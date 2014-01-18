//
//  JCLog.m
//  JuliaCoreFramework
//
//  Created by Jymn_Chen on 13-11-14.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "JCLog.h"

@implementation JCLog

+ (void)logoutPartingLine {
    NSLog(@"---------- ----------");
}

+ (void)logoutImplementFileName:(NSString *)imFileName Message:(NSString *)message {
    NSLog(@"%@ ---- %@", imFileName, message);
}

+ (void)logoutCGRect:(CGRect)rect {
    [self logoutCGRect:rect Named:@"Rect"];
}

+ (void)logoutCGRect:(CGRect)rect Named:(NSString *)name {
    NSLog(@"%@:", name);
    NSLog(@"x = %f", rect.origin.x);
    NSLog(@"y = %f", rect.origin.y);
    NSLog(@"width = %f", rect.size.width);
    NSLog(@"height = %f", rect.size.height);
    [self logoutPartingLine];
}

+ (void)logoutCGPoint:(CGPoint)point {
    [self logoutCGPoint:point Named:@"Point"];
}

+ (void)logoutCGPoint:(CGPoint)point Named:(NSString *)name {
    NSLog(@"%@", name);
    NSLog(@"x = %f", point.x);
    NSLog(@"y = %f", point.y);
    [self logoutPartingLine];
}

+ (void)logoutCGSize:(CGSize)size {
    [self logoutCGSize:size Named:@"size"];
}

+ (void)logoutCGSize:(CGSize)size Named:(NSString *)name {
    NSLog(@"%@:", name);
    NSLog(@"width = %f", size.width);
    NSLog(@"height = %f", size.height);
    [self logoutPartingLine];
}

+ (void)logoutNSRange:(NSRange)range {
    [self logoutNSRange:range Named:@"Range"];
    [self logoutPartingLine];
}

+ (void)logoutNSRange:(NSRange)range Named:(NSString *)name {
    NSLog(@"%@:", name);
    NSLog(@"location = %d", range.location);
    NSLog(@"length = %d", range.length);
    [self logoutPartingLine];
}

@end
