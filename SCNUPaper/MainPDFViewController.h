//
//  MainPDFViewController.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-17.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class MyPDFDocument;
@class Comments;
@class VoicePlayer;

@interface MainPDFViewController : UIViewController <UIScrollViewDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate, UITableViewDelegate>

#pragma mark - PDF Model

/* 管理PDF文档的类 */
@property (strong, nonatomic) MyPDFDocument *myPDFDocument;

#pragma mark - PDF Views

/* 阅读论文的横向ScrollView */
@property (strong, nonatomic) UIScrollView *thesisPagesView;

/* 一个视图数组，用于呈现各个PDF页面的内容 */
@property (strong, nonatomic) NSMutableDictionary *viewsForThesisPages;

@property (strong, nonatomic) NSMutableArray *tempViews;

- (void)unenableViewAndBarsInteraction;
- (void)enableViewAndBarsInteraction;

#pragma mark - NavigationBar

/* 返回最近打开列表 */
- (IBAction)goBack_latestList:(id)sender;

/* 执行发邮件，上传文件到服务器等操作的按钮 */
@property (strong, nonatomic) IBOutlet UIBarButtonItem *performActions_barButtonItem;

/* 发邮件，上传文件到服务器 */
- (IBAction)performActions:(id)sender;

/* 判断文件是否被修改过 */
@property (assign, nonatomic) BOOL hasEdited;

/* 页面跳转 */
- (IBAction)turnToPage:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *pageInputView;
@property (strong, nonatomic) IBOutlet UITextField *inputPageIndex_textField;
- (IBAction)turnToPage_Action:(id)sender;
- (IBAction)cancelTurnPage_Action:(id)sender;

#pragma mark - Toolbar

/* 主选项工具栏 */
@property (strong, nonatomic) IBOutlet UIToolbar *mainOptions_Toolbar;

/* 直接添加笔注 */
- (IBAction)addStrokes:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addStroke_barButtonItem;

/* 先选择文字，再添加文字或语音批注 */
- (IBAction)selectText:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *selectText_barButtonItem;

#pragma mark - Add Strokes

/* 添加笔注的工具栏 */
@property (strong, nonatomic) IBOutlet UIToolbar *strokeOptions_Toolbar;

/* 撤销上一步操作 */
- (IBAction)undoStrokes:(id)sender;

/* 删除本页所有的笔注 */
- (IBAction)redoStrokes:(id)sender;

/* 完成添加笔注，并保存当前的笔注 */
- (IBAction)finishAddingStrokes:(id)sender;

/* 取消添加笔注，不保存当前的笔注 */
- (IBAction)cancelAddingStrokes:(id)sender;

#pragma mark - Add Comments

/* 添加批注的工具栏 */
@property (strong, nonatomic) IBOutlet UIToolbar *commentOptions_Toolbar;

/* 取消添加批注，当前批注不会被保存 */
- (IBAction)cancelAddingComments:(id)sender;

/* 完成添加批注 */
- (void)main_finishAddingComments;

#pragma mark - Check Comments

- (void)checkComments;

@property (strong, nonatomic) IBOutlet UIView *viewForCheckComments;/* 查看批注视图的容器 */
@property (strong, nonatomic) IBOutlet UITableView *checkCommentsTable;
@property (strong, nonatomic) IBOutlet UIToolbar *checkCommentsOptions_Toolbar;/* 查看批注的主要选项的工具栏 */
- (IBAction)dismissCommentsView:(id)sender;/* 取消添加批注 */

/* 添加新的批注 */
@property (strong, nonatomic) IBOutlet UIView *addNewComments_Menu;
- (IBAction)addNewComments:(id)sender;/* 增加新的批注 */
- (IBAction)addNewTextComments:(id)sender;
- (IBAction)addNewVoiceComments:(id)sender;

@property (strong, nonatomic) Comments    *allComments; // CommentTable的DataSource
@property (strong, nonatomic) VoicePlayer *voicePlayer;
@property (strong, nonatomic) IBOutlet UIButton *stopPlaying_button;
- (IBAction)stopPlayingRecordFile:(id)sender;

#pragma mark - Comment Details

/* 文字批注细节视图 */
@property (strong, nonatomic) IBOutlet UIView *viewForCommentDetails;
@property (strong, nonatomic) IBOutlet UITextView *commentDetailsView;

/* 查看文字批注细节时底部的工具栏 */
@property (strong, nonatomic) IBOutlet UIToolbar *commentDetailOption_Toolbar;

/* 返回批注列表 */
- (IBAction)gobackToCommentsTable:(id)sender;

/* 编辑文字批注细节的按钮 */
@property (strong, nonatomic) IBOutlet UIBarButtonItem *edit_barButtonItem;

/* 直接编辑当前查看的文字批注细节 */
- (IBAction)editCommentDetails:(id)sender;

@end
