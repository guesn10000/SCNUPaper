//
//  AppDelegate.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-17.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "JCAlert.h"
#import "Cookies.h"
#import "URLConnector.h"
#import "JCFilePersistence.h"
#import "FileCleaner.h"
#import "AnnotationViews.h"
#import "LoginViewController.h"
#import "LatestViewController.h"
#import "MainPDFViewController.h"

@implementation AppDelegate

/* 设置基本的ViewController */
- (void)setViewControllers {
    // 1.重置ViewControllers
    self.rootViewController    = nil;
    self.latestViewController  = nil;
    self.mainPDFViewController = nil;
    
    // 2.重新指定root view controller，避免push view controller时navigation controller是空的或者栈中的视图为空
    self.rootViewController    = [[UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil]
                                  instantiateInitialViewController];
    
    self.loginViewController   = [[UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil]
                                  instantiateViewControllerWithIdentifier:LOGINVIEWCONTROLLER_ID];
    
    self.latestViewController  = [[UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil]
                                  instantiateViewControllerWithIdentifier:LATESTVIEWCONTROLLER_ID];
    
    self.mainPDFViewController = [[UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil]
                                  instantiateViewControllerWithIdentifier:MAINPDFVIEWCONTROLLER_ID];
    
    self.loginViewController.request_openFileURL = NO; // 程序刚开始时并不请求open file url
    
    self.rootViewController = [[UINavigationController alloc] initWithRootViewController:self.loginViewController];
    if (self.urlConnector.isLoginSucceed) {
        [self.loginViewController.navigationController pushViewController:self.latestViewController animated:YES];
    }
    else {
        
    }
    
    self.window.rootViewController = self.rootViewController;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if (url && [url isFileURL]) { // 如果是file url
        // 设置好ViewControllers
        [self setViewControllers];
        
        // 记录当前文件的URL
        self.fileURL = url;
        
        if (self.urlConnector.isLoginSucceed) {
            self.window.alpha = UNABLE_VIEW_ALPHA;
            [self.window setUserInteractionEnabled:NO];
            [self.latestViewController openFileURL]; // 已登陆，直接打开file url
        }
        else {
            [JCAlert alertWithMessage:@"您尚未登陆，请先登陆"];
            self.loginViewController.request_openFileURL = YES; // 打开open file url请求，作为登陆的后续动作
        }
        
        return YES;
    }
    else {
        [JCAlert alertWithMessage:@"打开文件失败，该文件的URL不是File URL"];
        return NO;
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 1.设置好ViewControllers
    [self setViewControllers];
    
    // 2.设置好全局的spinner，先不要add subview，否则会被后面的views遮住
    self.app_spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.app_spinner.hidesWhenStopped = YES;
    self.app_spinner.frame = CGRectMake(0.0, 0.0, 60.0, 60.0);
    self.app_spinner.center = self.window.center;
    
    // 3.初始化基本参数
    self.urlConnector = [[URLConnector alloc] init];
    self.filePersistence = [[JCFilePersistence alloc] init];
    self.fileCleaner = [[FileCleaner alloc] init];
    [self.fileCleaner clearDocumentFiles]; // 清除本地残留的zip, mp3, caf等文件
    self.annoViewsProvider = [[AnnotationViews alloc] init];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    if (self.fileCleaner) {
        [self.fileCleaner clearInboxFiles];
    }
}

@end
