//
//  Stroke.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-28.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stroke : NSObject <NSCoding>

/*
 * 笔注的数据结构
 * previousDrawStrokes / currentDrawStrokes : (Array) [
 
 draw_Stroke0 : (Stroke) (
 draw_strokePoints : (Array)
 draw_strokeColor  : (UIColor)
 draw_strokeWidth  : (CGFloat)
 )
 
 draw_Stroke1 : (Stroke) (
 ...
 )
 
 * ]
 */

@property (strong, nonatomic) NSMutableArray *points;

@property (strong, nonatomic) UIColor *color;

@property (assign, nonatomic) CGFloat width;

- (id)initWithPoints:(NSMutableArray *)points Color:(UIColor *)color Width:(CGFloat)width;

@end
