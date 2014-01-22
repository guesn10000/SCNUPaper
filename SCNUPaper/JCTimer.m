//
//  JCTimer.m
//  SCNUPaper
//
//  Created by Jymn_Chen on 14-1-22.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//

#import "JCTimer.h"

@implementation JCTimer

+ (NSString *)get_yyMMddhhmm_StringOfCurrentTime {
    NSDateFormatter *fileNameFormatter = [[NSDateFormatter alloc] init];
    [fileNameFormatter setDateFormat:@"yy年MM月dd日hh时mm分"];
    return [fileNameFormatter stringFromDate:[NSDate date]];
}

+ (NSString *)get_yyMMddhhmmss_StringOfCurrentTime {
    NSDateFormatter *fileNameFormatter = [[NSDateFormatter alloc] init];
    [fileNameFormatter setDateFormat:@"yy年MM月dd日hh时mm分ss秒"];
    return [fileNameFormatter stringFromDate:[NSDate date]];
}

@end
