//
//  FileCleaner.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 14-1-16.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//

#import "FileCleaner.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "JCFilePersistence.h"
#import "Cookies.h"

@implementation FileCleaner

#pragma mark - Clear Files

/* 清除Document/Inbox目录下的所有文件 */
- (void)clearInboxFiles {
    JCFilePersistence *filePersistence = [[JCFilePersistence alloc] init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 清空inbox中的文件
    NSString *inboxPath = [filePersistence getDirectoryInDocumentWithName:INBOX_FOLDER_NAME];
    NSArray *filesInBox = [fileManager contentsOfDirectoryAtPath:inboxPath error:NULL];
    if (filesInBox && filesInBox.count > 0) {
        for (NSString *file in filesInBox) {
            NSString *filePath = [inboxPath stringByAppendingString:file];
            if ([fileManager fileExistsAtPath:filePath isDirectory:NO]) {
                [fileManager removeItemAtPath:inboxPath error:NULL];
            }
        }
    }
    else {
//        NSLog(@"Inbox文件夹中没有文件");
    }
}

/* 删除残留在Documents目录下的suffix后缀的文件 */
- (void)clearFilesWithSuffix:(NSString *)suffix {
    JCFilePersistence *filePersistence = [[JCFilePersistence alloc] init];
    NSString *documentPath = [filePersistence getDirectoryOfDocumentFolder];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *filesInFolder = [fileManager contentsOfDirectoryAtPath:documentPath error:NULL];
    
    // 清空Documents当前目录下的文件
    if (filesInFolder && filesInFolder.count > 0) {
        for (NSString *file in filesInFolder) {
            if ([file hasSuffix:suffix]) {
                NSString *filePath = [filePersistence getDirectoryOfDocumentFileWithName:file];
                if ([fileManager fileExistsAtPath:filePath]) {
                    [fileManager removeItemAtPath:filePath error:nil];
                }
            }
        }
    }
    else {
//        NSLog(@"Document中没有zip文件");
    }
}

/* 删除残留在Documents目录下的zip, mp3, caf等文件，以及Inbox目录中的doc, ppt文件（错误处理） */
- (void)clearDocumentFiles {
    [self clearFilesWithSuffix:ZIP_SUFFIX];
    [self clearFilesWithSuffix:MP3_SUFFIX];
    [self clearFilesWithSuffix:CAF_SUFFIX];
    
    // 清空inbox中的文件
    [self clearInboxFiles];
}

/* 删除文件夹Username/PureFileName/PDF */
- (void)clearFilesInPDFFolder:(NSString *)foldername {
    AppDelegate *appDelegate = APPDELEGATE;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *folderPath = [NSString stringWithFormat:@"%@/%@/%@", appDelegate.cookies.username, foldername, PDF_FOLDER_NAME];
    folderPath = [appDelegate.filePersistence getDirectoryInDocumentWithName:folderPath];
    
    if ([fileManager fileExistsAtPath:folderPath isDirectory:NO]) {
        [fileManager removeItemAtPath:folderPath error:NULL];
    }
}

@end
