//
//  JCLog.h
//  JuliaCoreFramework
//
//  Created by Jymn_Chen on 13-11-14.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCLog : NSObject

+ (void)logoutPartingLine;

+ (void)logoutImplementFileName:(NSString *)imFileName Message:(NSString *)message;

+ (void)logoutCGRect:(CGRect)rect;
+ (void)logoutCGRect:(CGRect)rect Named:(NSString *)name;

+ (void)logoutCGPoint:(CGPoint)point;
+ (void)logoutCGPoint:(CGPoint)point Named:(NSString *)name;

+ (void)logoutCGSize:(CGSize)size;
+ (void)logoutCGSize:(CGSize)size Named:(NSString *)name;

+ (void)logoutNSRange:(NSRange)range;
+ (void)logoutNSRange:(NSRange)range Named:(NSString *)name;

@end
