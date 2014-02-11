//
//  RegistAccount.h
//  SCNUPaper
//
//  Created by Jymn_Chen on 14-2-11.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegistAccount : NSObject <NSCopying>

/* 获取RegistAccount单例 */
+ (instancetype)sharedInstance;

/* 检查输入的合法性，如果成功就发起注册的网络请求 */
- (void)registWithUsername:(NSString *)aUsername
                  Nickname:(NSString *)aNickname
                  Password:(NSString *)aPass
                   Confirm:(NSString *)confirmPass;

@end
