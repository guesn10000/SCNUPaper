//
//  URLConnector.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-19.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

@class JCFilePersistence;

@interface URLConnector : NSObject 

/* 判断当前网络是否可用 */
+ (BOOL)isNetworkConnecting;

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
