//
//  Stroke.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-28.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stroke : NSObject <NSCoding>

@property (strong, nonatomic) NSMutableArray *points;

@property (strong, nonatomic) UIColor *color;

@property (assign, nonatomic) CGFloat width;

- (id)initWithPoints:(NSMutableArray *)points Color:(UIColor *)color Width:(CGFloat)width;

@end
