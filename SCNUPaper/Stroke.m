//
//  Stroke.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-28.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "Stroke.h"

#pragma mark - Constants

static NSString * const kStrokePoints = @"StrokePoints";
static NSString * const kStrokeColor  = @"StrokeColor";
static NSString * const kStrokeWidth  = @"StrokeWidth";

@implementation Stroke

#pragma mark - NSCoding

/* 序列化解码 */
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        self.points = (NSMutableArray *)[aDecoder decodeObjectForKey:kStrokePoints];
        
        NSMutableArray *color_values = (NSMutableArray *)[aDecoder decodeObjectForKey:kStrokeColor];
        NSString *red   = [color_values objectAtIndex:0];
        NSString *green = [color_values objectAtIndex:1];
        NSString *blue  = [color_values objectAtIndex:2];
        NSString *alpha = [color_values objectAtIndex:3];
        self.color = [UIColor colorWithRed:red.floatValue
                                     green:green.floatValue
                                      blue:blue.floatValue
                                     alpha:alpha.floatValue];
        
        self.width = [aDecoder decodeFloatForKey:kStrokeWidth];
    }
    
    return self;
}

/* 序列化编码 */
- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    NSMutableArray *color_values = [[NSMutableArray alloc] init];
    
    int numComponents = CGColorGetNumberOfComponents(self.color.CGColor);
    if (numComponents == 4) {
        const CGFloat *components = CGColorGetComponents(self.color.CGColor);
        [color_values addObject:[NSString stringWithFormat:@"%f", components[0]]];
        [color_values addObject:[NSString stringWithFormat:@"%f", components[1]]];
        [color_values addObject:[NSString stringWithFormat:@"%f", components[2]]];
        [color_values addObject:[NSString stringWithFormat:@"%f", components[3]]];
    }
    
    [aCoder encodeObject:self.points  forKey:kStrokePoints];
    [aCoder encodeObject:color_values forKey:kStrokeColor];
    [aCoder encodeFloat:self.width    forKey:kStrokeWidth];
    
}


#pragma mark - Initialization

- (id)initWithPoints:(NSMutableArray *)points Color:(UIColor *)color Width:(CGFloat)width {
    self = [super init];
    
    if (self) {
        self.points = [[NSMutableArray alloc] initWithArray:[points mutableCopy]];
        self.color  = [[UIColor alloc] initWithCGColor:color.CGColor];
        self.width  = width;
    }
    
    return self;
}

@end
