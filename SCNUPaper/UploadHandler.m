//
//  UploadHandler.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-19.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "UploadHandler.h"
#import "AppDelegate.h"
#import "APIURL.h"
#import "LatestViewController.h"

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
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSUInteger responseStatusCode = [httpResponse statusCode];
    if (responseStatusCode == REDIRECT_STATUS_CODE || responseStatusCode == REQUEST_SUCCEED_STATUS_CODE) { // 上传文件请求成功
        self.responseData_ = [[NSMutableData alloc] initWithLength:0];
    }
    else {
        self.responseData_ = nil;
        [[AppDelegate sharedDelegate] stopSpinnerAnimating];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (self.responseData_ && data) {
        [self.responseData_ appendData:data];
    }
}

/* 上传文件操作完成 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (!self.responseData_ || self.responseData_.length == 0) {
        if (self.needConvert) {
            [JCAlert alertWithMessage:@"转换文件失败"];
        }
        else {
            [JCAlert alertWithMessage:@"上传数据失败"];
        }
        return;
    }
    else {
        AppDelegate *appDelegate = [AppDelegate sharedDelegate];
        if (self.needConvert) { // 转换成功
            LatestViewController *latestViewController = appDelegate.latestViewController;
            
            // 下载该pdf文件配套的zip包
            [latestViewController downloadZipFile];
            
            // 下载pdf文件，顺序不可互换
            [latestViewController downloadPDFFile];
        }
        else { // 上传文件成功
            // 清理本地tmp文件夹中残留的zip文件
            [[JCFilePersistence sharedInstance] removeFilesAtTmpFolder];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[JCFilePersistence sharedInstance] removeFilesAtTmpFolder];
    self.responseData_ = nil;
    [JCAlert alertWithMessage:@"上传文件失败，请检查您的网络" Error:error];
    [[AppDelegate sharedDelegate] stopSpinnerAnimating];
}

@end
