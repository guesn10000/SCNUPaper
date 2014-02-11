//
//  RegistAccount.m
//  SCNUPaper
//
//  Created by Jymn_Chen on 14-2-11.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//

#import "RegistAccount.h"
#import "JCAlert.h"

@implementation RegistAccount

#pragma mark - Singleton

+ (instancetype)sharedInstance {
    static RegistAccount *registAccount = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        registAccount = [[super allocWithZone:NULL] init];
    });
    
    return registAccount;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark - Regist Action

- (void)registWithUsername:(NSString *)aUsername
                  Nickname:(NSString *)aNickname
                  Password:(NSString *)aPass
                   Confirm:(NSString *)confirmPass
{
    // 检查用户名
    if ([aUsername isEqualToString:@""]) {
        [JCAlert alertWithMessage:@"注册失败，您输入的用户名为空"];
        return;
    }
    
    // 检查昵称
    if ([aNickname isEqualToString:@""]) {
        [JCAlert alertWithMessage:@"注册失败，您输入的昵称为空"];
        return;
    }
    
    // 检查密码
    if ([aPass isEqualToString:@""]) {
        [JCAlert alertWithMessage:@"注册失败，您输入的密码为空"];
        return;
    }
    if ([confirmPass isEqualToString:@""]) {
        [JCAlert alertWithMessage:@"注册失败，请确认您输入的密码"];
        return;
    }
    
    // 检查两次输入的密码是否一致
    if (![aPass isEqualToString:confirmPass]) {
        [JCAlert alertWithMessage:@"注册失败，两次输入的密码不一致"];
        return;
    }
    
    // 通过合法性检查，发送网络注册请求
    
}

@end
