//
//  JCTimer.h
//  SCNUPaper
//
//  Created by Jymn_Chen on 14-1-22.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCTimer : NSObject

/* 获取当前时间对应的字符串 */
+ (NSString *)get_yyMMddhhmm_StringOfCurrentTime;
+ (NSString *)get_yyMMddhhmmss_StringOfCurrentTime;

@end
