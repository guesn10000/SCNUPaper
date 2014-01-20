//
//  CommentStroke.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-12-5.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "CommentStroke.h"

@implementation CommentStroke

#pragma mark - Constants

static NSString *kStrkFrame    = @"ButtonFrame";
static NSString *kStrkBtnKey   = @"ButtonKey";
static NSString *kHasTextAnno  = @"HasTextAnnotation";
static NSString *kHasVoiceAnno = @"HasVoiceAnnotation";

static NSInteger kTextType  = 3;
static NSInteger kVoiceType = 4;

#pragma mark - NSCoding Delegate

/* 序列化解码 */
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        self.frame              = (NSString *)[aDecoder decodeObjectForKey:kStrkFrame];
        self.buttonKey          = (NSInteger)[aDecoder decodeIntegerForKey:kStrkBtnKey];
        self.hasTextAnnotation  = (BOOL)[aDecoder decodeBoolForKey:kHasTextAnno];
        self.hasVoiceAnnotation = (BOOL)[aDecoder decodeBoolForKey:kHasVoiceAnno];
    }
    
    return self;
}

/* 序列化编码 */
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.frame            forKey:kStrkFrame];
    [aCoder encodeInteger:self.buttonKey       forKey:kStrkBtnKey];
    [aCoder encodeBool:self.hasTextAnnotation  forKey:kHasTextAnno];
    [aCoder encodeBool:self.hasVoiceAnnotation forKey:kHasVoiceAnno];
}

#pragma mark - Initialization

- (id)initWithFrame:(NSString *)frame Key:(NSInteger)key {
    self = [super init];
    
    if (self) {
        self.frame = frame;
        self.buttonKey = key;
        self.hasTextAnnotation  = NO;
        self.hasVoiceAnnotation = NO;
    }
    
    return self;
}

- (void)setAnnotationType:(NSInteger)type {
    if (type == kTextType) {
        self.hasTextAnnotation = YES;
    }
    else if (type == kVoiceType) {
        self.hasVoiceAnnotation = YES;
    }
    else {
        return;
    }
}

@end
