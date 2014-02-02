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

static NSString * const kStrkFrame    = @"ButtonFrame";
static NSString * const kStrkBtnKey   = @"ButtonKey";
static NSString * const kHasTextAnno  = @"HasTextAnnotation";
static NSString * const kHasVoiceAnno = @"HasVoiceAnnotation";

static const NSInteger kTextType  = 3; // 这里的kTextType的值必须等于enum EditType 的枚举值kAddTextComments
static const NSInteger kVoiceType = 4; // 这里的kTextType的值必须等于enum EditType 的枚举值kAddVoiceComments

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
