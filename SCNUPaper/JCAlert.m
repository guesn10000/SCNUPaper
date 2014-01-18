//
//  JCAlert.m
//  JuliaCoreFramework
//
//  Created by Jymn_Chen on 13-11-17.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "JCAlert.h"

@implementation JCAlert

+ (void)alertWithMessage:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注意" message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

+ (void)alertWithError:(NSError *)error {
    NSString *errorInfo = [error localizedDescription];
    [self alertWithMessage:errorInfo];
}

+ (void)alertWithMessage:(NSString *)message Error:(NSError *)error {
    NSString *errorInfo = [error localizedDescription];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message message:errorInfo
                                                       delegate:nil
                                              cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

@end
