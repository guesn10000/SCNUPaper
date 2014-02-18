//
//  AppDelegate.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-17.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class Cookies;
@class KeyGeneraton;
@class LoginViewController;
@class RegistViewController;
@class LatestViewController;
@class MainPDFViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

+ (instancetype)sharedDelegate;

@property (strong, nonatomic) UIWindow *window;

/* View Controllers */
@property (strong, nonatomic) UINavigationController *rootViewController;
@property (strong, nonatomic) LoginViewController    *loginViewController;
@property (strong, nonatomic) RegistViewController   *registViewController;
@property (strong, nonatomic) LatestViewController   *latestViewController;
@property (strong, nonatomic) MainPDFViewController  *mainPDFViewController;

/* 保存一些临时性数据，如用户名，密码，打开的文件名等 */
@property (strong, nonatomic) Cookies *cookies;

/* 产生和管理KeyNumber，用于管理PDF Page上的Annotation */
@property (strong, nonatomic) KeyGeneraton *keyGeneration;

/* 全局的spinner，用于指示正在进行数据处理 */
@property (strong, nonatomic) UIActivityIndicatorView *app_spinner;
- (void)startSpinnerAnimating;
- (void)stopSpinnerAnimating;

/* 要打开的文件的file url */
@property (strong, nonatomic) NSURL *fileURL;
@property (assign, nonatomic) BOOL fromInboxFile; // 文件是否来自Inbox文件夹

@end
