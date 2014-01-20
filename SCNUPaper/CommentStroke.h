//
//  CommentStroke.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-12-5.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentStroke : NSObject <NSCoding>

/* 文字上的按钮的frame */
@property (strong, nonatomic) NSString *frame;

/* 标记的key */
@property (assign, nonatomic) NSInteger buttonKey;

/* 是否有文字标记 */
@property (assign, nonatomic) BOOL hasTextAnnotation;

/* 是否有音频标记 */
@property (assign, nonatomic) BOOL hasVoiceAnnotation;

/* 初始化 */
- (id)initWithFrame:(NSString *)frame Key:(NSInteger)key;

- (void)setAnnotationType:(NSInteger)type;

@end
