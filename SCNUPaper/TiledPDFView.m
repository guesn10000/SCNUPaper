//
//  TiledPDFView.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-17.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "TiledPDFView.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "Cookies.h"
#import "JCAlert.h"
#import "JCFilePersistence.h"
#import "Comments.h"
#import "MyPDFPage.h"
#import "MyPDFAnnotation.h"
#import "AnnotationView.h"
#import "Stroke.h"
#import "CommentStroke.h"
#import "MyPDFButton.h"
#import "KeyGeneraton.h"
#import "TextAnnotation.h"
#import "Recorder.h"
#import "PDFScrollView.h"
#import "MainPDFViewController.h"

#pragma mark - Constants

static const CGFloat gVolumeView_Width  = 200.0;
static const CGFloat gVolumeView_Height = 40.0;

static NSString * const kPoints = @"Draw_Points";
static NSString * const kColor  = @"Draw_Color";
static NSString * const kWidth  = @"Draw_Width";

enum EditType {
    kAddEmpty    = 0,
    kAddStrokes  = 1,
    kAddComments = 2,
    kAddTextComments  = 3,
    kAddVoiceComments = 4
};

enum AddTextType {
    kTxtNone = 0,
    kTxtNew,
    kTxtAdd,
    kTxtEdit
};

enum AddVoiceType {
    kVocNone = 0,
    kVocNew,
    kVocAdd
};

@interface TiledPDFView ()

#pragma mark - Private

/* PDF页面参数 */
@property (strong, nonatomic) MyPDFPage *myPDFPage_;

/* 手势的起点和终点 */
@property (assign, nonatomic) CGPoint beginPoint_;
@property (assign, nonatomic) CGPoint endPoint_;

/* 批改的类型 */
@property (assign, nonatomic) enum EditType     editType_;
@property (assign, nonatomic) enum AddTextType  addTextType_;
@property (assign, nonatomic) enum AddVoiceType addVoiceType_;

/* 当前视图上的所有按钮和标记视图 */
@property (strong, nonatomic) NSMutableArray  *buttonsInView_;
@property (strong, nonatomic) NSMutableArray  *annoViewsInView_;

/* 保存临时生成的PDFAnnotation或Comment的frame */
@property (strong, nonatomic) MyPDFAnnotation *tempPDFAnnotation_;
@property (strong, nonatomic) NSString        *tempCommentFrame_;

/* 保存笔注的参数 */
@property (strong, nonatomic) Stroke         *draw_Stroke_;       // 一个包含属性的笔画
@property (strong, nonatomic) NSMutableArray *draw_strokePoints_; // 笔画中的点集
@property (strong, nonatomic) UIColor        *draw_strokeColor_;  // 笔画的颜色
@property (assign, nonatomic) CGFloat         draw_strokeWidth_;  // 笔画的粗细

@end


@implementation TiledPDFView

#pragma mark - Initailization

/* 初始化 */
- (id)initWithFrame:(CGRect)frame MyPDFPage:(MyPDFPage *)myPDFPage {
    self = [super initWithFrame:frame];
    
    if (self) {
        /* 1.设置基本参数 */
        self.myPDFPage_  = myPDFPage;
        self.beginPoint_ = CGPointZero;
        self.endPoint_   = CGPointZero;
        
        
        /* 2.初始化添加笔注参数 */
        self.editType_ = kAddEmpty;
        self.draw_strokePoints_ = [[NSMutableArray alloc] init];
        self.draw_strokeColor_  = [UIColor blackColor];
        self.draw_strokeWidth_  = DRAW_STROKE_WIDTH;
        
        
        /* 3.初始化添加批注参数 */
        self.tempCommentFrame_ = NSStringFromCGRect(CGRectZero);
        self.addTextType_  = kTxtNone;
        self.addVoiceType_ = kVocNone;
        
        
        /* 4.设置视图部分 */
        
        // 设置CATiledLayer，保持高清输出
        CATiledLayer *tiledLayer      = (CATiledLayer *)[self layer];
        tiledLayer.levelsOfDetail     = (IS_IPAD) ? 1 : 4;
        tiledLayer.levelsOfDetailBias = (IS_IPAD) ? 1 : 3;
        tiledLayer.tileSize           = (IS_IPAD) ? CGSizeMake(1024.0, 1024.0) : CGSizeMake(512.0, 512.0);
        
        // 为了解决涂鸦卡顿问题而引入的一个图片视图
        self.screenCapture = [[UIImageView alloc] initWithImage:nil];
        self.screenCapture.frame = self.bounds;
        [self addSubview:self.screenCapture];
        
        // 设置添加批注菜单
        NSArray *menu_nibs = [[NSBundle mainBundle] loadNibNamed:@"CommentsMenu" owner:self options:nil];
        self.commentsMenu = [menu_nibs objectAtIndex:0];
        self.commentsMenu.layer.cornerRadius = 6.0;
        self.commentsMenu.layer.masksToBounds = YES;
        self.commentsMenu.hidden = YES;
        [self addSubview:self.commentsMenu];
        
        // 设置添加文字批注的输入视图
        AppDelegate *appDelegate = APPDELEGATE;
        NSArray *text_nibs = [[NSBundle mainBundle] loadNibNamed:@"InputTextView" owner:self options:nil];
        self.inputTextView = [text_nibs objectAtIndex:0];
        self.inputTextView.layer.cornerRadius = 6.0;
        self.inputTextView.layer.masksToBounds = YES;
        self.inputTextView.center = appDelegate.window.center;
        [appDelegate.window addSubview:self.inputTextView];
        self.inputTextView.hidden = YES;
        
        // 设置添加语音批注的录音视图
        NSArray *voice_nibs = [[NSBundle mainBundle] loadNibNamed:@"RecorderView" owner:self options:nil];
        self.recorderView = [voice_nibs objectAtIndex:0];
        self.recorderView.layer.cornerRadius = 6.0;
        self.recorderView.layer.masksToBounds = YES;
        CGFloat height = self.recorderView.frame.size.height;
        self.recorderView.center = CGPointMake(appDelegate.window.frame.size.width / 2,
                                               appDelegate.window.frame.size.height - height / 2);
        [appDelegate.window addSubview:self.recorderView];
        
        self.recorder = [[Recorder alloc] init];
        
        // 添加调节音量视图
        self.volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(0.0,
                                                                         0.0,
                                                                         gVolumeView_Width,
                                                                         gVolumeView_Height)];
        self.volumeView.center = CGPointMake(appDelegate.window.frame.size.width / 2,
                                             self.recorderView.frame.size.height - gVolumeView_Height / 2);
        [self.volumeView sizeToFit];
        [self.recorderView addSubview:self.volumeView];
        
        self.recorderView.hidden = YES;
        
        // 当前视图上的所有按钮和标记组成的数组
        self.buttonsInView_   = [[NSMutableArray alloc] init];
        self.annoViewsInView_ = [[NSMutableArray alloc] init];
    }
    
    return self;
}

/* 返回一个CATiledLayer Class */
+ (Class)layerClass {
    return [CATiledLayer class];
}

- (void)setDefaultScalesWithScale:(CGFloat)defaultScale ConvertScale:(CGFloat)convertScale {
    self.defaultScale = defaultScale;
    self.iPhone_iPad_Scale = convertScale;
}

#pragma mark - Add Strokes

/* 开始添加笔注，这里进行一些初始化操作 */
- (void)addStrokesToPDFView {
    // 1.进入添加笔注状态
    self.editType_ = kAddStrokes;
    
    
    // 2.重置pdf page管理的current draw strokes数组
    self.myPDFPage_.currentDrawStrokes = [[NSMutableArray alloc] init];
    
    
    // 3.初始化画笔的参数
    self.draw_strokeWidth_ = DRAW_STROKE_WIDTH;
    self.draw_strokeColor_ = [[UIColor alloc] initWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    
    
    // 4.隐藏当前页面的按钮，防止干扰添加笔注
    [self hidePDFButtonsInView];
}

/* 删除之前的笔注 */
- (void)undoStrokeFromPDFView {
    // 移除最后一个笔画
    if (self.myPDFPage_.currentDrawStrokes && self.myPDFPage_.currentDrawStrokes.count > 0) {
        [self.myPDFPage_.currentDrawStrokes removeLastObject];
    }
    else {
        [JCAlert alertWithMessage:@"您尚未编辑或当前添加的笔注为空"];
        return;
    }
    
    // 刷新屏幕截图
    [self updateScreenCapture];
}

/* 删除当前页面所有笔注 */
- (void)deleteAllStrokesFromPDFView {
    // 删除pdf page管理的currentDrawStrokes和previousDrawStrokes中的Strokes
    self.myPDFPage_.previousDrawStrokes = nil;
    self.myPDFPage_.previousDrawStrokes = [[NSMutableArray alloc] init];
    
    self.myPDFPage_.currentDrawStrokes  = nil;
    self.myPDFPage_.currentDrawStrokes  = [[NSMutableArray alloc] init];
    
    self.draw_strokePoints_             = nil;
    self.draw_strokePoints_             = [[NSMutableArray alloc] init];
    
    // 刷新视图
    [self updateScreenCapture];
}

/* 完成添加笔注 */
- (void)finishAddingStrokesToPDFView {
    // 1.取消添加笔注状态
    self.editType_ = kAddEmpty;
    
    
    // 2.保存pdf page管理的currentDrawStrokes中的Strokes到previousDrawStrokes中
    if (!self.myPDFPage_.previousDrawStrokes) {
        self.myPDFPage_.previousDrawStrokes = [[NSMutableArray alloc] init];
    }
    if (self.myPDFPage_.currentDrawStrokes && self.myPDFPage_.currentDrawStrokes.count > 0) {
        for (Stroke *stroke in self.myPDFPage_.currentDrawStrokes) {
            NSMutableArray *scalePoints = [[NSMutableArray alloc] init];
            for (NSString *pointString in stroke.points) {
                CGPoint point = CGPointFromString(pointString);
                
                // scalePoints为初始页面尺寸下所记录的点集
                [scalePoints addObject:NSStringFromCGPoint(point)];
            }
            stroke.points = [[NSMutableArray alloc] initWithArray:[scalePoints mutableCopy]];
            
            [self.myPDFPage_.previousDrawStrokes addObject:stroke];
        }
    }
    
    // 压缩成二进制数据
    NSData        *data  = [NSKeyedArchiver archivedDataWithRootObject:self.myPDFPage_.previousDrawStrokes];
    NSMutableData *mdata = [data mutableCopy];
    
    
    // 3.写入文件中
    AppDelegate        *appDelegate    = APPDELEGATE;
    JCFilePersistence *filePersistence = [[JCFilePersistence alloc] init];
    NSString *drawStrokesFileName      = [NSString stringWithFormat:@"%zu_drawStrokes.plist", self.myPDFPage_.pageIndex];
    NSString *drawStrokesFileDirectory = [NSString stringWithFormat:@"%@/%@/%@/%@",
                                          appDelegate.cookies.username,
                                          appDelegate.cookies.pureFileName,
                                          PDF_FOLDER_NAME,
                                          DRAW_STROKES_FOLDER_NAME];
    [filePersistence saveMutableData:mdata
                              ToFile:drawStrokesFileName
             inDocumentWithDirectory:drawStrokesFileDirectory];
    
    
    // 4.清空数组
    self.draw_strokePoints_            = nil;
    self.draw_strokePoints_            = [[NSMutableArray alloc] init];
    
    self.myPDFPage_.currentDrawStrokes = nil;
    self.myPDFPage_.currentDrawStrokes = [[NSMutableArray alloc] init];
    
    
    // 5.更新视图
    self.screenCapture.image = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
    
    // 6.恢复页面中的按钮
    [self showPDFButtonsInView];
}

/* 取消添加笔注 */
- (void)cancelAddingStrokesToPDFView {
    // 1.刷新当前页面
    self.screenCapture.image = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
    
    // 2.取消添加笔注状态
    self.editType_ = kAddEmpty;
    
    // 3.清空draw_strokePoints和pdf page管理的current draw strokes
    self.draw_strokePoints_            = nil;
    self.draw_strokePoints_            = [[NSMutableArray alloc] init];
    
    self.myPDFPage_.currentDrawStrokes = nil;
    self.myPDFPage_.currentDrawStrokes = [[NSMutableArray alloc] init];
    
    // 4.恢复页面中的按钮
    [self showPDFButtonsInView];
}

#pragma mark - Add Comments

/* 进入添加批注的状态 */
- (void)addCommentsToPDFView {
    self.editType_ = kAddComments;
    [self hidePDFButtonsInView];
}

/* 完成并保存本次添加的批注 */
- (void)finishAddingCommentsToPDFView:(NSInteger)commentType {
    /* 1.退出添加批注状态 */
    [self quit_addingComments];
    
    /* 2.添加本次添加的所有批注到数组中 */
    AppDelegate *appDelegate = APPDELEGATE;
    NSInteger key = [appDelegate.keyGeneration getCommentAnnotationKeyWithPageIndex:self.myPDFPage_.pageIndex];
    CommentStroke *stroke = [[CommentStroke alloc] initWithFrame:self.tempCommentFrame_ Key:key];
    [stroke setAnnotationType:commentType];
    [self.myPDFPage_.previousStrokesForComments addObject:stroke];
    
    /* 3.刷新页面 */
    self.screenCapture.image = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
    
    /* 4.添加button到annotatons的frame上 */
    [self addAnnotationsInView];
}

/* 取消本次添加的批注 */
- (void)cancelAddingCommentsToPDFView {
    [self quit_addingComments];
    self.screenCapture.image = nil;
    self.tempCommentFrame_ = NSStringFromCGRect(CGRectZero);
    self.tempPDFAnnotation_ = nil;
}

/* 退出添加批注状态，还原一些参数，隐藏编辑视图 */
- (void)quit_addingComments {
    // 解除添加批注状态
    self.editType_    = kAddEmpty;
    self.addTextType_  = kTxtNone;
    self.addVoiceType_ = kVocNone;
    [self.input_textView resignFirstResponder];
    
    // 隐藏仍在显示的菜单，输入文本框，录音视图等
    self.commentsMenu.hidden = YES;
    self.inputTextView.hidden = YES;
    self.recorderView.hidden = YES;
    
    // 显示页面上隐藏的按钮
    [self showPDFButtonsInView];
}

/* 保存批注到文件中 */
- (void)saveCommentStrokes {
    AppDelegate *appDelegate = APPDELEGATE;
    JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
    
    // 保存笔画和笔画按钮的边界到文件中
    // Document / Username / PureFileName / PDF / CommentStrokes / PageIndex_commentStrokes.plist
    NSString *strokesFileName = [NSString stringWithFormat:@"%zu_commentStrokes.plist", self.myPDFPage_.pageIndex];
    NSString *strokesFileDirectory = [NSString stringWithFormat:@"%@/%@/%@/%@", appDelegate.cookies.username, appDelegate.cookies.pureFileName, PDF_FOLDER_NAME, COMMENT_STROKES_FOLDER_NAME];
    
    NSData        *data  = [NSKeyedArchiver archivedDataWithRootObject:self.myPDFPage_.previousStrokesForComments];
    NSMutableData *mdata = [[NSMutableData alloc] initWithData:data];
    
    [filePersistence saveMutableData:mdata
                              ToFile:strokesFileName
             inDocumentWithDirectory:strokesFileDirectory];
}

#pragma mark - Comments Annotations

/* 重新加载本页的标记 */
- (void)reloadAnnotations {
    // 清空页面上的按钮
    for (UIButton *button in self.buttonsInView_) {
        [button removeFromSuperview];
    }
    self.buttonsInView_ = nil;
    self.buttonsInView_ = [[NSMutableArray alloc] init];
    
    // 清空页面上的标记视图
    for (AnnotationView *annoView in self.annoViewsInView_) {
        [annoView removeFromSuperview];
    }
    self.annoViewsInView_ = nil;
    self.annoViewsInView_ = [[NSMutableArray alloc] init];
    
    // 清空之前的PDFAnnotation数组，然后遍历本页的CommentStroke，在本页添加更新后的所有标记
    AppDelegate *appDelegate = APPDELEGATE;
    self.myPDFPage_.previousAnnotationsForComments = nil;
    self.myPDFPage_.previousAnnotationsForComments = [[NSMutableArray alloc] init];
    for (CommentStroke *stroke in self.myPDFPage_.previousStrokesForComments) {
        self.tempPDFAnnotation_ = [[MyPDFAnnotation alloc] initWithFrame:stroke.frame
                                                                   Scale:self.iPhone_iPad_Scale
                                                                     Key:stroke.buttonKey
                                                               PageIndex:self.myPDFPage_.pageIndex
                                                          TextAnnotation:stroke.hasTextAnnotation
                                                         VoiceAnnotation:stroke.hasVoiceAnnotation
                                   ];
        [appDelegate.keyGeneration increaseCommentAnnotationKeyinPageIndex:self.myPDFPage_.pageIndex];
        [self.myPDFPage_.previousAnnotationsForComments addObject:self.tempPDFAnnotation_];
    }
}

/* 添加annotatons到视图上 */
- (void)addAnnotationsInView {
    /* 1.重新加载本页之前的所有标记和按钮 */
    [self reloadAnnotations];
    
    /* 2.添加按钮和标记的视图到页面上 */
    for (MyPDFAnnotation *pdfAnnotation in self.myPDFPage_.previousAnnotationsForComments) {
        // 添加标记视图
        [self addSubview:pdfAnnotation.annotationView];
        [self.annoViewsInView_ addObject:pdfAnnotation.annotationView];
        
        // 添加按钮
        [self addSubview:pdfAnnotation.pdfButton.myButton];
        [pdfAnnotation.pdfButton addTargetForButton];
        [self.buttonsInView_ addObject:pdfAnnotation.pdfButton.myButton];
    }
}

- (void)showPDFButtonsInView {
    if (self.buttonsInView_) {
        for (UIButton *button in self.buttonsInView_) {
            button.hidden = NO;
        }
    }
}

- (void)hidePDFButtonsInView {
    if (self.buttonsInView_) {
        for (UIButton *button in self.buttonsInView_) {
            button.hidden = YES;
        }
    }
}

#pragma mark - Add Text Comments

- (void)prepareToAddText:(NSInteger)addTextType PreviousText:(NSString *)preText {
    self.addTextType_          = addTextType;
    self.editType_            = kAddEmpty;
    self.commentsMenu.hidden  = YES;
    self.inputTextView.hidden = NO;
    self.input_textView.text  = preText;
    [self.input_textView becomeFirstResponder];
    
    // 暂时解锁pdf scroll view的滚动，方便用户查看页面内容
    // 不能解锁缩放视图，否则缩放后视图的笔画可能错乱
    [self.containerScrollView setScrollEnabled:YES];
}

/* 点击了菜单中的添加文字选项后的响应方法 */
- (IBAction)addTextComments:(id)sender {
    [self prepareToAddText:kTxtNew PreviousText:@""];
}

- (void)addNewTextComments {
    [self prepareToAddText:kTxtAdd PreviousText:@""];
}

- (void)editTextComments {
    AppDelegate *appDelegate = APPDELEGATE;
    [self prepareToAddText:kTxtEdit PreviousText:appDelegate.mainPDFViewController.allComments.currentText];
}

/* 完成并保存输入的文字批注 */
- (IBAction)done_inputText:(id)sender {
    if (self.input_textView.text && ![self.input_textView.text isEqualToString:@""]) {
        AppDelegate *appDelegate = APPDELEGATE;
        NSString *filename = appDelegate.cookies.pureFileName;
        
        if (self.addTextType_ == kTxtNew) { // 添加新的文字批注
            [self finishAddingCommentsToPDFView:kAddTextComments]; // 添加批注到页面上和当前批注数组
            [self saveCommentStrokes];                             // 保存批注到文件
            [TextAnnotation saveInputText:self.input_textView.text
                            PDFAnnotation:self.tempPDFAnnotation_
                                 toFolder:filename];               // 保存文字批注内容到文件中
            [self.containerScrollView unlockPDFScrollView];        // 解锁pdf scroll view
            [appDelegate.mainPDFViewController main_finishAddingComments]; // 通知main pdf view controller完成添加批注
            [Comments showCommentsWithPage:self.myPDFPage_.pageIndex Key:self.tempPDFAnnotation_.commentAnnotationKey]; // 显示批注表格
            self.tempCommentFrame_ = NSStringFromCGRect(CGRectZero);
            self.tempPDFAnnotation_ = nil;
        }
        else if (self.addTextType_ == kTxtAdd) { // 在当前文字批注的基础上添加新的文字批注
            [self quit_addingComments]; // 退出添加批注状态
            
            // 刷新页面的标记
            for (int i = 0; i < self.myPDFPage_.previousStrokesForComments.count; i++) {
                CommentStroke *stroke = [self.myPDFPage_.previousStrokesForComments objectAtIndex:i];
                if (stroke.buttonKey == appDelegate.mainPDFViewController.allComments.currentButtonKey) {
                    if (!stroke.hasTextAnnotation) {
                        stroke.hasTextAnnotation = YES;
                        [self.myPDFPage_.previousStrokesForComments removeObjectAtIndex:i];
                        [self.myPDFPage_.previousStrokesForComments insertObject:stroke atIndex:i];
                        [self addAnnotationsInView];
                    }
                    break;
                }
            }
            [self saveCommentStrokes]; // 保存批注到文件
            [TextAnnotation addNewInputText:self.input_textView.text
                                   toFolder:filename
                                       Page:self.myPDFPage_.pageIndex
                                        Key:appDelegate.mainPDFViewController.allComments.currentButtonKey]; // 保存文字批注内容到文件中
            [self.containerScrollView unlockPDFScrollView]; // 解锁pdf scroll view
            [appDelegate.mainPDFViewController main_finishAddingComments]; // 通知main pdf view controller完成添加批注
            [Comments showCommentsWithPage:self.myPDFPage_.pageIndex
                                       Key:appDelegate.mainPDFViewController.allComments.currentButtonKey]; // 显示批注表格
        }
        else if (self.addTextType_ == kTxtEdit) { // 编辑现存的某个文字批注内容
            [self quit_addingComments]; // 退出添加批注状态
            [TextAnnotation editInputText:self.input_textView.text
                                 toFolder:filename
                                     Page:self.myPDFPage_.pageIndex
                                      Key:appDelegate.mainPDFViewController.allComments.currentButtonKey
                                      Row:appDelegate.mainPDFViewController.allComments.currentRow]; // 保存修改结果到文件
            [self.containerScrollView unlockPDFScrollView]; // 解锁pdf scroll view
            [appDelegate.mainPDFViewController main_finishAddingComments]; // 通知main pdf view controller完成添加批注
            [Comments showCommentsWithPage:self.myPDFPage_.pageIndex
                                       Key:appDelegate.mainPDFViewController.allComments.currentButtonKey]; // 显示批注表格
        }
    }
    else {
        [JCAlert alertWithMessage:@"输入的文字内容为空，请重新输入"];
        return;
    }
}

/* 取消输入的文字批注 */
- (IBAction)cancel_inputText:(id)sender {
    AppDelegate *appDelegate = APPDELEGATE;
    
    [self cancelAddingCommentsToPDFView];
    [self.containerScrollView unlockPDFScrollView];
    [appDelegate.mainPDFViewController main_finishAddingComments];
    
    if (self.addTextType_ == kTxtAdd || self.addTextType_ == kTxtEdit) {
        [Comments showCommentsWithPage:self.myPDFPage_.pageIndex
                                   Key:appDelegate.mainPDFViewController.allComments.currentButtonKey]; // 显示批注表格
    }
}

#pragma mark - Add Voice Comments

/* 点击了菜单中的添加语音选项后的响应方法 */
- (IBAction)addVoiceComments:(id)sender {
    self.editType_ = kAddEmpty;
    self.addVoiceType_ = kVocNew;
    self.commentsMenu.hidden = YES;
    self.recorderView.hidden = NO;
    
    // 暂时解锁pdf scroll view的滚动，方便用户查看页面内容
    // 不能解锁缩放视图，否则缩放后该视图将变为nil
    [(UIScrollView *)self.superview setScrollEnabled:YES];
}

/* 给表格添加新的语音批注 */
- (void)addNewVoiceComments {
    self.editType_ = kAddEmpty;
    self.addVoiceType_ = kVocAdd;
    self.commentsMenu.hidden = YES;
    self.recorderView.hidden = NO;
    
    // 暂时解锁pdf scroll view的滚动，方便用户查看页面内容
    // 不能解锁缩放视图，否则缩放后该视图将变为nil
    [(UIScrollView *)self.superview setScrollEnabled:YES];
}

/* 进行录音动作 */
- (IBAction)doRecording:(id)sender {
    AppDelegate *appDelegate = APPDELEGATE;
    [appDelegate.mainPDFViewController.navigationController.view setUserInteractionEnabled:NO];
    
    if (self.recorder.isRecording) { // YES to NO，关闭录音
        [self.recorder doRecording];
        
        [self.record_button setTitle:@"重新录音" forState:UIControlStateNormal];
        self.doneRecord_button.enabled = YES;
        self.cancelRecord_button.enabled = YES;
        [appDelegate.mainPDFViewController.view setUserInteractionEnabled:YES];
        [appDelegate.window                     setAlpha:DEFAULT_VIEW_ALPHA];
        [self.recording_spinner stopAnimating];
    }
    else { // No to YES，开始录音
        [self.recording_spinner startAnimating];
        [appDelegate.mainPDFViewController.view setUserInteractionEnabled:NO];
        [appDelegate.window                     setAlpha:UNABLE_VIEW_ALPHA];
        [self.record_button setTitle:@"完成录音" forState:UIControlStateNormal];
        self.doneRecord_button.enabled = NO;
        self.cancelRecord_button.enabled = NO;
        
        [self.recorder doRecording];
    }
}

/* 完成录音并保存语音批注 */
- (IBAction)done_record:(id)sender {
    AppDelegate *appDelegate = APPDELEGATE;
    
    if (self.addVoiceType_ == kVocNew) {
        [self finishAddingCommentsToPDFView:kAddVoiceComments]; // 保存批注并添加批注到页面上
        [self saveCommentStrokes]; // 保存批注到文件
        [self.recorder saveRecordVoiceForPDFAnnotaton:self.tempPDFAnnotation_ toFolder:appDelegate.cookies.pureFileName]; // 保存录音文件
        [self.containerScrollView unlockPDFScrollView]; // 解锁pdf scroll view
        [appDelegate.mainPDFViewController main_finishAddingComments]; // 通知main pdf view controller完成添加批注
        [Comments showCommentsWithPage:self.myPDFPage_.pageIndex Key:self.tempPDFAnnotation_.commentAnnotationKey]; // 显示批注表格
        self.tempCommentFrame_ = NSStringFromCGRect(CGRectZero);
        self.tempPDFAnnotation_ = nil;
    }
    else if (self.addVoiceType_ == kVocAdd) {
        [self quit_addingComments]; // 退出添加批注状态
        
        // 刷新页面的标记
        for (int i = 0; i < self.myPDFPage_.previousStrokesForComments.count; i++) {
            CommentStroke *stroke = [self.myPDFPage_.previousStrokesForComments objectAtIndex:i];
            if (stroke.buttonKey == appDelegate.mainPDFViewController.allComments.currentButtonKey) {
                if (!stroke.hasVoiceAnnotation) {
                    stroke.hasVoiceAnnotation = YES;
                    [self.myPDFPage_.previousStrokesForComments removeObjectAtIndex:i];
                    [self.myPDFPage_.previousStrokesForComments insertObject:stroke atIndex:i];
                    [self addAnnotationsInView];
                }
                break;
            }
        }
        [self saveCommentStrokes]; // 保存批注到文件
        [self.recorder addNewRecordVoiceToFolder:appDelegate.cookies.pureFileName
                                            Page:self.myPDFPage_.pageIndex
                                             Key:appDelegate.mainPDFViewController.allComments.currentButtonKey];
        [self.containerScrollView unlockPDFScrollView];
        [appDelegate.mainPDFViewController main_finishAddingComments]; // 通知main pdf view controller完成添加批注
        [Comments showCommentsWithPage:self.myPDFPage_.pageIndex Key:appDelegate.mainPDFViewController.allComments.currentButtonKey];
    }
    
    [self.record_button setTitle:@"开始录音" forState:UIControlStateNormal];
    
    [appDelegate.mainPDFViewController.navigationController.view setUserInteractionEnabled:YES];
}

/* 取消录音 */
- (IBAction)cancel_record:(id)sender {
    // 删除录音文件
    [self.recorder unsaveRecordVoice];
    
    [self cancelAddingCommentsToPDFView];
    [self.containerScrollView unlockPDFScrollView];
    AppDelegate *appDelegate = APPDELEGATE;
    [appDelegate.mainPDFViewController main_finishAddingComments];
    
    if (self.addVoiceType_ == kVocAdd) {
        [Comments showCommentsWithPage:self.myPDFPage_.pageIndex
                                   Key:appDelegate.mainPDFViewController.allComments.currentButtonKey]; // 显示批注表格
    }
    
    [appDelegate.mainPDFViewController.navigationController.view setUserInteractionEnabled:YES];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.commentsMenu.hidden) {
        return;
    }
    
    if (self.editType_ == kAddStrokes) {
        // 记录起点
        self.beginPoint_ = [[touches anyObject] locationInView:self];
        
        // 清空draw strokes数组
        self.draw_strokePoints_ = nil;
        self.draw_strokePoints_ = [[NSMutableArray alloc] init];
        
        // 将手势起点加入数组
        [self.draw_strokePoints_ addObject:NSStringFromCGPoint(self.beginPoint_)];
        
        self.draw_Stroke_ = nil;
        self.draw_Stroke_ = [[Stroke alloc] init];
        [self.myPDFPage_.currentDrawStrokes addObject:self.draw_Stroke_];
    }
    else if (self.editType_ == kAddComments) {
        self.beginPoint_ = [[touches anyObject] locationInView:self];
        self.tempCommentFrame_ = NSStringFromCGRect(CGRectZero);
    }
    else {
        return;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.commentsMenu.hidden) {
        return;
    }
    
    if (self.editType_ == kAddStrokes) {
        // 记录当前的移动点
        CGPoint currentPoint = [[touches anyObject] locationInView:self];
        self.endPoint_       = currentPoint;
        
        // 将当前移动点加入数组
        [self.draw_strokePoints_ addObject:NSStringFromCGPoint(currentPoint)];
        
        // 设置笔画属性
        self.draw_Stroke_ = nil;
        self.draw_Stroke_ = [[Stroke alloc] initWithPoints:[self.draw_strokePoints_ mutableCopy]
                                                     Color:self.draw_strokeColor_
                                                     Width:self.draw_strokeWidth_];
        [self.myPDFPage_.currentDrawStrokes removeLastObject];
        [self.myPDFPage_.currentDrawStrokes addObject:self.draw_Stroke_];
    }
    else if (self.editType_ == kAddComments) {
        // 记录当前的移动点
        self.endPoint_ = [[touches anyObject] locationInView:self];
        
        // 添加标准页面尺寸下的button frame到frames数组中
        CGFloat x = MIN(self.beginPoint_.x, self.endPoint_.x);
        CGFloat y = MIN(self.beginPoint_.y, self.endPoint_.y);
        CGFloat w = fabsf(self.endPoint_.x - self.beginPoint_.x);
        CGFloat h = fabsf(self.endPoint_.y - self.beginPoint_.y);
        self.tempCommentFrame_ = NSStringFromCGRect(CGRectMake(x, y, w, h));
    }
    else {
        return;
    }
    
    // 刷新屏幕截图
    [self updateScreenCapture];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded_Cancelled:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded_Cancelled:touches withEvent:event];
}

- (void)touchesEnded_Cancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.commentsMenu.hidden) {
        return;
    }
    
    if (self.editType_ == kAddStrokes) { // 添加笔注状态
        return;
    }
    else if (self.editType_ == kAddComments) {
        // 记录手势终点
        self.endPoint_ = [[touches anyObject] locationInView:self];
        
        // 设置菜单的位置并显示
        CGFloat midX = (self.beginPoint_.x + self.endPoint_.x) / 2;
        CGFloat midY = (self.beginPoint_.y + self.endPoint_.y) / 2;
        self.commentsMenu.center = CGPointMake(midX, midY);
        self.commentsMenu.hidden = NO;
    }
    else {
        return;
    }
}

#pragma mark - Draw

- (void)drawRect:(CGRect)rect
{
}

// Draw the CGPDFPageRef into the layer at the correct scale.
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    /* 1.Draw pdf page */
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(context, self.bounds);
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextScaleCTM(context, self.defaultScale, self.defaultScale);
    CGContextDrawPDFPage(context, self.myPDFPage_.pdfPageRef);
    CGContextRestoreGState(context);
    
    /* 2.Draw停留在本页上的点集 */
    CGContextSaveGState(context);
    CGContextScaleCTM(context, self.iPhone_iPad_Scale, self.iPhone_iPad_Scale);
    
    // 笔注部分
    drawDrawStrokes(context, self.myPDFPage_.previousDrawStrokes);
    
    // 批注部分
    for (int i = 0; i < self.myPDFPage_.previousStrokesForComments.count; i++) {
        CommentStroke *commStroke = [self.myPDFPage_.previousStrokesForComments objectAtIndex:i];
        drawCommentFrame(context, commStroke.frame);
    }
    
    CGContextRestoreGState(context);
}

/* 刷新屏幕截图 */
- (void)updateScreenCapture {
    /* 获取屏幕截图 */
    self.screenCapture.image = nil;
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 1.5f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, YES); // 设置抗锯齿属性
    
    /* 新画上去的笔注或批注 */
    CGContextSaveGState(context);
    drawDrawStrokes(context, self.myPDFPage_.currentDrawStrokes); // 笔注部分
    drawCommentFrame(context, self.tempCommentFrame_); // 批注部分
    CGContextRestoreGState(context);
    
    /* 更新截图 */
    self.screenCapture.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

/* draw笔注的所有笔画 */
void drawDrawStrokes(CGContextRef context, NSMutableArray *drawStrokes) {
    if (drawStrokes && drawStrokes.count > 0) {
        for (Stroke *stroke in drawStrokes) {
            NSMutableArray *points = stroke.points;
            UIColor        *color  = stroke.color;
            CGFloat         width  = stroke.width;
            
            if (points && points.count > 0) {
                UIBezierPath *linesPath = [UIBezierPath bezierPath];
                CGPoint startPoint = CGPointFromString(points[0]);
                [linesPath moveToPoint:startPoint];
                
                for (int i = 1; i < points.count; i++) {
                    CGPoint nextPoint = CGPointFromString(points[i]);
                    [linesPath addLineToPoint:nextPoint];
                }
                
                CGContextAddPath(context, linesPath.CGPath);
                CGContextSetStrokeColorWithColor(context, color.CGColor);
                CGContextSetLineWidth(context, width);
                CGContextSetLineCap(context, kCGLineCapRound);
                CGContextSetLineJoin(context, kCGLineJoinRound);
                CGContextDrawPath(context, kCGPathStroke);
            }
        }
    }
}

/* draw批注对应的边界 */
void drawCommentFrame(CGContextRef context, NSString *frame) {
    CGRect rect = CGRectFromString(frame);
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
    CGContextAddRect(context, rect);
    CGContextSetFillColorWithColor(context, COMMENT_STROKE_COLOR.CGColor);
    CGContextSetLineWidth(context, COMMENT_STROKE_WIDTH);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextDrawPath(context, kCGPathFill);
}

@end
