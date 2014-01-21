//
//  TiledPDFView.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-17.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>

@class MyPDFPage;
@class Recorder;
@class PDFScrollView;
@class CommentsMenu;
@class RecorderView;

@interface TiledPDFView : UIView

/// Base Model

/* 初始化 */
- (id)initWithFrame:(CGRect)frame Scale:(CGFloat)scale MyPDFPage:(MyPDFPage *)myPDFPage;

/* pdf页面的默认缩放比例 */
@property (assign, nonatomic) CGFloat defaultScale;

/* pdf页面的默认尺寸 */
@property (assign, nonatomic) CGSize  defaultSize;

/* 从iPad视图过渡到iPhone或iPad视图的缩放比例 */
@property (assign, nonatomic) CGFloat iPhone_iPad_Scale;

/* 设置视图横向和纵向缩放的比例 */
- (void)setScales;

/* 指向上层视图 */
@property (weak, nonatomic) PDFScrollView *containerScrollView;


/// Base Views

/* 屏幕截图 */
@property (strong, nonatomic) UIImageView *screenCapture;

/* 添加批改意见的菜单 */
@property (strong, nonatomic) IBOutlet UIView *commentsMenu;
- (IBAction)addTextComments:(id)sender;
- (IBAction)addVoiceComments:(id)sender;

/* 输入文字的视图 */
@property (strong, nonatomic) IBOutlet UIView *inputTextView;
@property (weak, nonatomic) IBOutlet UITextView *input_textView;
- (IBAction)done_inputText:(id)sender;
- (IBAction)cancel_inputText:(id)sender;

/* 录音的视图 */
@property (strong, nonatomic) Recorder *recorder; // 实现录音功能
@property (strong, nonatomic) IBOutlet UIView *recorderView;
@property (weak, nonatomic) IBOutlet UIButton *record_button;
@property (weak, nonatomic) IBOutlet UIButton *doneRecord_button;
@property (weak, nonatomic) IBOutlet UIButton *cancelRecord_button;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *recording_spinner;
@property (strong, nonatomic) MPVolumeView *volumeView;
- (IBAction)doRecording:(id)sender;
- (IBAction)done_record:(id)sender;
- (IBAction)cancel_record:(id)sender;


/// Add Strokes

/* 添加笔注 */
- (void)addStrokesToPDFView;

/* 删除本页的当前笔注 */
- (void)undoStrokeFromPDFView;

/* 删除本页所有笔注 */
- (void)deleteAllStrokesFromPDFView;

/* 完成添加笔注 */
- (void)finishAddingStrokesToPDFView;

/* 取消添加笔注 */
- (void)cancelAddingStrokesToPDFView;


/// Add Comments

@property (assign, nonatomic) NSInteger addTextType;
@property (assign, nonatomic) NSInteger addVoiceType;

/* 添加批注 */
- (void)addCommentsToPDFView;

/* 取消向pdf view添加批注 */
- (void)cancelAddingCommentsToPDFView;

/* 在视图中加载pdf标记 */
- (void)addAnnotationsInView;

/* 打开表格时添加新的批注 */
- (void)addNewTextComments;
- (void)editTextComments;
- (void)addNewVoiceComments;

/* 显示或隐藏页面上的按钮 */
- (void)showPDFButtonsInView;
- (void)hidePDFButtonsInView;

@end
