//
//  PDFScrollView.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-17.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class MainPDFViewController;
@class MyPDFPage;

@interface PDFScrollView : UIScrollView <UIScrollViewDelegate>

/* 初始化 */
- (id)initWithFrame:(CGRect)frame Document:(CGPDFDocumentRef)document PageIndex:(size_t)pageIndex;

@property (strong, nonatomic) MyPDFPage *myPDFPage;

/* 当前页面的缩放倍数 */
@property (assign, nonatomic) CGFloat pageScale;

/* iPhone视图到iPad视图之间的转换参数 */
@property (assign, nonatomic) CGFloat iPhone_iPad_Scale;

- (void)lockPDFScrollView;
- (void)unlockPDFScrollView;

///////////////////////////////////////////////////////////////////////////


/// Add Strokes

/* 添加笔注 */
- (void)calloutPDFView_addStrokes;

/* 撤销当前的笔注 */
- (void)calloutPDFView_undoStroke;

/* 删除所有笔注 */
- (void)calloutPDFView_deleteAllStrokes;

/* 完成添加笔注 */
- (void)calloutPDFView_finishAddingStrokes;

/* 取消添加笔注 */
- (void)calloutPDFView_cancelAddingStrokes;

///////////////////////////////////////////////////////////////////////////


/// Add Comments

/* 添加批注 */
- (void)calloutPDFView_addComments;

/* 取消添加批注 */
- (void)calloutPDFView_cancelAddingComments;


- (void)calloutPDFView_addNewTextComments;
- (void)calloutPDFView_addNewVoiceComments;
- (void)calloutPDFView_editTextComments;

- (void)refreshTiledPDFView;

@end
