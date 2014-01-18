//
//  JCPoint.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-18.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "JCPoint.h"

@implementation JCPoint

+ (BOOL)isPoint:(CGPoint)point1 EqualsToPoint:(CGPoint)point2 {
    if (point1.x == point2.x && point1.y == point2.y) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
