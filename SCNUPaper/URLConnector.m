//
//  URLConnector.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-19.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "URLConnector.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "JCAlert.h"
#import "JCFilePersistence.h"
#import "APIURL.h"
#import "Cookies.h"
#import "Reachability.h"
#import "LoginHandler.h"
#import "RegistHandler.h"
#import "UploadHandler.h"
#import "DownloadHandler.h"
#import "LatestViewController.h"

#pragma mark - Constants

static const CGFloat kLoginTimeoutInterval    = 10.0;
static const CGFloat kRegistTimeoutInterval   = 10.0;
static const CGFloat kUploadTimeoutInterval   = 30.0;
static const CGFloat kDownloadTimeoutInterval = 30.0;

@implementation URLConnector

#pragma mark - Singleton

+ (instancetype)sharedInstance {
    static URLConnector *connector = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        connector = [[super allocWithZone:NULL] init];
        connector.isLoginSucceed = NO;
    });
    
    return connector;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark - Initialization

- (id)init {
    self = [super init];
    
    if (self) {
        self.isLoginSucceed = NO;
    }
    
    return self;
}

#pragma mark - Network connections

+ (BOOL)canConnectToSCNUServer {
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:SCNU_SERVER_URL];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            [JCAlert alertWithMessage:@"无法连接到华师服务器，请检查您的网络"];
            break;
            
        case ReachableViaWiFi:
            break;
            
        case ReachableViaWWAN:
            break;
            
        default:
            isExistenceNetwork = NO;
            [JCAlert alertWithMessage:@"无法连接到华师服务器，请检查您的网络"];
            break;
    }
    
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    [appDelegate stopSpinnerAnimating];
    
    return isExistenceNetwork;
}

+ (BOOL)isOnline {
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    BOOL isExistenceNetwork = YES;
    NSString *testURLString = SHOW_DOWNLOADLIST_URL(appDelegate.cookies.username);
    Reachability *reach = [Reachability reachabilityWithHostName:testURLString];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            [JCAlert alertWithMessage:@"登陆超时，请重新登陆"];
            break;
            
        case ReachableViaWiFi:
            break;
            
        case ReachableViaWWAN:
            break;
            
        default:
            isExistenceNetwork = NO;
            [JCAlert alertWithMessage:@"登陆超时，请重新登陆"];
            break;
    }
    
    // 如果登陆超时，那么要求用户重新登陆
    if (!isExistenceNetwork) {
        [appDelegate.latestViewController quitLogin:nil];
    }
    
    return isExistenceNetwork;
}

#pragma mark - Login

- (void)loginWithUsername:(NSString *)username Password:(NSString *)password {
    if (![URLConnector canConnectToSCNUServer]) {
        return;
    }
    
    NSURL *loginURL = [NSURL URLWithString:LOGIN_URL];
    NSMutableURLRequest *requestForLogin = [[NSMutableURLRequest alloc] initWithURL:loginURL];
    [requestForLogin setHTTPMethod:@"POST"];
    [requestForLogin setTimeoutInterval:kLoginTimeoutInterval];
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

- (void)registWithUsername:(NSString *)aUsername
                  Nickname:(NSString *)aNickname
                  Password:(NSString *)aPass
                   Confirm:(NSString *)confirmPass
{
    if (![URLConnector canConnectToSCNUServer]) {
        return;
    }
    
    // 检查用户名
    if ([aUsername isEqualToString:@""]) {
        [JCAlert alertWithMessage:@"注册失败，您输入的用户名为空"];
        return;
    }
    
    // 检查昵称
    if ([aNickname isEqualToString:@""]) {
        [JCAlert alertWithMessage:@"注册失败，您输入的昵称为空"];
        return;
    }
    
    // 检查密码
    if ([aPass isEqualToString:@""]) {
        [JCAlert alertWithMessage:@"注册失败，您输入的密码为空"];
        return;
    }
    if ([confirmPass isEqualToString:@""]) {
        [JCAlert alertWithMessage:@"注册失败，请确认您输入的密码"];
        return;
    }
    
    // 检查两次输入的密码是否一致
    if (![aPass isEqualToString:confirmPass]) {
        [JCAlert alertWithMessage:@"注册失败，两次输入的密码不一致"];
        return;
    }
    
    // 通过合法性检查，发送网络注册请求
    NSURL *registURL = [NSURL URLWithString:REGISTER_URL];
    NSMutableURLRequest *requestForRegist = [[NSMutableURLRequest alloc] initWithURL:registURL];
    [requestForRegist setHTTPMethod:@"POST"];
    [requestForRegist setTimeoutInterval:kRegistTimeoutInterval];
    NSString *paramUsername = [NSString stringWithFormat:@"%@=%@", kUsername, aUsername];
    NSString *paramNickname = [NSString stringWithFormat:@"%@=%@", kNickname, aNickname];
    NSString *paramPassword = [NSString stringWithFormat:@"%@=%@", kPassword, aPass];
    NSString *parameters = [NSString stringWithFormat:@"%@&%@&%@", paramUsername, paramNickname, paramPassword];
    [requestForRegist setHTTPBody:[parameters dataUsingEncoding:NSUTF8StringEncoding]];
    
    RegistHandler *registHandler = [[RegistHandler alloc] initWithUsername:aUsername Nickname:aNickname Password:aPass];
    
    NSURLConnection *registConnection = [[NSURLConnection alloc] initWithRequest:requestForRegist delegate:registHandler];
    if (registConnection) {
        [registConnection start];
    }
}

#pragma mark - Upload Files

/* 上传文件到服务器
 *
 * 参数
 * filePath   : 文件路径
 * foldername : 文件夹名
 *
 */
- (void)uploadFileInPath:(NSString *)filepath toServerInFolder:(NSString *)foldername {
    if (![URLConnector isOnline]) {
        return;
    }
    
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    NSURL *uploadRequestURL = [NSURL URLWithString:UPLOAD_FILES_URL(appDelegate.cookies.username)];
    [self uploadFileInPath:filepath ToFolder:foldername ServerURL:uploadRequestURL NeedConvert:NO];
}

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
    [request setTimeoutInterval:kUploadTimeoutInterval];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@", charset, stringBoundary] forHTTPHeaderField:@"Content-Type"];
    
    
    //  2.对要POST的数据进行编码并设置HTTP请求的BODY
    // 开头的boundary:
    // --KhTmLbOuNdArY
    NSMutableData *postData = [[NSMutableData alloc] init];
    [postData appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // source参数对应的key和内容:
    // Content-disposition: form-data; name="folder"
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
    // content-disposition: form-data; name="data01"; filename="filename"
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
    UploadHandler   *uploadHanler = [[UploadHandler alloc] initWithNeedConvert:need];
    NSURLConnection *connection   = [[NSURLConnection alloc] initWithRequest:request delegate:uploadHanler];
    if (connection) {
        [connection start];
    }
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
    if (![URLConnector isOnline]) {
        return;
    }
    
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    NSURL *convertRequestURL = [NSURL URLWithString:CONVERT_DOC_TO_PDF_URL(appDelegate.cookies.username)];
    [self uploadFileInPath:filepath ToFolder:foldername ServerURL:convertRequestURL NeedConvert:YES];
}

#pragma mark - Show download list

- (NSArray *)getDownloadList {
    if (![URLConnector isOnline]) {
        return nil;
    }
    
    // 首先对url进行编码
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
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
    if (![URLConnector isOnline]) {
        return;
    }
    
    // 1.设置下载接口的URL
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    NSString *downloadURLString = DOWNLOAD_FILES_URL(appDelegate.cookies.username);
    downloadURLString = [downloadURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; // 对下载URL进行编码，字符集为utf-8，防止受到中文URL的影响
    NSURL *downloadURL = [NSURL URLWithString:downloadURLString];
    
    // 2.开始下载数据
    NSMutableURLRequest *requestForDownload = [[NSMutableURLRequest alloc] initWithURL:downloadURL];
    [requestForDownload setHTTPMethod:@"POST"];
    [requestForDownload setTimeoutInterval:kDownloadTimeoutInterval];
    NSString *paramFolderName = [NSString stringWithFormat:@"%@=%@", kFoldername, foldername];
    NSString *paramFileName   = [NSString stringWithFormat:@"%@=%@", kFilename, filename];
    NSString *parameters      = [NSString stringWithFormat:@"%@&%@", paramFolderName, paramFileName];
    [requestForDownload setHTTPBody:[parameters dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 3.建立连接
    DownloadHandler *downloadHandler    = [[DownloadHandler alloc] initWithFileType:fileType];
    NSURLConnection *downloadConnection = [[NSURLConnection alloc] initWithRequest:requestForDownload delegate:downloadHandler];
    if (downloadConnection) {
        [downloadConnection start];
    }
}

@end
