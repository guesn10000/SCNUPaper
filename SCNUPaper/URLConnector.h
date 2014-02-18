//
//  URLConnector.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-19.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JCFilePersistence;

@interface URLConnector : NSObject <NSCopying>

/* 获取URLConnector单例 */
+ (instancetype)sharedInstance;

/* 判断是否能够连接到SCNU服务器上 */
+ (BOOL)canConnectToSCNUServer;

/* 判断当前用户是否在线 */
+ (BOOL)isOnline;

/* 是否登陆成功 */
@property (assign, nonatomic) BOOL isLoginSucceed;

/* 登陆到服务器 */
- (void)loginWithUsername:(NSString *)username Password:(NSString *)password;

/* 检查输入的合法性，如果成功就发起注册的网络请求 */
- (void)registWithUsername:(NSString *)aUsername
                  Nickname:(NSString *)aNickname
                  Password:(NSString *)aPass
                   Confirm:(NSString *)confirmPass;

/* 上传文件到服务器 */
- (void)uploadFileInPath:(NSString *)filepath toServerInFolder:(NSString *)foldername;

/* 上传pdf文件到服务器并进行转换 */
- (void)convertDocFileInPath:(NSString *)filepath toPDFFileInFolder:(NSString *)foldername;

/* 获取下载文件列表 */
- (NSArray *)getDownloadList;

/* 从服务器下载文件 */
- (void)downloadFile:(NSString *)filename Type:(NSString *)fileType FromServerInFolder:(NSString *)foldername;

@end
