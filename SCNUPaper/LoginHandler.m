//
//  LoginHandler.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-19.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "LoginHandler.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "APIURL.h"
#import "JCAlert.h"
#import "URLConnector.h"
#import "Cookies.h"
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
    if (response) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSInteger responseStatusCode = [httpResponse statusCode];
        
        AppDelegate *appDelegate = APPDELEGATE;
        URLConnector *urlConnector = [URLConnector sharedInstance];
        if (responseStatusCode == REQUEST_SUCCEED_STATUS_CODE) {
            // 设置好参数并保存用户的临时信息
            urlConnector.isLoginSucceed = YES;
            appDelegate.cookies = [[Cookies alloc] initWithUsername:self.temp_username_ Password:self.temp_password_];
            appDelegate.cookies.isTeacher = appDelegate.loginViewController.isTeacher;
            [appDelegate.cookies saveUserInfo];
            
            // push LatestViewController进栈
            [appDelegate.loginViewController.navigationController pushViewController:appDelegate.latestViewController animated:YES];
            
            if (appDelegate.loginViewController.request_openFileURL) { // 如果当前程序请求登陆后打开file url
                
                // 进入打开处理状态
                [appDelegate.window addSubview:appDelegate.app_spinner];
                [appDelegate.app_spinner startAnimating];
                
                // Open File URL
                [appDelegate.latestViewController openFileURL];
            }
        }
        else {
            [JCAlert alertWithMessage:@"登录失败，请检查网络是否连接"];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [JCAlert alertWithMessage:@"登陆失败，请检查您的网络" Error:error];
}

@end
