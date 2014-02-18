//
//  LoginHandler.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-19.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "LoginHandler.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "JCAlert.h"
#import "APIURL.h"
#import "Cookies.h"
#import "URLConnector.h"
#import "LoginViewController.h"
#import "LatestViewController.h"

@interface LoginHandler ()

@property (strong, nonatomic) NSString *temp_username_;
@property (strong, nonatomic) NSString *temp_password_;

@end

@implementation LoginHandler

#pragma mark - Initialization

- (id)initWithUsername:(NSString *)username Password:(NSString *)password {
    self = [super init];
    
    if (self) {
        self.temp_username_ = username;
        self.temp_password_ = password;
    }
    
    return self;
}


#pragma mark - NSURLConnection delegate

/* 登录是否成功 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger responseStatusCode = [httpResponse statusCode];
    
    if (responseStatusCode == REQUEST_SUCCEED_STATUS_CODE) {
        AppDelegate *appDelegate   = [AppDelegate sharedDelegate];
        URLConnector *urlConnector = [URLConnector sharedInstance];
        
        // 设置好参数并保存用户的临时信息
        urlConnector.isLoginSucceed = YES;
        appDelegate.cookies = [[Cookies alloc] initWithUsername:self.temp_username_ Password:self.temp_password_];
        [appDelegate.cookies saveUserInfo];
        
        // push LatestViewController进栈
        [appDelegate.loginViewController.navigationController pushViewController:appDelegate.latestViewController animated:YES];
        
        if (appDelegate.loginViewController.request_openFileURL) { // 如果当前程序请求登陆后打开file url
            [appDelegate.latestViewController openFileURL];
        }
        else {
            [appDelegate stopSpinnerAnimating];
        }
    }
    else {
        [[AppDelegate sharedDelegate] stopSpinnerAnimating];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [JCAlert alertWithMessage:@"登陆失败，请检查您的网络" Error:error];
    [[AppDelegate sharedDelegate] stopSpinnerAnimating];
}

@end
