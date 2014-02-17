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

/* 是否登陆成功 */
@property (assign, nonatomic) BOOL isLoginSucceed;

/* 登陆和注册 */
- (void)loginWithUsername:(NSString *)username Password:(NSString *)password;
- (void)registerWithUsername:(NSString *)username Nickname:(NSString *)nickname Password:(NSString *)password;

/* 文件操作 */
- (void)uploadFileInPath:(NSString *)filepath toServerInFolder:(NSString *)foldername;
- (void)convertDocFileInPath:(NSString *)filepath toPDFFileInFolder:(NSString *)foldername;
- (NSArray *)getDownloadList;
- (void)downloadFile:(NSString *)filename Type:(NSString *)fileType FromServerInFolder:(NSString *)foldername;

@end
