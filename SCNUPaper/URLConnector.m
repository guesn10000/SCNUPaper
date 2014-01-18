//
//  URLConnector.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-19.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "URLConnector.h"
#include "netdb.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "Cookies.h"
#import "JCFilePersistence.h"
#import "JCAlert.h"
#import "APIURL.h"
#import "LoginHandler.h"
#import "UploadHandler.h"
#import "DownloadHandler.h"
#import "AppDelegate.h"

@interface URLConnector ()

@end

@implementation URLConnector

#pragma mark - Initialization

- (id)init {
    self = [super init];
    
    if (self) {
        self.isLoginSucceed = NO;
    }
    
    return self;
}


#pragma mark - Network

/* 判断网络是否连接 */
+ (BOOL)isNetworkConnecting {
    // 创建零地址，0.0.0.0的地址表示查询本机的网络连接状态
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    /**
     *  SCNetworkReachabilityRef: 用来保存创建测试连接返回的引用
     *
     *  SCNetworkReachabilityCreateWithAddress: 根据传入的地址测试连接.
     *  第一个参数可以为NULL或kCFAllocatorDefault
     *  第二个参数为需要测试连接的IP地址,当为0.0.0.0时则可以查询本机的网络连接状态.
     *  同时返回一个引用必须在用完后释放.
     *  PS: SCNetworkReachabilityCreateWithName: 这个是根据传入的网址测试连接,
     *  第二个参数比如为"www.2cto.com",其他和上一个一样.
     *
     *  SCNetworkReachabilityGetFlags: 这个函数用来获得测试连接的状态,
     *  第一个参数为之前建立的测试连接的引用,
     *  第二个参数用来保存获得的状态,
     *  如果能获得状态则返回TRUE，否则返回FALSE
     *
     */
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flagsn");
        return NO;
    }
    
    /**
     *  kSCNetworkReachabilityFlagsReachable: 能够连接网络
     *  kSCNetworkReachabilityFlagsConnectionRequired: 能够连接网络,但是首先得建立连接过程
     *  kSCNetworkReachabilityFlagsIsWWAN: 判断是否通过蜂窝网覆盖的连接,
     *  比如EDGE,GPRS或者目前的3G.主要是区别通过WiFi的连接.
     *
     */
    BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
    return (isReachable && !needsConnection) ? YES : NO;
}


#pragma mark - Login

- (void)loginWithUsername:(NSString *)username Password:(NSString *)password {
    NSURL *loginURL = [NSURL URLWithString:LOGIN_URL];
    NSMutableURLRequest *requestForLogin = [[NSMutableURLRequest alloc] initWithURL:loginURL];
    [requestForLogin setHTTPMethod:@"POST"];
    NSString *paramUsername = [NSString stringWithFormat:@"%@=%@", kUsername, username];
    NSString *paramPassword = [NSString stringWithFormat:@"%@=%@", kPassword, password];
    NSString *parameters = [NSString stringWithFormat:@"%@&%@", paramUsername, paramPassword];
    [requestForLogin setHTTPBody:[parameters dataUsingEncoding:NSUTF8StringEncoding]];
    
    LoginHandler *loginHandler = [[LoginHandler alloc] initWithUsername:username Password:password];
    NSURLConnection *loginConnection = [[NSURLConnection alloc] initWithRequest:requestForLogin delegate:loginHandler];
    if (loginConnection) {
        [loginConnection start];
    }
}


#pragma mark - Register

- (void)registerWithUsername:(NSString *)username Nickname:(NSString *)nickname Password:(NSString *)password
{
}


#pragma mark - Upload Files

/*
 * 上传文件到服务器，如有需要则转换文件
 *
 * filePath   : 文件所在路径
 * foldername : 文件夹名
 * serverURL  : 服务器接口URL
 * need       : 是否需要转换，若为YES则要进行转换
 */
- (void)uploadFileInPath:(NSString *)filePath
                ToFolder:(NSString *)foldername
               ServerURL:(NSURL *)serverURL
             NeedConvert:(BOOL)need {
    NSString *filename = [filePath lastPathComponent];
    
    //  1.设置HTTP请求方式和请求头
    // 请求头的内容：
    // Content-type: multipart/form-data, charset=utf-8, boundary=KhTmLbOuNdArY
    NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    CFUUIDRef uuid = CFUUIDCreate(nil);
    NSString *uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuid));
    CFRelease(uuid);
    NSString *stringBoundary = [NSString stringWithFormat:@"0xKhTmLbOuNdArY-%@",uuidString];
    NSString *endItemBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:serverURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@", charset, stringBoundary] forHTTPHeaderField:@"Content-Type"];
    
    
    //  2.对要POST的数据进行编码并设置HTTP请求的BODY
    // 开头的boundary:
    // --KhTmLbOuNdArY
    NSMutableData *postData = [[NSMutableData alloc] init];
    [postData appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // source参数对应的key和内容:
    // Content-disposition: form-data; name="source"
    //
    // AppKey对应的内容
    NSString *kFolder = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"folder\"\r\n\r\n"];
    [postData appendData:[kFolder dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *vFolder = foldername;
    [postData appendData:[vFolder dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 分割字段内容的boundary:
    // --KhTmLbOuNdArY
    [postData appendData:[endItemBoundary dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    // image参数对应的key和内容:
    // content-disposition: form-data; name="file"; filename="filename"
    // Content-Type: file
    //
    // ... contents of filename.zip ...
    NSString *kFile = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"data01\"; filename=\"%@\"\r\n", filename];
    [postData appendData:[kFile dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *tFile = [NSString stringWithFormat:@"Content-Type: file\r\n\r\n"];
    [postData appendData:[tFile dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *vFileData = [[NSData alloc] initWithContentsOfFile:filePath];
    [postData appendData:vFileData];
    
    // 结尾的boundary
    // --KhTmLbOuNdArY--
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    // 3.设置HTTP的BODY和请求头中的Content-Length
    NSString *length = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    [request setValue:length forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    
    // 4.建立URL连接
    UploadHandler *uploadHanler = [[UploadHandler alloc] initWithNeedConvert:need];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:uploadHanler];
    if (connection) {
        [connection start];
    }
}

/* 上传文件到服务器
 *
 * 参数
 * filePath   : 文件路径
 * foldername : 文件夹名
 *
 */
- (void)uploadFileInPath:(NSString *)filepath toServerInFolder:(NSString *)foldername {
    AppDelegate *appDelegate = APPDELEGATE;
    NSURL *uploadRequestURL = [NSURL URLWithString:UPLOAD_FILES_URL(appDelegate.cookies.username)];
    [self uploadFileInPath:filepath ToFolder:foldername ServerURL:uploadRequestURL NeedConvert:NO];
}


#pragma mark - Convert doc to pdf

/* 上传文件到服务器，并执行转换操作
 *
 * 参数
 * filePath   : 文件路径
 * foldername : 文件夹名
 *
 */
- (void)convertDocFileInPath:(NSString *)filepath toPDFFileInFolder:(NSString *)foldername {
    AppDelegate *appDelegate = APPDELEGATE;
    NSURL *convertRequestURL = [NSURL URLWithString:CONVERT_DOC_TO_PDF_URL(appDelegate.cookies.username)];
    [self uploadFileInPath:filepath ToFolder:foldername ServerURL:convertRequestURL NeedConvert:YES];
}


#pragma mark - Show download list

- (NSArray *)getDownloadList {
    // 首先对url进行编码
    AppDelegate *appDelegate = APPDELEGATE;
    NSString *showDownloadListURLString = SHOW_DOWNLOADLIST_URL(appDelegate.cookies.username);
    showDownloadListURLString = [showDownloadListURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *showDownloadListURL = [NSURL URLWithString:showDownloadListURLString];
    
    NSData *listData = [[NSData alloc] initWithContentsOfURL:showDownloadListURL];
    NSError *error = nil;
    NSArray *downloadList = [NSJSONSerialization JSONObjectWithData:listData options:kNilOptions error:&error];
    if (error) {
        [JCAlert alertWithMessage:@"打开资源列表失败" Error:error];
    }
    else {
        NSLog(@"List : %@", downloadList);
    }
    
    return downloadList;
}


#pragma mark - Download Files 

/* 从服务器下载文件 
 *
 * filename   : 文件名
 * fileType   : 文件类型
 * foldername : 文件在服务器的文件夹名
 *
 */
- (void)downloadFile:(NSString *)filename Type:(NSString *)fileType FromServerInFolder:(NSString *)foldername {
    // 1.设置下载接口的URL
    AppDelegate *appDelegate = APPDELEGATE;
    NSString *downloadURLString = DOWNLOAD_FILES_URL(appDelegate.cookies.username);
    downloadURLString = [downloadURLString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]; // 对下载URL进行编码，字符集为utf-8，防止受到中文URL的影响
    NSURL *downloadURL = [NSURL URLWithString:downloadURLString];
    
    
    // 2.开始下载数据
    NSMutableURLRequest *requestForDownload = [[NSMutableURLRequest alloc] initWithURL:downloadURL];
    [requestForDownload setHTTPMethod:@"POST"];
    NSString *paramFolderName = [NSString stringWithFormat:@"%@=%@", kFoldername, foldername];
    NSString *paramFileName   = [NSString stringWithFormat:@"%@=%@", kFilename, filename];
    NSString *parameters      = [NSString stringWithFormat:@"%@&%@", paramFolderName, paramFileName];
    [requestForDownload setHTTPBody:[parameters dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    // 3.建立连接
    DownloadHandler *downloadHandler = [[DownloadHandler alloc] initWithFileType:fileType];
    NSURLConnection *downloadConnection = [[NSURLConnection alloc] initWithRequest:requestForDownload delegate:downloadHandler];
    if (downloadConnection) {
        [downloadConnection start];
    }
}

@end
