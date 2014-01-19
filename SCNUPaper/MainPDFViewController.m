//
//  MainPDFViewController.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-17.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "MainPDFViewController.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "JCAlert.h"
#import "JCFilePersistence.h"
#import "KeyGeneraton.h"
#import "Cookies.h"
#import "URLConnector.h"
#import "MyPDFDocument.h"
#import "MyPDFCreator.h"
#import "Comments.h"
#import "PDFScrollView.h"
#import "Comments.h"
#import "VoicePlayer.h"
#import "LoginViewController.h"
#import "LatestViewController.h"

@interface MainPDFViewController ()

/* 用户是否正在编辑，包括添加笔注和添加文字或语音 */
@property (assign, nonatomic) BOOL isEditing_;

/* 从nib加载的工具栏数组 */
@property (assign, nonatomic) NSArray *nibToolbars_;

/* 该参数决定执行alertview delegate时的动作 */
@property (assign, nonatomic) NSInteger alertDelegate_;

@end

@implementation MainPDFViewController

#pragma mark - Constants

static NSInteger kDefaultAlert  = 0;
static NSInteger kRemvStkAlert  = 1;
static NSInteger kSyncronAlert  = 2;
const  CGFloat   kCellHeight    = 60.0;
const  CGFloat   kStopButtonLoc = 60.0;

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* 初始化一些基本参数 */
    
    self.isEditing_ = NO;
    self.hasEdited  = NO;
    self.alertDelegate_ = kDefaultAlert;
    self.view.backgroundColor = (IS_IPAD) ? [UIColor whiteColor] : [UIColor lightGrayColor];
    
    // 产生管理Annotation key的序列号生成器
    AppDelegate *appDelegate  = APPDELEGATE;
    appDelegate.keyGeneration = [[KeyGeneraton alloc] initWithDocumentName:appDelegate.cookies.pureFileName];
    
    
    /* 设置基本的界面部分 */
    
    // 设置标题
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = [NSString stringWithFormat:@"%zu / %zu", self.myPDFDocument.currentIndex, self.myPDFDocument.totalPages];
    
    // 根据用户权限决定是否显示工具栏和导航栏的按钮
    [self setBarsWithAuthority];
    
    // 建立显示论文内容的视图
    [self buildThesisPages];
    
    // 设置显示comments结果的视图
    [self setViewsForCheckComments];
}

/* 根据权限设置工具条和导航栏 */
- (void)setBarsWithAuthority {
    // 设置边界位置
    CGRect toolbarsFrame = CGRectMake(0,
                                      self.view.bounds.size.height - TOOLBAR_HEIGHT,
                                      self.view.bounds.size.width,
                                      TOOLBAR_HEIGHT
                                      );
    
    // 从nib中加载工具栏数组
    NSString *nibName = (IS_IPAD) ? IPAD_TOOLBARS_NIB : IPHONE_TOOLBARS_NIB;
    self.nibToolbars_ = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    
    // 设置工具栏和导航栏按钮
    AppDelegate *appDelegate = APPDELEGATE;
    if (appDelegate.cookies.isTeacher && IS_IPAD) { // 登陆的用户是老师，并且用iPad登陆
        self.mainOptions_Toolbar    = (UIToolbar *)self.nibToolbars_[0];
        self.strokeOptions_Toolbar  = (UIToolbar *)self.nibToolbars_[1];
        self.commentOptions_Toolbar = (UIToolbar *)self.nibToolbars_[2];
        
        self.mainOptions_Toolbar.frame    = toolbarsFrame;
        self.strokeOptions_Toolbar.frame  = toolbarsFrame;
        self.commentOptions_Toolbar.frame = toolbarsFrame;
        
        self.mainOptions_Toolbar.hidden    = NO;
        self.strokeOptions_Toolbar.hidden  = YES;
        self.commentOptions_Toolbar.hidden = YES;
        
        [self.view addSubview:self.mainOptions_Toolbar];
        [self.view addSubview:self.strokeOptions_Toolbar];
        [self.view addSubview:self.commentOptions_Toolbar];
    }
    else { // 登陆的用户是学生
        self.navigationItem.rightBarButtonItem = nil; // 隐藏同步及发送邮件的操作按钮
        
        self.mainOptions_Toolbar = (UIToolbar *)self.nibToolbars_[0];
        self.mainOptions_Toolbar.frame = toolbarsFrame;
        self.mainOptions_Toolbar.hidden = NO;
        self.addStroke_barButtonItem.enabled = NO;
        [self.addStroke_barButtonItem setTitle:@""];
        self.selectText_barButtonItem.enabled = NO;
        [self.selectText_barButtonItem setTitle:@""];
        [self.view addSubview:self.mainOptions_Toolbar];
    }
    
    NSString *pageInputNibName = (IS_IPAD) ? @"PageInputView" : @"iPhone_PageInput";
    NSArray *inputNibs = [[NSBundle mainBundle] loadNibNamed:pageInputNibName owner:self options:nil];
    self.pageInputView = [inputNibs objectAtIndex:0];
    self.pageInputView.layer.cornerRadius = 6.0;
    self.pageInputView.layer.masksToBounds = YES;
    self.pageInputView.center = appDelegate.window.center;
    self.pageInputView.hidden = YES;
    [appDelegate.window addSubview:self.pageInputView];
}

/* 建立显示论文内容的视图 */
- (void)buildThesisPages {
    self.thesisPagesView = [[UIScrollView alloc]
                            initWithFrame:CGRectMake(0,
                                                     STATUS_NAVIGATIONBAR_HEIGHT,
                                                     self.view.bounds.size.width,
                                                     self.view.bounds.size.height -\
                                                     STATUS_NAVIGATIONBAR_HEIGHT  -\
                                                     TOOLBAR_HEIGHT)
                            ];
    [self.view addSubview:self.thesisPagesView];
    self.thesisPagesView.backgroundColor                = [UIColor lightGrayColor];
    self.thesisPagesView.delegate                       = self;
    self.thesisPagesView.autoresizesSubviews            = YES;
    self.thesisPagesView.contentOffset                  = CGPointZero;
    self.thesisPagesView.directionalLockEnabled         = NO;
    self.thesisPagesView.pagingEnabled                  = YES;
    self.thesisPagesView.showsHorizontalScrollIndicator = NO;
    self.thesisPagesView.showsVerticalScrollIndicator   = NO;
    self.thesisPagesView.bouncesZoom                    = NO;
    self.thesisPagesView.bounces                        = YES;
    self.thesisPagesView.scrollEnabled                  = YES;
    self.thesisPagesView.userInteractionEnabled         = YES;
    self.thesisPagesView.contentSize                    = CGSizeMake(self.thesisPagesView.bounds.size.width *\
                                                                     self.myPDFDocument.totalPages,
                                                                     self.thesisPagesView.bounds.size.height);
    
    // 设置scroll view中的内容
    self.viewsForThesisPages = [[NSMutableArray alloc] init];
    for (int i = 1; i <= self.myPDFDocument.totalPages; i++) {
        PDFScrollView *pdfScrollView = [[PDFScrollView alloc]
                                        initWithFrame:CGRectMake((i - 1) * self.thesisPagesView.bounds.size.width,
                                                                 0,
                                                                 self.thesisPagesView.bounds.size.width,
                                                                 self.thesisPagesView.bounds.size.height)
                                        Document:self.myPDFDocument.pdfDocumentRef
                                        PageIndex:i
                                        ];
        [self.viewsForThesisPages addObject:pdfScrollView];
        [self.thesisPagesView addSubview:pdfScrollView];
        [pdfScrollView setNeedsLayout]; // 立即刷新pdfScrollView的位置
    }
}

/* 设置展示批注的视图 */
- (void)setViewsForCheckComments {
    AppDelegate *appDelegate = APPDELEGATE;
    
    // 设置展现comments列表视图
    NSString *commNibname = (IS_IPAD) ? @"CommentsTable" : @"CheckCommTable";
    NSArray *commNibs = [[NSBundle mainBundle] loadNibNamed:commNibname owner:self options:nil];
    self.viewForCheckComments = [commNibs objectAtIndex:0];
    self.viewForCheckComments.layer.cornerRadius = 6.0;
    self.viewForCheckComments.layer.masksToBounds = YES;
    self.viewForCheckComments.hidden = YES;
    self.allComments                   = [[Comments alloc] init];
    self.checkCommentsTable.delegate   = self;
    self.checkCommentsTable.dataSource = self.allComments;
    
    // 添加批注的菜单
    if (IS_IPAD) {
        self.addNewComments_Menu = [commNibs objectAtIndex:1];
        self.addNewComments_Menu.layer.cornerRadius = 6.0;
        self.addNewComments_Menu.layer.masksToBounds = YES;
        CGFloat menuHeight = self.addNewComments_Menu.frame.size.height / 2 + TOOLBAR_HEIGHT;
        self.addNewComments_Menu.center = CGPointMake(self.addNewComments_Menu.frame.size.width / 2,
                                                      self.view.frame.size.height - menuHeight);
        self.addNewComments_Menu.hidden = YES;
        [appDelegate.window addSubview:self.addNewComments_Menu];
    }
    
    CGFloat height = self.viewForCheckComments.frame.size.height;
    CGPoint center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height - height / 2);
    self.viewForCheckComments.center = center;
    self.viewForCheckComments.hidden = YES;
    [self.view addSubview:self.viewForCheckComments];
    
    self.voicePlayer = [[VoicePlayer alloc] initWithCenter:self.viewForCheckComments.center];
    self.stopPlaying_button = [commNibs objectAtIndex:2];
    self.stopPlaying_button.hidden = YES;
    self.stopPlaying_button.center = CGPointMake(center.x, center.y + kStopButtonLoc);
    [appDelegate.window addSubview:self.stopPlaying_button];
    
    
    // 设置comment的细节视图
    NSString *detailNibname = (IS_IPAD) ? @"CommentDetail" : @"CheckCommDetail";
    NSArray *detailNibs = [[NSBundle mainBundle] loadNibNamed:detailNibname owner:self options:nil];
    self.viewForCommentDetails = [detailNibs objectAtIndex:0];
    self.viewForCommentDetails.layer.cornerRadius = 6.0;
    self.viewForCommentDetails.layer.masksToBounds = YES;
    
    height = self.viewForCommentDetails.frame.size.height;
    center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height - height / 2);
    self.viewForCommentDetails.center = center;
    self.viewForCommentDetails.hidden = YES;
    [self.view addSubview:self.viewForCommentDetails];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (void)lockThesisPagesView {
    self.thesisPagesView.scrollEnabled = NO;
}

- (void)unlockThesisPagesView {
    self.thesisPagesView.scrollEnabled = YES;
}

#pragma mark - Navigation / Toolbar Item Actions

/* 返回最近打开列表 */
- (IBAction)goBack_latestList:(id)sender {
    AppDelegate *appDelegate = APPDELEGATE;
    if (self.hasEdited && appDelegate.cookies.isTeacher) {
        self.alertDelegate_ = kSyncronAlert;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注意" message:@"是否保存修改？本操作将使用您的流量"
                                                           delegate:self
                                                  cancelButtonTitle:@"返回但不保存" otherButtonTitles:@"保存并返回", nil];
        [alertView show];
    }
    else {
        // 返回最近打开列表
        [self.navigationController popToViewController:appDelegate.latestViewController animated:YES];
    }
}

/* 发送邮件，将文件与服务器同步 */
- (IBAction)performActions:(id)sender {
    // 1.创建视图控制器
    AppDelegate *appDelegate = APPDELEGATE;
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    if (!mailViewController) {
        // 在设备还没有添加邮件账户的时候mailViewController为空，下面的present view controller会导致程序崩溃，这里要作出判断
        [JCAlert alertWithMessage:@"您的设备尚未添加邮件帐户，无法发送邮件，请前往设置中添加邮件帐户"];
        return;
    }
    mailViewController.mailComposeDelegate = self;
    
    // 2.设置邮件主题
    [mailViewController setSubject:@"论文批改结果"];
    
    // 3.设置邮件主体内容
    [mailViewController setMessageBody:@"批改的论文已附在下列附件，如果想查看老师的批注，请使用\"论文批阅系统\"打开查看" isHTML:NO];
    
    // 4.添加附件
    if (self.hasEdited) {
        MyPDFCreator *pdfCreator = [[MyPDFCreator alloc] init];
        [pdfCreator createNewPDFFile];
        [pdfCreator uploadFilesToServer];
        self.hasEdited = NO;
    }
    
    NSString *folderDirectory = appDelegate.cookies.getPDFFolderDirectory;
    folderDirectory = [appDelegate.filePersistence getDirectoryInDocumentWithName:folderDirectory];
    NSString *pdfFilePath = [folderDirectory stringByAppendingPathComponent:appDelegate.cookies.pdfFileName];
    NSData *attachmentData = [NSData dataWithContentsOfFile:pdfFilePath];
    [mailViewController addAttachmentData:attachmentData mimeType:PDF_MIME_TYPE fileName:appDelegate.cookies.pdfFileName];
    
    // 5.呼出发送视图
    [self presentViewController:mailViewController animated:YES completion:nil];
}

/// MailComposer Delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            [JCAlert alertWithMessage:@"取消发送邮件"];
            break;
            
        case MFMailComposeResultSaved:
            [JCAlert alertWithMessage:@"邮件已保存"];
            break;
            
        case MFMailComposeResultSent:
            [JCAlert alertWithMessage:@"邮件已发送"];
            break;
            
        case MFMailComposeResultFailed:
            [JCAlert alertWithMessage:@"邮件发送失败" Error:error];
            break;
            
        default:
            NSLog(@"Send Mail Default");
            break;
            
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

/* 跳转到指定页 */
- (IBAction)turnToPage:(id)sender {
    self.view.userInteractionEnabled = NO;
    self.pageInputView.hidden = NO;
    self.inputPageIndex_textField.text = @"";
    [self.inputPageIndex_textField becomeFirstResponder];
    [self lockThesisPagesView];
}

- (IBAction)turnToPage_Action:(id)sender {
    NSInteger pageIndex = self.inputPageIndex_textField.text.integerValue;
    if (pageIndex > 0 && pageIndex <= self.myPDFDocument.totalPages) {
        [self.inputPageIndex_textField resignFirstResponder];
        self.view.userInteractionEnabled = YES;
        self.pageInputView.hidden = YES;
        [self unlockThesisPagesView];
        
        self.myPDFDocument.currentIndex = pageIndex;
        self.navigationItem.title = [NSString stringWithFormat:@"%zu / %zu", self.myPDFDocument.currentIndex, self.myPDFDocument.totalPages];
        self.thesisPagesView.contentOffset = CGPointMake((pageIndex - 1) * self.thesisPagesView.frame.size.width,
                                                         0.0);
    }
    else {
        [JCAlert alertWithMessage:@"您输入的页码出错"];
    }
}

- (IBAction)cancelTurnPage_Action:(id)sender {
    [self.inputPageIndex_textField resignFirstResponder];
    self.view.userInteractionEnabled = YES;
    self.pageInputView.hidden = YES;
    [self unlockThesisPagesView];
}

#pragma mark - Add Strokes

/* 主选项：添加笔注 */
- (IBAction)addStrokes:(id)sender {
    // 1.设置底部的工具栏
    self.mainOptions_Toolbar.hidden   = YES;
    self.strokeOptions_Toolbar.hidden = NO;
    
    
    // 2.开始选择文字
    self.isEditing_ = YES;
    self.thesisPagesView.scrollEnabled = NO; // 锁住scroll view的滑动
    [self.viewsForThesisPages[self.myPDFDocument.currentIndex - 1] calloutPDFView_addStrokes]; // 调用当前视图的add strokes方法
}

/* 添加笔注：撤销当前的一个笔画 */
- (IBAction)undoStrokes:(id)sender {
    [self.viewsForThesisPages[self.myPDFDocument.currentIndex - 1] calloutPDFView_undoStroke]; // 通知对应视图撤销当前笔注
}

/* 添加笔注：撤销当前页面所有笔画 */
- (IBAction)redoStrokes:(id)sender {
    self.alertDelegate_ = kRemvStkAlert;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"您确定要删除本页全部笔注吗?"
                                                       delegate:self
                                              cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

/* 添加笔注：完成添加笔画 */
- (IBAction)finishAddingStrokes:(id)sender {
    // 重置底部工具栏为主选项工具栏
    self.strokeOptions_Toolbar.hidden = YES;
    self.mainOptions_Toolbar.hidden   = NO;
    
    self.isEditing_ = NO; // 解除编辑状态
    self.hasEdited  = YES;
    self.thesisPagesView.scrollEnabled = YES; // 解锁
    [self.viewsForThesisPages[self.myPDFDocument.currentIndex - 1] calloutPDFView_finishAddingStrokes]; // 通知对应视图完成添加批注
}

/* 添加笔注：取消添加笔画 */
- (IBAction)cancelAddingStrokes:(id)sender {
    // 重置底部工具栏为主选项工具栏
    self.strokeOptions_Toolbar.hidden = YES;
    self.mainOptions_Toolbar.hidden   = NO;
    
    self.isEditing_ = NO; // 解除编辑状态
    self.thesisPagesView.scrollEnabled = YES; // 解锁
    [self.viewsForThesisPages[self.myPDFDocument.currentIndex - 1] calloutPDFView_cancelAddingStrokes]; // 通知对应视图取消添加批注
}

#pragma mark - Add Comments

/* 选择文字 */
- (IBAction)selectText:(id)sender {
    // 1.设置底部的工具栏
    self.mainOptions_Toolbar.hidden    = YES;
    self.commentOptions_Toolbar.hidden = NO;
    
    // 2.开始选择文字
    self.isEditing_ = YES; // 进入编辑状态
    self.thesisPagesView.scrollEnabled = NO; // 锁定scroll view的滚动
    [self.viewsForThesisPages[self.myPDFDocument.currentIndex - 1] calloutPDFView_addComments];
}

/* 取消添加当前批注 */
- (IBAction)cancelAddingComments:(id)sender {
    self.commentOptions_Toolbar.hidden = YES;
    self.mainOptions_Toolbar.hidden    = NO;
    
    self.isEditing_ = NO;
    self.thesisPagesView.scrollEnabled = YES;
    [self.viewsForThesisPages[self.myPDFDocument.currentIndex - 1] calloutPDFView_cancelAddingComments];
}

/* 完成添加批注 */
- (void)main_finishAddingComments {
    self.commentOptions_Toolbar.hidden = YES;
    self.mainOptions_Toolbar.hidden    = NO;
    
    self.isEditing_ = NO;
    self.hasEdited = YES;
    self.thesisPagesView.scrollEnabled = YES;
}

#pragma mark - Check Comments

- (void)checkComments {
    self.viewForCheckComments.hidden = NO;
    self.viewForCommentDetails.hidden = YES;
    [self lockThesisPagesView];
    [self.checkCommentsTable reloadData];
}

- (IBAction)dismissCommentsView:(id)sender {
    self.addNewComments_Menu.hidden = YES;
    self.viewForCheckComments.hidden = YES;
    self.viewForCommentDetails.hidden = YES;
    self.mainOptions_Toolbar.hidden = NO;
    [self unlockThesisPagesView];
}

- (IBAction)addNewComments:(id)sender {
    self.addNewComments_Menu.hidden = NO;
}

- (IBAction)addNewTextComments:(id)sender {
    self.viewForCheckComments.hidden = YES;
    self.addNewComments_Menu.hidden = YES;
    [self lockThesisPagesView];
    [self.viewsForThesisPages[self.myPDFDocument.currentIndex - 1] calloutPDFView_addNewTextComments];
}

- (IBAction)addNewVoiceComments:(id)sender {
    self.viewForCheckComments.hidden = YES;
    self.addNewComments_Menu.hidden = YES;
    [self lockThesisPagesView];
    [self.viewsForThesisPages[self.myPDFDocument.currentIndex - 1] calloutPDFView_addNewVoiceComments];
}

#pragma mark - TableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) { // 打开文字批注内容
        self.viewForCheckComments.hidden = YES;
        self.viewForCommentDetails.hidden = NO;
        self.commentDetailsView.text = self.allComments.textComments[indexPath.row];
        self.allComments.currentRow = indexPath.row;
        self.allComments.currentText = self.allComments.textComments[indexPath.row];
    }
    else if (indexPath.section == 1) { // 播放语音内容
        NSString *mp3FileName = self.allComments.voiceComments[indexPath.row];
        [self.voicePlayer playRecordVoice:mp3FileName];
        self.stopPlaying_button.hidden = NO;
    }
    else {
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (IBAction)stopPlayingRecordFile:(id)sender {
    [self.voicePlayer stopRecordVoicePlaying];
    self.stopPlaying_button.hidden = YES;
}

#pragma mark - Comment Detail

- (IBAction)gobackToCommentsTable:(id)sender {
    self.viewForCommentDetails.hidden = YES;
    self.viewForCheckComments.hidden = NO;
}

- (IBAction)editCommentDetails:(id)sender {
    self.viewForCommentDetails.hidden = YES;
    [self lockThesisPagesView];
    [self.viewsForThesisPages[self.myPDFDocument.currentIndex - 1] calloutPDFView_editTextComments];
}

#pragma mark - UIScrollViewDelegate

/* scroll事件尚未停止，即scrollView还没完成减速 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 如果当前scrollView的位移点大于当前页面的一半就跳转到下一个页面
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1; // 向下取整
    self.navigationItem.title = [NSString stringWithFormat:@"%d / %zu", page + 1, self.myPDFDocument.totalPages];
}

/* scrollView完成减速 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int page = scrollView.contentOffset.x / scrollView.frame.size.width;
    page++;
    self.myPDFDocument.currentIndex = page;
    self.navigationItem.title = [NSString stringWithFormat:@"%zu / %zu", self.myPDFDocument.currentIndex, self.myPDFDocument.totalPages];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.alertDelegate_ == kSyncronAlert) {
        AppDelegate *appDelegate = APPDELEGATE;
        if (buttonIndex == 1) {
            appDelegate.window.alpha = UNABLE_VIEW_ALPHA;
            appDelegate.window.userInteractionEnabled = NO;
            
            MyPDFCreator *pdfCreator = [[MyPDFCreator alloc] init];
            [pdfCreator createNewPDFFile];
            [pdfCreator uploadFilesToServer];
        }
        
        // 返回最近打开列表
        [self.navigationController popToViewController:appDelegate.latestViewController animated:YES];
        appDelegate.window.alpha = DEFAULT_VIEW_ALPHA;
        appDelegate.window.userInteractionEnabled = YES;
    }
    else if (self.alertDelegate_ == kRemvStkAlert) {
        if (buttonIndex == 1) { // 删除本页所有笔画
            [self.viewsForThesisPages[self.myPDFDocument.currentIndex - 1] calloutPDFView_deleteAllStrokes];
            [self finishAddingStrokes:nil];
        }
        else { // 取消
            
        }
    }
}

@end
