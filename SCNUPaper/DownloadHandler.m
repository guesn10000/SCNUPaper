//
//  DownloadHandler.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-26.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "DownloadHandler.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "JCAlert.h"
#import "JCFilePersistence.h"
#import "APIURL.h"
#import "Cookies.h"
#import "LatestViewController.h"

@interface DownloadHandler ()

/* 下载的文件类型 */
@property (strong, nonatomic) NSString *fileType_;

/* 下载的数据 */
@property (strong, nonatomic) NSMutableData *download_data_;

@end

@implementation DownloadHandler

#pragma mark - Initialization

- (id)initWithFileType:(NSString *)fileType {
    self = [super init];
    
    if (self) {
        self.fileType_ = fileType;
    }
    
    return self;
}

#pragma mark - NSURLConnnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger responseStatusCode = [httpResponse statusCode];
    
    if (responseStatusCode == REDIRECT_STATUS_CODE || responseStatusCode == REQUEST_SUCCEED_STATUS_CODE) {
        self.download_data_ = [[NSMutableData alloc] initWithLength:0];
    }
    else if (responseStatusCode == FILE_NOT_FOUND_CODE) {
        self.download_data_ = nil;
        [JCAlert alertWithMessage:@"该文件不曾被老师修改过，找不到任何批改意见"];
        [[JCFilePersistence sharedInstance] removeFilesAtInboxFolder];
    }
    else {
        [JCAlert alertWithMessage:@"发送网络请求失败"];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (self.download_data_ && data) {
        [self.download_data_ appendData:data];
    }
}

/* 下载文件操作完成 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.download_data_ && self.download_data_.length > 0) {
        AppDelegate *appDelegate = [AppDelegate sharedDelegate];
        
        // 将下载的数据回传到LatestViewController
        if ([self.fileType_ isEqualToString:ZIP_SUFFIX]) {
            [appDelegate.latestViewController getDownload_ZIP_Data:self.download_data_];
        }
        else if ([self.fileType_ isEqualToString:PDF_SUFFIX]) {
            [appDelegate.latestViewController getDownload_PDF_Data:self.download_data_];
        }
        else {
            [[AppDelegate sharedDelegate] stopSpinnerAnimating];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.download_data_ = nil;
    [JCAlert alertWithMessage:@"下载文件出错，请检查您的网络" Error:error];
    [[AppDelegate sharedDelegate] stopSpinnerAnimating];
}

@end
