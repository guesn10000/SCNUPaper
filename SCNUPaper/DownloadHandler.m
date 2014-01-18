//
//  DownloadHandler.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-26.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "DownloadHandler.h"
#import "APIURL.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "Cookies.h"
#import "JCAlert.h"
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
    self.download_data_ = [[NSMutableData alloc] initWithLength:0];
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSUInteger responseStatusCode = [httpResponse statusCode];
    if (responseStatusCode == REDIRECT_STATUS_CODE || responseStatusCode == REQUEST_SUCCEED_STATUS_CODE) {
//        NSLog(@"发送下载文件请求成功");
    }
    else {
        [JCAlert alertWithMessage:@"发送网络请求失败"];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (data) {
        [self.download_data_ appendData:data];
    }
}

/* 下载文件操作完成 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    AppDelegate *appDelegate = APPDELEGATE;
    
    if (self.download_data_.length == 0) {
        if ([self.fileType_ isEqualToString:ZIP_SUFFIX]) {
//            NSLog(@"该文件尚未上传过，现在下载pdf文件");
//            [appDelegate.latestViewController downloadPDFFile];
        }
        else {
            [JCAlert alertWithMessage:@"下载文件失败"];
        }
    }
    else {
//        NSLog(@"下载文件成功");
        // 将下载的数据回传到LatestViewController
        if ([self.fileType_ isEqualToString:ZIP_SUFFIX]) {
            [appDelegate.latestViewController getDownload_ZIP_Data:self.download_data_];
        }
        else if ([self.fileType_ isEqualToString:PDF_SUFFIX]) {
            [appDelegate.latestViewController getDownload_PDF_Data:self.download_data_];
        }
        else {
            [JCAlert alertWithMessage:@"从服务器下载数据失败"];
        }
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [JCAlert alertWithMessage:@"下载文件出错" Error:error];
}

@end
