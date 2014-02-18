//
//  RegistHandler.m
//  SCNUPaper
//
//  Created by Jymn_Chen on 14-2-18.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//

#import "RegistHandler.h"
#import "AppDelegate.h"
#import "JCAlert.h"
#import "APIURL.h"
#import "RegistViewController.h"

@interface RegistHandler ()

@property (copy, nonatomic) NSString *username_;

@property (copy, nonatomic) NSString *nickname_;

@property (copy, nonatomic) NSString *password_;

@end

@implementation RegistHandler

- (id)initWithUsername:(NSString *)aUsername Nickname:(NSString *)aNickname Password:(NSString *)aPassword {
    self = [super init];
    
    if (self) {
        self.username_ = aUsername;
        self.nickname_ = aNickname;
        self.password_ = aPassword;
    }
    
    return self;
}

#pragma mark - NSURLConnection delegate

/* 登录是否成功 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger responseStatusCode = [httpResponse statusCode];
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
    if (responseStatusCode == REQUEST_SUCCEED_STATUS_CODE) {
        NSString *registSuccTips = [NSString stringWithFormat:@"注册成功。欢迎您，%@同学，请登陆", self.nickname_];
        [JCAlert alertWithMessage:registSuccTips];
        
        [appDelegate.registViewController.navigationController popToRootViewControllerAnimated:YES];
    }
    
    [appDelegate stopSpinnerAnimating];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [JCAlert alertWithMessage:@"注册失败，请检查您的网络" Error:error];
    [[AppDelegate sharedDelegate] stopSpinnerAnimating];
}

@end
