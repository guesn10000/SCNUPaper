//
//  UploadHandler.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-19.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "UploadHandler.h"
#import "AppDelegate.h"
#import "JCAlert.h"
#import "Constants.h"
#import "APIURL.h"
#import "FileCleaner.h"
#import "LatestViewController.h"
#import "MainPDFViewController.h"

@interface UploadHandler ()

@property (strong, nonatomic) NSMutableData *responseData_;

@end

@implementation UploadHandler

#pragma mark - Initialization

- (id)initWithNeedConvert:(BOOL)need {
    self = [super init];
    
    if (self) {
        self.needConvert = need;
    }
    
    return self;
}


#pragma mark - NSURLConnnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.responseData_ = [[NSMutableData alloc] initWithLength:0];
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSUInteger responseStatusCode = [httpResponse statusCode];
    if (responseStatusCode == REDIRECT_STATUS_CODE || responseStatusCode == REQUEST_SUCCEED_STATUS_CODE) {
//        NSLog(@"上传文件请求成功");
    }
    else {
        [JCAlert alertWithMessage:@"发送网络请求失败"];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (data) {
        [self.responseData_ appendData:data];
    }
}

/* 上传文件操作完成 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.needConvert) {
        if (self.responseData_.length == 0) {
            [JCAlert alertWithMessage:@"转换文件失败"];
        }
        else { // 转换成功
            AppDelegate *appDelegate = APPDELEGATE;
            LatestViewController *latestViewController = appDelegate.latestViewController;
            
            // 下载该pdf文件配套的zip包
            [latestViewController downloadZipFile];
            
            // 下载pdf文件
            [latestViewController downloadPDFFile];
        }
    }
    else {
        if (self.responseData_.length == 0) {
            [JCAlert alertWithMessage:@"上传数据失败"];
        }
        else {
            AppDelegate *appDelegate = APPDELEGATE;
            
            // 清理本地残留的zip文件
            [appDelegate.fileCleaner clearDocumentFiles];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [JCAlert alertWithMessage:@"上传文件出错" Error:error];
}

@end
