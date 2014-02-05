//
//  MyPDFCreator.h
//  SCNUPaper
//
//  Created by Jymn_Chen on 14-1-19.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyPDFCreator : NSObject <NSCopying>

/* 获取MyPDFCreator单例 */
+ (instancetype)sharedInstance;

/* 创建新的pdf文件，包含批改的涂鸦 */
- (void)createNewPDFFile;

/* 上传文件到服务器：同步 */
- (void)uploadFilesToServer;

/* 解压zip文件到指定路径 */
- (void)unzipFilesInPath:(NSString *)zipFilePath;

@end
