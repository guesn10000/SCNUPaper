//
//  MainPDFViewController.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-17.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "MainPDFViewController.h"
#import "AppDelegate.h"
#import "Cookies.h"
#import "URLConnector.h"
#import "MyPDFDocument.h"
#import "Comments.h"
#import "VoicePlayer.h"
#import "KeyGeneraton.h"
#import "MyPDFCreator.h"
#import "PDFScrollView.h"
#import "LoginViewController.h"
#import "LatestViewController.h"

#pragma mark - Constants

static NSString * const kPrePage = @"pre";
static NSString * const kCurPage = @"cur";
static NSString * const kNxtPage = @"nxt";

static const CGFloat kStopButtonLoc = 60.0;

enum AlertDelegate {
    kDefaultAlert = 0,
    kRemvStkAlert,
    kSyncronAlert
};

@interface MainPDFViewController ()

#pragma mark - Private

/* 用户是否正在编辑，包括添加笔注和添加文字或语音 */
@property (assign, nonatomic) BOOL isEditing_;

/* 该参数决定执行alertview delegate时的动作 */
@property (assign, nonatomic) enum AlertDelegate alertDelegate_;

@property (assign, nonatomic) CGRect tempFrame_;

@end

@implementation MainPDFViewController

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setBarsWithAuthority];
    [self setViewsForCheckComments];
    
    /* 初始化一些基本参数 */
    self.isEditing_ = NO;
    self.hasEdited  = NO;
    self.alertDelegate_ = kDefaultAlert;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.mainOptions_Toolbar.hidden = NO;
    
    // 产生管理Annotation key的序列号生成器
    AppDelegate *appDelegate  = [AppDelegate sharedDelegate];
    appDelegate.keyGeneration = [[KeyGeneraton alloc] initWithDocumentName:appDelegate.cookies.pureFileName];
    
    /* 设置基本的界面部分 */
    // 设置标题
    self.navigationItem.title = [NSString stringWithFormat:@"%zu / %zu", self.myPDFDocument.currentIndex, self.myPDFDocument.totalPages];
    
    // 建立显示论文内容的视图
    [self buildThesisPages];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.thesisPagesView removeFromSuperview];
    
    self.mainOptions_Toolbar.hidden    = YES;
    self.strokeOptions_Toolbar.hidden  = YES;
    self.commentOptions_Toolbar.hidden = YES;
    self.pageInputView.hidden          = YES;
    self.viewForCheckComments.hidden   = YES;
    self.stopPlaying_button.hidden     = YES;
    self.viewForCommentDetails.hidden  = YES;
    self.addNewComments_Menu.hidden    = YES;
}

/* 根据权限设置工具条和导航栏 */
- (void)setBarsWithAuthority {
    // 隐藏返回按钮
    self.navigationItem.hidesBackButton = YES;
    
    // 设置边界位置
    CGRect toolbarsFrame = CGRectMake(0,
                                      self.view.bounds.size.height - TOOLBAR_HEIGHT,
                                      self.view.bounds.size.width,
                                      TOOLBAR_HEIGHT);
    
    // 从nib中加载工具栏数组
    NSString *nibName = (IS_IPAD) ? IPAD_TOOLBARS_NIB : IPHONE_TOOLBARS_NIB;
    NSArray *nibToolbars = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    
    // 设置工具栏和导航栏按钮
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    if (appDelegate.cookies.isTeacher && IS_IPAD) { // 登陆的用户是老师，并且用iPad登陆
        self.mainOptions_Toolbar    = (UIToolbar *)nibToolbars[0];
        self.strokeOptions_Toolbar  = (UIToolbar *)nibToolbars[1];
        self.commentOptions_Toolbar = (UIToolbar *)nibToolbars[2];
        
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
    else { // 登陆的用户是学生，或用iPhone登陆
        self.navigationItem.rightBarButtonItem = nil; // 隐藏同步及发送邮件的操作按钮
        
        self.mainOptions_Toolbar = (UIToolbar *)nibToolbars[0];
        self.mainOptions_Toolbar.frame = toolbarsFrame;
        self.mainOptions_Toolbar.hidden = NO;
        self.addStroke_barButtonItem.enabled = NO;
        [self.addStroke_barButtonItem setTitle:@""];
        self.selectText_barButtonItem.enabled = NO;
        [self.selectText_barButtonItem setTitle:@""];
        [self.view addSubview:self.mainOptions_Toolbar];
    }
    
    // 添加页码输入视图
    NSString *pageInputNibName = (IS_IPAD) ? IPAD_INPUT_PAGE_XIB : IPHONE_INPUT_PAGE_XIB;
    NSArray *inputNibs = [[NSBundle mainBundle] loadNibNamed:pageInputNibName owner:self options:nil];
    self.pageInputView = [inputNibs objectAtIndex:0];
    self.pageInputView.layer.cornerRadius = 6.0;
    self.pageInputView.layer.masksToBounds = YES;
    self.pageInputView.center = appDelegate.window.center;
    self.pageInputView.hidden = YES;
    [appDelegate.window addSubview:self.pageInputView];
}

/* 设置展示批注的视图 */
- (void)setViewsForCheckComments {
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    // 设置展现comments列表视图
    NSString *commNibname = (IS_IPAD) ? IPAD_COMMENT_TABLE_XIB : IPHONE_COMMENT_TABLE_XIB;
    NSArray *commNibs = [[NSBundle mainBundle] loadNibNamed:commNibname owner:self options:nil];
    self.viewForCheckComments = [commNibs objectAtIndex:0];
    self.viewForCheckComments.layer.cornerRadius = 6.0;
    self.viewForCheckComments.layer.masksToBounds = YES;
    self.viewForCheckComments.hidden = YES;
    if (!self.allComments) {
        self.allComments = [[Comments alloc] init];
    }
    self.allComments.currentText = @"";
    self.checkCommentsTable.delegate   = self;
    self.checkCommentsTable.dataSource = self.allComments;
    
    CGFloat height = self.viewForCheckComments.bounds.size.height;
    CGPoint center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height - height / 2);
    self.viewForCheckComments.center = center;
    self.viewForCheckComments.hidden = YES;
    [appDelegate.window addSubview:self.viewForCheckComments];
    
    if (!self.voicePlayer) {
        self.voicePlayer = [[VoicePlayer alloc] initWithCenter:self.viewForCheckComments.center];
    }
    self.stopPlaying_button = [commNibs objectAtIndex:2];
    self.stopPlaying_button.hidden = YES;
    self.stopPlaying_button.center = CGPointMake(center.x, center.y + kStopButtonLoc);
    [appDelegate.window addSubview:self.stopPlaying_button];
    
    
    // 设置comment的细节视图
    NSString *detailNibname = (IS_IPAD) ? IPAD_COMMENT_DETAIL_XIB : IPHONE_COMMENT_DETAIL_XIB;
    NSArray *detailNibs = [[NSBundle mainBundle] loadNibNamed:detailNibname owner:self options:nil];
    self.viewForCommentDetails = [detailNibs objectAtIndex:0];
    self.viewForCommentDetails.layer.cornerRadius = 6.0;
    self.viewForCommentDetails.layer.masksToBounds = YES;
    
    height = self.viewForCommentDetails.bounds.size.height;
    center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height - height / 2);
    self.viewForCommentDetails.center = center;
    self.viewForCommentDetails.hidden = YES;
    [appDelegate.window addSubview:self.viewForCommentDetails];
    
    // 添加批注的菜单
    if (IS_IPAD) {
        self.addNewComments_Menu = [commNibs objectAtIndex:1];
        self.addNewComments_Menu.layer.cornerRadius = 6.0;
        self.addNewComments_Menu.layer.masksToBounds = YES;
        CGFloat menuHeight = self.addNewComments_Menu.bounds.size.height / 2 + TOOLBAR_HEIGHT;
        self.addNewComments_Menu.center = CGPointMake(self.addNewComments_Menu.bounds.size.width / 2,
                                                      self.view.bounds.size.height - menuHeight);
        self.addNewComments_Menu.hidden = YES;
        [appDelegate.window addSubview:self.addNewComments_Menu];
    }
}

/* 建立显示论文内容的视图 */
- (void)buildThesisPages {
    self.thesisPagesView = [[UIScrollView alloc]
                            initWithFrame:CGRectMake(0,
                                                     STATUS_NAVIGATIONBAR_HEIGHT,
                                                     self.view.bounds.size.width,
                                                     self.view.bounds.size.height -\
                                                     STATUS_NAVIGATIONBAR_HEIGHT  -\
                                                     TOOLBAR_HEIGHT)];
    [self.view addSubview:self.thesisPagesView];
    self.thesisPagesView.delegate                       = self;
    self.thesisPagesView.autoresizesSubviews            = YES;
    self.thesisPagesView.pagingEnabled                  = YES;
    self.thesisPagesView.showsHorizontalScrollIndicator = NO;
    self.thesisPagesView.showsVerticalScrollIndicator   = NO;
    self.thesisPagesView.bouncesZoom                    = NO;
    self.thesisPagesView.bounces                        = YES;
    self.thesisPagesView.scrollEnabled                  = YES;
    self.thesisPagesView.userInteractionEnabled         = YES;
    self.thesisPagesView.contentOffset                  = CGPointZero;
    self.thesisPagesView.contentSize = CGSizeMake(self.thesisPagesView.bounds.size.width * self.myPDFDocument.totalPages,
                                                  self.thesisPagesView.bounds.size.height);
    
    if (!self.viewsForThesisPages) {
        self.viewsForThesisPages = [[NSMutableDictionary alloc] init];
    }
    else {
        [self.viewsForThesisPages removeAllObjects];
    }
    
    if (!self.tempViews) {
        self.tempViews = [[NSMutableArray alloc] init];
    }
    
    self.tempFrame_ = CGRectMake(0, 0, self.thesisPagesView.bounds.size.width, self.thesisPagesView.bounds.size.height);
    NSUInteger pages = (self.myPDFDocument.totalPages == 1) ? 1 : 2;
    for (int i = 1; i <= pages; i++) {
        CGRect rect = self.tempFrame_;
        rect.origin.x = (i - 1) * self.thesisPagesView.bounds.size.width;
        PDFScrollView *pdfScrollView = [[PDFScrollView alloc] initWithFrame:rect
                                                                   Document:self.myPDFDocument.pdfDocumentRef
                                                                  PageIndex:i];
        if (i == 1) {
            [self.viewsForThesisPages setObject:pdfScrollView forKey:kCurPage];
        }
        else if (i == 2) {
            [self.viewsForThesisPages setObject:pdfScrollView forKey:kNxtPage];
        }
        [self.thesisPagesView addSubview:pdfScrollView];
        [self.tempViews addObject:pdfScrollView];
        [pdfScrollView setNeedsLayout]; // 立即刷新pdfScrollView的位置
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)unenableViewAndBarsInteraction {
    self.view.alpha = UNABLE_VIEW_ALPHA;
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    self.view.userInteractionEnabled = NO;
}

- (void)enableViewAndBarsInteraction {
    self.view.userInteractionEnabled = YES;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    self.view.alpha = DEFAULT_VIEW_ALPHA;
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
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    if (self.hasEdited && appDelegate.cookies.isTeacher) {
        self.alertDelegate_ = kSyncronAlert;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注意" message:@"是否保存修改？本操作将使用您的流量"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消" otherButtonTitles:@"保存并返回", @"返回但不保存", nil];
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
    AppDelegate       *appDelegate     = [AppDelegate sharedDelegate];
    MyPDFCreator      *pdfCreator      = [MyPDFCreator sharedInstance];
    JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
    
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
    NSData *attachmentData;
    NSString *tmpFolderDirectory = [filePersistence getDirectoryOfTmpFolder];
    NSString *pdfFilePath = [tmpFolderDirectory stringByAppendingPathComponent:appDelegate.cookies.pdfFileName];
    [filePersistence removeFileAtPath:pdfFilePath];
    if (![pdfCreator createNewPDFFile]) {
        pdfFilePath = [NSString stringWithFormat:@"%@/%@/%@/%@", appDelegate.cookies.username, appDelegate.cookies.pureFileName, PDF_FOLDER_NAME, appDelegate.cookies.pdfFileName];
    }
    attachmentData = [NSData dataWithContentsOfFile:pdfFilePath];
    [mailViewController addAttachmentData:attachmentData mimeType:PDF_MIME_TYPE fileName:appDelegate.cookies.pdfFileName];
    
    // 5.呼出发送视图
    [self presentViewController:mailViewController animated:YES completion:nil];
}

/* MailComposer Delegate */
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
#ifndef LOCAL_TEST
    MyPDFCreator *pdfCreator = [MyPDFCreator sharedInstance];
#endif
    
    switch (result) {
        case MFMailComposeResultCancelled:
            [JCAlert alertWithMessage:@"取消发送邮件"];
            break;
            
        case MFMailComposeResultSaved:
#ifndef LOCAL_TEST
            [pdfCreator uploadFilesToServer];
#endif
            [JCAlert alertWithMessage:@"邮件已保存"];
            break;
            
        case MFMailComposeResultSent:
#ifndef LOCAL_TEST
            [pdfCreator uploadFilesToServer];
#endif
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
    [self unenableViewAndBarsInteraction];
    self.inputPageIndex_textField.text = @"";
    self.pageInputView.hidden = NO;
    [self.inputPageIndex_textField becomeFirstResponder];
}

/* 确定跳转页面 */
- (IBAction)turnToPage_Action:(id)sender {
    NSInteger pageIndex = self.inputPageIndex_textField.text.integerValue;
    if (pageIndex > 0 && pageIndex <= self.myPDFDocument.totalPages) {
        [self.inputPageIndex_textField resignFirstResponder];
        self.pageInputView.hidden = YES;
        
        int temp = pageIndex - self.myPDFDocument.currentIndex;
        self.myPDFDocument.currentIndex = pageIndex;
        if (temp == 0) {
            [self enableViewAndBarsInteraction];
            return;
        }
        else if (temp == 1) {
            [self scrollToNextPage:pageIndex];
        }
        else if (temp == -1) {
            [self scrollToPreviousPage:pageIndex];
        }
        else {
            [self jumpToPage:pageIndex];
        }
        
        self.navigationItem.title = [NSString stringWithFormat:@"%zu / %zu", self.myPDFDocument.currentIndex, self.myPDFDocument.totalPages];
        
        
        self.thesisPagesView.contentOffset = CGPointMake((pageIndex - 1) * self.thesisPagesView.frame.size.width, 0.0);
        [self enableViewAndBarsInteraction];
    }
    else {
        [JCAlert alertWithMessage:@"您输入的页码出错，请重新输入"];
    }
}

/* 取消跳转页面 */
- (IBAction)cancelTurnPage_Action:(id)sender {
    [self.inputPageIndex_textField resignFirstResponder];
    self.pageInputView.hidden = YES;
    [self enableViewAndBarsInteraction];
}

#pragma mark - Add Strokes

/* 主选项：添加笔注 */
- (IBAction)addStrokes:(id)sender {
    [self lockThesisPagesView];
    
    // 1.设置底部的工具栏
    self.mainOptions_Toolbar.hidden   = YES;
    self.strokeOptions_Toolbar.hidden = NO;
    
    
    // 2.开始选择文字
    self.isEditing_ = YES;
    [[self.viewsForThesisPages objectForKey:kCurPage] calloutPDFView_addStrokes];
}

/* 添加笔注：撤销当前的一个笔画 */
- (IBAction)undoStrokes:(id)sender {
    [[self.viewsForThesisPages objectForKey:kCurPage] calloutPDFView_undoStroke];
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
    [[self.viewsForThesisPages objectForKey:kCurPage] calloutPDFView_finishAddingStrokes]; // 通知对应视图完成添加批注
    [self unlockThesisPagesView];
}

/* 添加笔注：取消添加笔画 */
- (IBAction)cancelAddingStrokes:(id)sender {
    // 重置底部工具栏为主选项工具栏
    self.strokeOptions_Toolbar.hidden = YES;
    self.mainOptions_Toolbar.hidden   = NO;
    
    self.isEditing_ = NO; // 解除编辑状态
    [[self.viewsForThesisPages objectForKey:kCurPage] calloutPDFView_cancelAddingStrokes]; // 通知对应视图取消添加批注
    [self unlockThesisPagesView];
}

#pragma mark - Add Comments

/* 选择文字 */
- (IBAction)selectText:(id)sender {
    [self lockThesisPagesView];
    
    // 1.设置底部的工具栏
    self.mainOptions_Toolbar.hidden    = YES;
    self.commentOptions_Toolbar.hidden = NO;
    
    // 2.开始选择文字
    self.isEditing_ = YES; // 进入编辑状态
    [[self.viewsForThesisPages objectForKey:kCurPage] calloutPDFView_addComments];
}

/* 取消添加当前批注 */
- (IBAction)cancelAddingComments:(id)sender {
    self.commentOptions_Toolbar.hidden = YES;
    self.mainOptions_Toolbar.hidden    = NO;
    
    self.isEditing_ = NO;
    [[self.viewsForThesisPages objectForKey:kCurPage] calloutPDFView_cancelAddingComments];
    [self unlockThesisPagesView];
}

/* 完成添加批注 */
- (void)main_finishAddingComments {
    self.commentOptions_Toolbar.hidden = YES;
    self.mainOptions_Toolbar.hidden    = NO;
    
    self.isEditing_ = NO;
    self.hasEdited = YES;
    [self unlockThesisPagesView];
}

#pragma mark - Check Comments

/* 查看批注，呼出批注列表 */
- (void)checkComments {
    [self lockThesisPagesView];
    [self.checkCommentsTable reloadData];
    self.viewForCheckComments.hidden  = NO;
    self.viewForCommentDetails.hidden = YES;
    self.addNewComments_Menu.hidden   = YES;
}

/* 取消查看批注，让批注列表消失 */
- (IBAction)dismissCommentsView:(id)sender {
    self.addNewComments_Menu.hidden   = YES;
    self.viewForCheckComments.hidden  = YES;
    self.viewForCommentDetails.hidden = YES;
    self.mainOptions_Toolbar.hidden   = NO;
    [self unlockThesisPagesView];
}

/* 呼出添加新的批注内容的菜单 */
- (IBAction)addNewComments:(id)sender {
    self.addNewComments_Menu.hidden = NO;
}

/* 为批注添加新的文字内容 */
- (IBAction)addNewTextComments:(id)sender {
    [self lockThesisPagesView];
    self.viewForCheckComments.hidden = YES;
    self.addNewComments_Menu.hidden  = YES;
    [[self.viewsForThesisPages objectForKey:kCurPage] calloutPDFView_addNewTextComments];
}

/* 为批注添加新的语音内容 */
- (IBAction)addNewVoiceComments:(id)sender {
    [self lockThesisPagesView];
    self.viewForCheckComments.hidden = YES;
    self.addNewComments_Menu.hidden  = YES;
    [[self.viewsForThesisPages objectForKey:kCurPage] calloutPDFView_addNewVoiceComments];
}

#pragma mark - TableView Delegate

/* 点击查看批注列表中的内容 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) { // 打开文字批注内容
        self.commentDetailsView.text = self.allComments.textComments[indexPath.row];
        self.allComments.currentRow  = indexPath.row;
        self.allComments.currentText = self.allComments.textComments[indexPath.row];
        self.viewForCheckComments.hidden  = YES;
        self.viewForCommentDetails.hidden = NO;
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
    return 60.0;
}

/* 暂停播放录音 */
- (IBAction)stopPlayingRecordFile:(id)sender {
    [self.voicePlayer stopRecordVoicePlaying];
    self.stopPlaying_button.hidden = YES;
}

#pragma mark - Comment Detail

/* 返回批注列表 */
- (IBAction)gobackToCommentsTable:(id)sender {
    self.viewForCommentDetails.hidden = YES;
    self.viewForCheckComments.hidden  = NO;
}

/* 编辑批注细节中的文字内容 */
- (IBAction)editCommentDetails:(id)sender {
    [self lockThesisPagesView];
    self.viewForCommentDetails.hidden = YES;
    [[self.viewsForThesisPages objectForKey:kCurPage] calloutPDFView_editTextComments];
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
    
    PDFScrollView *tempScrollView = [self.viewsForThesisPages objectForKey:kCurPage];
    int temp = page - tempScrollView.pageIndex;
    if (temp == 0) {
        return;
    }
    if (temp == 1) {
        [self scrollToNextPage:page];
    }
    else if (temp == -1) {
        [self scrollToPreviousPage:page];
    }
    else {
        [self jumpToPage:page];
    }
}

- (void)scrollToNextPage:(NSUInteger)page {
    PDFScrollView *preScrollView = [self.viewsForThesisPages objectForKey:kCurPage];
    PDFScrollView *curScrollView = [self.viewsForThesisPages objectForKey:kNxtPage];
    [self.viewsForThesisPages setObject:preScrollView forKey:kPrePage];
    [self.viewsForThesisPages setObject:curScrollView forKey:kCurPage];
    
    if (page == self.myPDFDocument.totalPages) {
        return;
    }
    
    CGRect rect = self.tempFrame_;
    rect.origin.x = page * self.thesisPagesView.bounds.size.width;
    PDFScrollView *nxtScrollView = [[PDFScrollView alloc] initWithFrame:rect
                                                               Document:self.myPDFDocument.pdfDocumentRef
                                                              PageIndex:(page + 1)];
    [self.tempViews addObject:nxtScrollView];
    [self.thesisPagesView addSubview:nxtScrollView];
    [nxtScrollView setNeedsLayout];
    [self.viewsForThesisPages setObject:nxtScrollView forKey:kNxtPage];
}

- (void)scrollToPreviousPage:(NSUInteger)page {
    PDFScrollView *curScrollView = [self.viewsForThesisPages objectForKey:kPrePage];
    PDFScrollView *nxtScrollView = [self.viewsForThesisPages objectForKey:kCurPage];
    [self.viewsForThesisPages setObject:curScrollView forKey:kCurPage];
    [self.viewsForThesisPages setObject:nxtScrollView forKey:kNxtPage];
    
    if (page == 1) {
        return;
    }
    
    CGRect rect = self.tempFrame_;
    rect.origin.x = (page - 2) * self.thesisPagesView.bounds.size.width;
    PDFScrollView *preScrollView = [[PDFScrollView alloc] initWithFrame:rect
                                                               Document:self.myPDFDocument.pdfDocumentRef
                                                              PageIndex:(page - 1)];
    [self.tempViews addObject:preScrollView];
    [self.thesisPagesView addSubview:preScrollView];
    [preScrollView setNeedsLayout];
    [self.viewsForThesisPages setObject:preScrollView forKey:kPrePage];
}

- (void)jumpToPage:(NSUInteger)page {
    for (PDFScrollView *view in self.tempViews) {
        [view removeFromSuperview];
    }
    [self.tempViews removeAllObjects];
    [self.viewsForThesisPages removeAllObjects];
    
    CGRect rect = self.tempFrame_;
    
    rect.origin.x = (page - 1) * self.thesisPagesView.bounds.size.width;
    PDFScrollView *tempScrollView = [[PDFScrollView alloc] initWithFrame:rect
                                                                Document:self.myPDFDocument.pdfDocumentRef
                                                               PageIndex:page];
    [self.tempViews addObject:tempScrollView];
    [self.thesisPagesView addSubview:tempScrollView];
    [tempScrollView setNeedsLayout];
    [self.viewsForThesisPages setObject:tempScrollView forKey:kCurPage];
    
    if (page != 1) {
        rect.origin.x -= self.thesisPagesView.bounds.size.width;
        tempScrollView = [[PDFScrollView alloc] initWithFrame:rect
                                                     Document:self.myPDFDocument.pdfDocumentRef
                                                    PageIndex:(page - 1)];
        [self.tempViews addObject:tempScrollView];
        [self.thesisPagesView addSubview:tempScrollView];
        [tempScrollView setNeedsLayout];
        [self.viewsForThesisPages setObject:tempScrollView forKey:kPrePage];
    }
    
    if (page != self.myPDFDocument.totalPages) {
        rect = self.tempFrame_;
        rect.origin.x = page * self.thesisPagesView.bounds.size.width;
        tempScrollView = [[PDFScrollView alloc] initWithFrame:rect
                                                     Document:self.myPDFDocument.pdfDocumentRef
                                                    PageIndex:(page + 1)];
        [self.tempViews addObject:tempScrollView];
        [self.thesisPagesView addSubview:tempScrollView];
        [tempScrollView setNeedsLayout];
        [self.viewsForThesisPages setObject:tempScrollView forKey:kNxtPage];
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.alertDelegate_ == kSyncronAlert) { // 同步对话框
        AppDelegate *appDelegate = [AppDelegate sharedDelegate];
        if (buttonIndex == 0) { // 取消
            return;
        }
        else if (buttonIndex == 1) { // 保存修改并返回
            [appDelegate unenableWindowInteraction];
            
#ifndef LOCAL_TEST
            // 创建pdf文件并上传到服务器
            MyPDFCreator *pdfCreator = [MyPDFCreator sharedInstance];
            [pdfCreator createNewPDFFile];
            [pdfCreator uploadFilesToServer];
#endif
        }
        
        // 返回最近打开列表
        [self.navigationController popToViewController:appDelegate.latestViewController animated:YES];
        [appDelegate enableWindowInteraction];
    }
    else if (self.alertDelegate_ == kRemvStkAlert) { // 移除当前页面所有笔注对话框
        if (buttonIndex == 1) { // 确定删除本页所有笔画
            [[self.viewsForThesisPages objectForKey:kCurPage] calloutPDFView_deleteAllStrokes];
            [self finishAddingStrokes:nil];
        }
    }
}

@end
