//
//  FileCleaner.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 14-1-16.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileCleaner : NSObject <NSCopying>

/* 获取FileCleaner单例 */
+ (instancetype)sharedInstance;

/* 删除残留在Documents目录下的suffix后缀的文件 */
- (void)clearFilesWithSuffix:(NSString *)suffix;

/* 删除文件夹Username/PureFileName/PDF */
- (void)clearFilesInPDFFolder:(NSString *)foldername;

- (void)clearFolder:(NSString *)foldername;

@end
