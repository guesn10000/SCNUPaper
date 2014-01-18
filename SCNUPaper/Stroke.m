//
//  Stroke.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-28.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "Stroke.h"

@implementation Stroke

static NSString *kPoints = @"Points";
static NSString *kColor  = @"Color";
static NSString *kWidth  = @"Width";

#pragma mark - NSCoding

/* 序列化解码 */
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        self.points = (NSMutableArray *)[aDecoder decodeObjectForKey:kPoints];
        
        NSMutableArray *color_values = (NSMutableArray *)[aDecoder decodeObjectForKey:kColor];
        NSString *red   = [color_values objectAtIndex:0];
        NSString *green = [color_values objectAtIndex:1];
        NSString *blue  = [color_values objectAtIndex:2];
        NSString *alpha = [color_values objectAtIndex:3];
        self.color = [UIColor colorWithRed:red.floatValue
                                     green:green.floatValue
                                      blue:blue.floatValue
                                     alpha:alpha.floatValue];
        
        self.width = [aDecoder decodeFloatForKey:kWidth];
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
    
    [aCoder encodeObject:self.points  forKey:kPoints];
    [aCoder encodeObject:color_values forKey:kColor];
    [aCoder encodeFloat:self.width    forKey:kWidth];
    
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
