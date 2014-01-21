//
//  PDFScrollView.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-17.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "PDFScrollView.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "Cookies.h"
#import "KeyGeneraton.h"
#import "MyPDFPage.h"
#import "TiledPDFView.h"

@interface PDFScrollView ()

/* 用于展示缩放后的PDF内容 */
@property (strong, nonatomic) TiledPDFView *tiledPDFView_;

/* PDF页面的默认比例 */
@property (assign, nonatomic) CGFloat defaultScale_;

/* PDF页面的默认尺寸 */
@property (assign, nonatomic) CGSize  defaultSize_;

@end

@implementation PDFScrollView

#pragma mark - Constants

/* PDF ScrollView 缩放的最大和最小因子 */
const CGFloat kMaximumZoomScale = 2.0;
const CGFloat kMinimumZoomScale = 0.5;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame Document:(CGPDFDocumentRef)document PageIndex:(size_t)pageIndex {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        /* 设置基本参数 */
        
        [self basicSettings];
        
        // PDF Page
        self.myPDFPage     = [[MyPDFPage alloc] initWithDocument:document PageIndex:pageIndex];
        CGRect pageBoxRect = CGPDFPageGetBoxRect(self.myPDFPage.pdfPageRef, kCGPDFMediaBox);
        
        // 设置默认的页面比例
        self.defaultScale_ = MIN(self.frame.size.width  / pageBoxRect.size.width,
                                 self.frame.size.height / pageBoxRect.size.height);
        
        // 设置默认的页面尺寸
        pageBoxRect.size  = CGSizeMake(pageBoxRect.size.width  * self.defaultScale_,
                                       pageBoxRect.size.height * self.defaultScale_);
        self.defaultSize_ = pageBoxRect.size;
        
        // 设置iPhone到iPad视图之间的转换参数
        if (IS_IPAD) {
            self.iPhone_iPad_Scale = 1.0;
        }
        else {
            self.iPhone_iPad_Scale = MAX((CGFloat)pageBoxRect.size.width  / IPAD_SCREEN_WIDTH,
                                         (CGFloat)pageBoxRect.size.height / (IPAD_SCREEN_HEIGHT - STATUS_NAVIGATIONBAR_HEIGHT - TOOLBAR_HEIGHT)
                                         );
        }
        self.myPDFPage.convertScale = self.iPhone_iPad_Scale; // 顺序不可颠倒
        
        
        /* 添加TiledPDFView */
        
        self.tiledPDFView_ = [[TiledPDFView alloc] initWithFrame:pageBoxRect MyPDFPage:self.myPDFPage];
        self.tiledPDFView_.containerScrollView  = self;
        [self.tiledPDFView_ setDefaultScalesWithScale:self.defaultScale_ ConvertScale:self.iPhone_iPad_Scale];
        [self addSubview:self.tiledPDFView_];
        [self.tiledPDFView_ addAnnotationsInView];
    }
    
    return self;
}

/* 设置基本参数 */
- (void)basicSettings {
    self.decelerationRate               = UIScrollViewDecelerationRateFast;
    self.delegate                       = self;
    self.backgroundColor                = [UIColor lightGrayColor];
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator   = NO;
    self.scrollEnabled                  = YES;
    self.directionalLockEnabled         = NO;
    self.minimumZoomScale               = kMinimumZoomScale;
    self.maximumZoomScale               = kMaximumZoomScale;
    self.zoomScale                      = 1.0;
    self.bouncesZoom                    = NO;
    self.bounces                        = YES;
    self.userInteractionEnabled         = YES;
}

/* 对子视图布局使tiled pdf view居中 */
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize sizeOfBounds = self.frame.size;
    CGRect frameToCenter = self.tiledPDFView_.frame;
    
    if (frameToCenter.size.width < sizeOfBounds.width) {
        frameToCenter.origin.x = (sizeOfBounds.width - frameToCenter.size.width) / 2;
    }
    else {
        frameToCenter.origin.x = 0;
    }
    
    if (frameToCenter.size.height < sizeOfBounds.height) {
        frameToCenter.origin.y = (sizeOfBounds.height - frameToCenter.size.height) / 2;
    }
    else {
        frameToCenter.origin.y = 0.0;
    }
    
    self.tiledPDFView_.frame = frameToCenter;
    self.tiledPDFView_.contentScaleFactor = 1.0;
}

- (void)refreshTiledPDFView {
    [self.myPDFPage reloadPDFPage];
    [self.tiledPDFView_ addAnnotationsInView];
    [self.tiledPDFView_ setNeedsDisplay];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.tiledPDFView_;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
}

/* 锁定PDFScrollView：不可滚动，不可缩放 */
- (void)lockPDFScrollView {
    self.scrollEnabled    = NO;                    // 当前页面不可滚动
    self.minimumZoomScale = self.maximumZoomScale; // 锁定页面不可缩放
}

/* 解除PDFScrollView的锁定：允许滚动和缩放 */
- (void)unlockPDFScrollView {
    self.scrollEnabled    = YES;
    self.maximumZoomScale = kMaximumZoomScale;
    self.minimumZoomScale = kMinimumZoomScale;
}


#pragma mark - Add Strokes

/* 本视图开始添加笔注 */
- (void)calloutPDFView_addStrokes {
    // 锁定当前视图的滑动和缩放
    [self lockPDFScrollView];
    
    // 当前的tiled pdf view开始添加strokes
    [self.tiledPDFView_ addStrokesToPDFView];
}

/* 撤销本页添加的笔注 */
- (void)calloutPDFView_undoStroke {
    // 通知当前的tiled pdf view
    [self.tiledPDFView_ undoStrokeFromPDFView];
}

/* 删除本页所有笔注 */
- (void)calloutPDFView_deleteAllStrokes {
    // 通知当前的tiled pdf view
    [self.tiledPDFView_ deleteAllStrokesFromPDFView];
}

/* 本视图完成添加笔注 */
- (void)calloutPDFView_finishAddingStrokes {
    // 解除当前视图的锁定
    [self unlockPDFScrollView];
    
    // 通知当前的tiled pdf view
    [self.tiledPDFView_ finishAddingStrokesToPDFView];
}

/* 本视图取消添加笔注 */
- (void)calloutPDFView_cancelAddingStrokes {
    // 解除当前视图的锁定
    [self unlockPDFScrollView];
    
    // 通知当前的tiled pdf view
    [self.tiledPDFView_ cancelAddingStrokesToPDFView];
}


#pragma mark - Add Comments

- (void)calloutPDFView_addComments {
    [self lockPDFScrollView];
    [self.tiledPDFView_ addCommentsToPDFView];
}

- (void)calloutPDFView_cancelAddingComments {
    [self unlockPDFScrollView];
    [self.tiledPDFView_ cancelAddingCommentsToPDFView];
}

#pragma mark - New Comments

- (void)calloutPDFView_addNewTextComments {
    [self lockPDFScrollView];
    [self.tiledPDFView_ addNewTextComments];
}

- (void)calloutPDFView_editTextComments {
    [self lockPDFScrollView];
    [self.tiledPDFView_ editTextComments];
}

- (void)calloutPDFView_addNewVoiceComments {
    [self lockPDFScrollView];
    [self.tiledPDFView_ addNewVoiceComments];
}

@end
