//
//  FileCleaner.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 14-1-16.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//

#import "FileCleaner.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "JCFilePersistence.h"
#import "Cookies.h"

@implementation FileCleaner

#pragma mark - Singleton

+ (instancetype)sharedInstance {
    static FileCleaner *cleaner = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        cleaner = [[super allocWithZone:NULL] init];
    });
    
    return cleaner;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark - Clear Files

/* 删除残留在Documents目录下的suffix后缀的文件 */
- (void)clearFilesWithSuffix:(NSString *)suffix {
    JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
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

/* 删除文件夹Username/PureFileName/PDF */
- (void)clearFilesInPDFFolder:(NSString *)foldername {
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    NSString *folderPath = [NSString stringWithFormat:@"%@/%@/%@", appDelegate.cookies.username, foldername, PDF_FOLDER_NAME];
    JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
    folderPath = [filePersistence getDirectoryInDocumentWithName:folderPath];
    [filePersistence removeFileAtPath:folderPath];
}

- (void)clearFolder:(NSString *)foldername {
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    NSString *folderPath = [NSString stringWithFormat:@"%@/%@", appDelegate.cookies.username, foldername];
    JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
    folderPath = [filePersistence getDirectoryInDocumentWithName:folderPath];
    [filePersistence removeFileAtPath:folderPath];
}

@end
