//
//  AnnotationViews.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 14-1-18.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//

#import "AnnotationViews.h"

@interface AnnotationViews ()

@property (strong, nonatomic) UIView *textAnnoView_;

@property (strong, nonatomic) UIView *voiceAnnoView_;

@property (strong, nonatomic) UIView *allAnnoView_;

@end

@implementation AnnotationViews

#pragma mark - Constants

const NSInteger kNoneAnno   = 0;
const NSInteger kTxtAnno    = 1;
const NSInteger kVocAnno    = 2;
const NSInteger kTxtVocAnno = 3;

#pragma mark - Initialization

- (id)init {
    self = [super init];
    
    if (self) {
        CGRect rect0 = CGRectMake(0.0, 0.0, 60.0, 30.0);
        CGRect rect1 = CGRectMake(0.0, 0.0, 30.0, 30.0);
        CGRect rect2 = CGRectMake(30.0, 0.0, 30.0, 30.0);
        
        UIImage *textImage  = [UIImage imageNamed:@"addText.png"];
        UIImage *voiceImage = [UIImage imageNamed:@"addVoice.jpg"];
        
        self.textAnnoView_ = [[UIView alloc] initWithFrame:rect1];
        UIImageView *textView = [[UIImageView alloc] initWithImage:textImage];
        textView.frame = rect1;
        [self.textAnnoView_ addSubview:textView];
        
        self.voiceAnnoView_ = [[UIView alloc] initWithFrame:rect1];
        UIImageView *voiceView = [[UIImageView alloc] initWithImage:voiceImage];
        voiceView.frame = rect1;
        [self.voiceAnnoView_ addSubview:voiceView];
        
        self.allAnnoView_ = [[UIView alloc] initWithFrame:rect0];
        UIImageView *textView2 = [[UIImageView alloc] initWithImage:textImage];
        UIImageView *voiceView2 = [[UIImageView alloc] initWithImage:voiceImage];
        textView2.frame = rect1;
        voiceView2.frame = rect2;
        [self.allAnnoView_ addSubview:textView2];
        [self.allAnnoView_ addSubview:voiceView2];
    }
    
    return self;
}

- (UIView *)getAnnotationViewWithType:(NSInteger)type {
    switch (type) {
        case kTxtAnno:
            return self.textAnnoView_;
            
        case kVocAnno:
            return self.voiceAnnoView_;
            
        case kTxtVocAnno:
            return self.allAnnoView_;
            
        default:
            return [[UIView alloc] init];
    }
}

@end
