//
//  MyPDFSender.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-22.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyPDFSender : NSObject

/* 创建新的pdf文件，包含批改的涂鸦 */
- (void)createNewPDFFile;

/* 上传文件到服务器：同步 */
- (void)uploadFilesToServer;

/* 解压zip文件到指定路径 */
- (void)unzipFilesInPath:(NSString *)zipFilePath;

@end
