//
//  FileCleaner.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 14-1-16.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileCleaner : NSObject

/* 清除Document/Inbox目录下的所有文件 */
- (void)clearInboxFiles;

/* 删除残留在Documents目录下的suffix后缀的文件 */
- (void)clearFilesWithSuffix:(NSString *)suffix;

/* 删除残留在Documents目录下的zip, mp3, caf等文件，以及Inbox目录中的doc, ppt文件（错误处理） */
- (void)clearDocumentFiles;

/* 删除文件夹Username/PureFileName/PDF */
- (void)clearFilesInPDFFolder:(NSString *)foldername;

@end
