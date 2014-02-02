//
//  AnnotationView.m
//  SCNUPaper
//
//  Created by Jymn_Chen on 14-1-21.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//

#import "AnnotationView.h"
#import "Constants.h"

@implementation AnnotationView

#pragma mark - Constants

static const NSInteger kNoneAnno   = 0;
static const NSInteger kTxtAnno    = 1;
static const NSInteger kVocAnno    = 2;
static const NSInteger kTxtVocAnno = 3;

static const CGFloat kAnnoSize = 30.0;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame AnnotationType:(NSUInteger)annoType {
    self = [super init];
    
    if (self) {
        UIImageView *textAnnoView = [[UIImageView alloc] initWithImage:TEXT_ANNOTATION_IMAGE];
        UIImageView *voiceAnnoView = [[UIImageView alloc] initWithImage:VOICE_ANNOTATION_IMAGE];
        
        if (annoType == kTxtAnno) {
            self.frame         = CGRectMake(frame.origin.x, frame.origin.y, kAnnoSize, kAnnoSize);
            textAnnoView.frame = CGRectMake(0.0, 0.0, kAnnoSize, kAnnoSize);
            [self addSubview:textAnnoView];
        }
        else if (annoType == kVocAnno) {
            self.frame          = CGRectMake(frame.origin.x, frame.origin.y, kAnnoSize, kAnnoSize);
            voiceAnnoView.frame = CGRectMake(0.0, 0.0, kAnnoSize, kAnnoSize);
            [self addSubview:voiceAnnoView];
        }
        else if (annoType == kTxtVocAnno) {
            self.frame          = CGRectMake(frame.origin.x, frame.origin.y, kAnnoSize * 2, kAnnoSize);
            textAnnoView.frame  = CGRectMake(0.0, 0.0, kAnnoSize, kAnnoSize);
            voiceAnnoView.frame = CGRectMake(kAnnoSize, 0.0, kAnnoSize, kAnnoSize);
            [self addSubview:textAnnoView];
            [self addSubview:voiceAnnoView];
        }
        else {
            
        }
    }
    
    return self;
}

@end
