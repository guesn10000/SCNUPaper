//
//  JCFilePersistence.m
//  JuliaCoreFramework
//
//  Created by Jymn_Chen on 13-11-19.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "JCFilePersistence.h"
#import "JCAlert.h"

#if 0
#ifdef LOG_DEBUG
#endif
#endif

#define SANDBOX_DOCUMENTS @"Documents"
#define SANDBOX_LIBRARY   @"Library"
#define SANDBOX_TMP       @"tmp"
#define SANDBOX_INBOX     @"Inbox"

@implementation JCFilePersistence

#pragma mark - Singleton

+ (instancetype)sharedInstance {
    static JCFilePersistence *filePersistence = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        filePersistence = [[super allocWithZone:NULL] init];
    });
    
    return filePersistence;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark - Get directory

- (NSString *)getDirectoryOfDocumentFolder {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); // 获取所有Document文件夹路径
    NSString *documentsPath = paths[0]; // 搜索目标文件所在Document文件夹的路径，通常为第一个
    
    if (!documentsPath) {
        [JCAlert alertWithMessage:@"Documents目录不存在"];
    }
    
    return documentsPath;
}

- (NSString *)getDirectoryOfDocumentFileWithName:(NSString *)fileName {
    NSString *documentsPath = [self getDirectoryOfDocumentFolder];
    if (documentsPath) {
        return [documentsPath stringByAppendingPathComponent:fileName]; // 获取用于存取的目标文件的完整路径
    }
    
    return nil;
}

- (NSString *)getDirectoryInDocumentWithName:(NSString *)directName {
    NSFileManager *fileManager        = [NSFileManager defaultManager];
    NSString      *documentsDirectory = [self getDirectoryOfDocumentFolder];
    if (!documentsDirectory) {
        return nil;
    }
    
    NSString *folderDirectory = [documentsDirectory stringByAppendingPathComponent:directName];
    
    if (![fileManager fileExistsAtPath:folderDirectory]) {
        if ([fileManager createDirectoryAtPath:folderDirectory withIntermediateDirectories:YES attributes:nil error:nil]) {
            return folderDirectory;
        }
        else {
#ifdef LOG_DEBUG
            NSLog(@"目标路径不存在");
#endif
            return nil;
        }
    }
    
    return folderDirectory;
}

- (NSString *)getDirectoryOfInboxFolder {
    NSString *documentPath = [self getDirectoryOfDocumentFolder];
    if (documentPath) {
        if ([self createDirectoryInDocumentWithName:SANDBOX_INBOX]) {
            return [documentPath stringByAppendingPathComponent:SANDBOX_INBOX];
        }
        else {
            [JCAlert alertWithMessage:@"在Document目录下创建Inbox文件夹失败"];
        }
    }
    
    return nil;
}

- (NSString *)getDirectoryOfTmpFolder {
    if ([self createTmpFolder]) {
        return NSTemporaryDirectory();
    }
    else {
        [JCAlert alertWithMessage:@"tmp目录不存在"];
        return nil;
    }
}

- (NSString *)getDirectoryOfTmpFileWithName:(NSString *)fileName {
    NSString *tempFolderPath = [self getDirectoryOfTmpFolder];
    if (tempFolderPath) {
        return [tempFolderPath stringByAppendingPathComponent:fileName];
    }
    
    return nil;
}

#pragma mark - Save and load document file

- (BOOL)saveMutableDictionary:(NSMutableDictionary *)mdic toDocumentFile:(NSString *)fileName {
    NSString *filePath = [self getDirectoryOfDocumentFileWithName:fileName];
    if (filePath) {
        if ([mdic writeToFile:filePath atomically:YES]) {
            return YES;
        }
        else {
            [JCAlert alertWithMessage:@"将Mutable Dictionary数据写入文件失败"];
            return NO;
        }
    }
    else {
        [JCAlert alertWithMessage:@"文件路径不存在，无法写入文件"];
        return NO;
    }
}

- (NSMutableDictionary *)loadMutableDictionaryFromDocumentFile:(NSString *)fileName {
    NSString *filePath = [self getDirectoryOfDocumentFileWithName:fileName];
    if (!filePath) {
        return nil;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSMutableDictionary *mdic = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath]; // 从文件中获取数据
        if (mdic) {
            return mdic;
        }
    }
#ifdef LOG_DEBUG
    NSLog(@"文件不存在，加载Mutable Dictionary数据失败");
#endif
    return nil;
}

- (BOOL)saveMutableArray:(NSMutableArray *)marray toDocumentFile:(NSString *)fileName {
    NSString *filePath = [self getDirectoryOfDocumentFileWithName:fileName];
    if (filePath) {
        if ([marray writeToFile:filePath atomically:YES]) {
            return YES;
        }
        else {
            [JCAlert alertWithMessage:@"将Mutable Array数据写入文件失败"];
            return NO;
        }
    }
    else {
        [JCAlert alertWithMessage:@"文件路径不存在，无法写入文件"];
        return NO;
    }
}

- (NSMutableArray *)loadMutableArrayFromDocumentFile:(NSString *)fileName {
    NSString *filePath = [self getDirectoryOfDocumentFileWithName:fileName];
    if (!filePath) {
        return nil;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSMutableArray *marray = [[NSMutableArray alloc] initWithContentsOfFile:filePath]; // 从文件中获取数据
        if (marray) {
            return marray;
        }
    }
#ifdef LOG_DEBUG
    NSLog(@"文件不存在，加载Mutable Array数据失败");
#endif
    return nil;
}

- (BOOL)saveMutableData:(NSMutableData *)mdata toDocumentFile:(NSString *)fileName {
    NSString *filePath = [self getDirectoryOfDocumentFileWithName:fileName];
    if (filePath) {
        if ([mdata writeToFile:filePath atomically:YES]) {
            return YES;
        }
        else {
            [JCAlert alertWithMessage:@"将Mutable Data数据写入文件失败"];
            return NO;
        }
    }
    else {
        [JCAlert alertWithMessage:@"文件路径不存在，无法写入文件"];
        return NO;
    }
}

- (NSMutableData *)loadMutableDataFromDocumentFile:(NSString *)fileName {
    NSString *filePath = [self getDirectoryOfDocumentFileWithName:fileName];
    if (!filePath) {
        return nil;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSMutableData *mdata = [[NSMutableData alloc] initWithContentsOfFile:filePath]; // 从文件中获取数据
        if (mdata) {
            return mdata;
        }
    }
#ifdef LOG_DEBUG
    NSLog(@"文件不存在，加载Mutable Data数据失败");
#endif
    return nil;
}

#pragma mark - Save and load tmp file

- (BOOL)saveMutableData:(NSMutableData *)mdata toTmpFile:(NSString *)fileName {
    NSString *filePath = [self getDirectoryOfTmpFileWithName:fileName];
    if (filePath) {
        if ([mdata writeToFile:filePath atomically:YES]) {
            return YES;
        }
        else {
            [JCAlert alertWithMessage:@"将Mutable Data数据写入文件失败"];
            return NO;
        }
    }
    else {
        [JCAlert alertWithMessage:@"文件路径不存在，无法写入文件"];
        return NO;
    }
}
    
- (NSMutableData *)loadMutableDataFromTmpFile:(NSString *)fileName {
    NSString *filePath = [self getDirectoryOfTmpFileWithName:fileName];
    if (!filePath) {
        return nil;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSMutableData *mdata = [[NSMutableData alloc] initWithContentsOfFile:filePath]; // 从文件中获取数据
        if (mdata) {
            return mdata;
        }
    }
#ifdef LOG_DEBUG
    NSLog(@"文件不存在，加载Mutable Data数据失败");
#endif
    return nil;
}

#pragma mark - Save and load file in directory of document

- (BOOL)saveMutableDictionary:(NSMutableDictionary *)mdic toFile:(NSString *)fileName inDocumentWithDirectory:(NSString *)directory {
    NSString *folderPath = [self getDirectoryInDocumentWithName:directory];
    if (!folderPath) {
        return NO;
    }
    
    NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
    if ([mdic writeToFile:filePath atomically:YES]) {
        return YES;
    }
    else {
        [JCAlert alertWithMessage:@"保存Mutable Dictionary数据失败"];
        return NO;
    }
}

- (NSMutableDictionary *)loadMutableDictionaryFromFile:(NSString *)fileName inDocumentWithDirectory:(NSString *)directory {
    NSString *folderPath = [self getDirectoryInDocumentWithName:directory];
    if (!folderPath) {
        return nil;
    }
    
    NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSMutableDictionary *mdic = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath]; // 从文件中获取数据
        return mdic;
    }
    
    return nil;
}

- (BOOL)saveMutableArray:(NSMutableArray *)marray toFile:(NSString *)fileName inDocumentWithDirectory:(NSString *)directory {
    NSString *folderPath = [self getDirectoryInDocumentWithName:directory];
    if (!folderPath) {
        return NO;
    }
    
    NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
    if ([marray writeToFile:filePath atomically:YES]) {
        return YES;
    }
    else {
        [JCAlert alertWithMessage:@"保存Mutable Array数据失败"];
        return NO;
    }
}

- (NSMutableArray *)loadMutableArrayFromFile:(NSString *)fileName inDocumentWithDirectory:(NSString *)directory {
    NSString *folderPath = [self getDirectoryInDocumentWithName:directory];
    if (!folderPath) {
        return nil;
    }
    
    NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSMutableArray *marray = [[NSMutableArray alloc] initWithContentsOfFile:filePath]; // 从文件中获取数据
        return marray;
    }
    
    return nil;
}

- (BOOL)saveMutableData:(NSMutableData *)mdata ToFile:(NSString *)fileName inDocumentWithDirectory:(NSString *)directory {
    NSString *folderPath = [self getDirectoryInDocumentWithName:directory];
    if (!folderPath) {
        return NO;
    }
    
    NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
    if ([mdata writeToFile:filePath atomically:YES]) {
        return YES;
    }
    else {
        [JCAlert alertWithMessage:@"保存Mutable Data数据失败"];
        return NO;
    }
}

- (NSMutableData *)loadMutableDataFromFile:(NSString *)fileName inDocumentWithDirectory:(NSString *)directory {
    NSString *folderPath = [self getDirectoryInDocumentWithName:directory];
    if (!folderPath) {
        return nil;
    }
    
    NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSMutableData *mdata = [[NSMutableData alloc] initWithContentsOfFile:filePath]; // 从文件中获取数据
        return mdata;
    }
    
    return nil;
}

#pragma mark - Create files

/* 在Documents目录下创建文件夹 */
- (BOOL)createDirectoryInDocumentWithName:(NSString *)directName {
    NSFileManager *fileManager        = [NSFileManager defaultManager];
    NSString      *documentsDirectory = [self getDirectoryOfDocumentFolder];
    NSString      *folderDirectory    = [documentsDirectory stringByAppendingPathComponent:directName];
    
    if (![fileManager fileExistsAtPath:folderDirectory]) {
        NSError *error = nil;
        BOOL isCreated = [fileManager createDirectoryAtPath:folderDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error) {
#ifdef LOG_DEBUG
            NSLog(@"在Document文件夹下创建目录失败，error = %@", error);
#endif
            return NO;
        }
        
        if (isCreated) {
            return YES;
        }
        else {
            [JCAlert alertWithMessage:@"在Document文件夹下创建目录失败"];
            return NO;
        }
    }
    else {
        return YES;
    }
}

/* 创建tmp文件夹 */
- (BOOL)createTmpFolder {
    NSFileManager *fileManager   = [NSFileManager defaultManager];
    NSString      *tmpFolderPath = NSTemporaryDirectory();
    
    if (![fileManager fileExistsAtPath:tmpFolderPath]) {
        NSError *error = nil;
        BOOL isCreated = [fileManager createDirectoryAtPath:tmpFolderPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
#ifdef LOG_DEBUG
            NSLog(@"创建tmp文件夹失败，error = %@", error);
#endif
            return NO;
        }
        
        if (isCreated) {
            return YES;
        }
        else {
            [JCAlert alertWithMessage:@"创建tmp文件夹失败"];
            return NO;
        }
    }
    else {
        return YES;
    }
}

#pragma mark - Remove files

- (void)removeFilesAtInboxFolder {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 清空Inbox文件夹中的文件
    NSString *inboxPath = [self getDirectoryOfInboxFolder];
    if (!inboxPath) {
#ifdef LOG_DEBUG
        NSLog(@"Inbox目录不存在");
#endif
        return;
    }
    
    NSError *error = nil;
    NSArray *filesInBox = [fileManager contentsOfDirectoryAtPath:inboxPath error:&error];
    if (error) {
        [JCAlert alertWithMessage:@"获取Inbox文件夹中的内容失败" Error:error];
        return;
    }
    if (!filesInBox) {
        [JCAlert alertWithMessage:@"获取Inbox文件夹中的内容失败"];
        return;
    }
    
    for (int i = 0; i < filesInBox.count; i++) {
        NSString *filePath = [inboxPath stringByAppendingPathComponent:filesInBox[i]];
        [self removeFileAtPath:filePath];
    }
}

- (void)removeFilesAtTmpFolder {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 清空tmp文件夹中的文件
    NSString *tmpPath = [self getDirectoryOfTmpFolder];
    if (!tmpPath) {
#ifdef LOG_DEBUG
        NSLog(@"tmp目录不存在");
#endif
        return;
    }
    
    NSError *error = nil;
    NSArray *filesInTmp = [fileManager contentsOfDirectoryAtPath:tmpPath error:&error];
    if (error) {
        [JCAlert alertWithMessage:@"获取tmp文件夹中的内容失败" Error:error];
        return;
    }
    if (!filesInTmp) {
        [JCAlert alertWithMessage:@"获取tmp文件夹中的内容失败"];
        return;
    }
    
    for (int i = 0; i < filesInTmp.count; i++) {
        NSString *filePath = [tmpPath stringByAppendingPathComponent:filesInTmp[i]];
        [self removeFileAtPath:filePath];
    }
}

- (void)removeFileAtPath:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:&error];
        if (error) {
            [JCAlert alertWithMessage:@"移除文件失败" Error:error];
        }
    }
}

#pragma mark - Move file

- (void)moveFileFromPath:(NSString *)srcFilePath toPath:(NSString *)desFilePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:srcFilePath]) {
        if ([fileManager fileExistsAtPath:desFilePath]) { // 如果文件存在于目标路径中，先将其移除
            NSError *removeError = nil;
            [fileManager removeItemAtPath:desFilePath error:&removeError];
            if (removeError) {
                [JCAlert alertWithMessage:@"移除目标文件失败" Error:removeError];
                return;
            }
        }
        
        // 从源路径移动文件到目标路径
        NSError *moveError = nil;
        [fileManager moveItemAtPath:srcFilePath toPath:desFilePath error:&moveError];
        if (moveError) {
            [JCAlert alertWithMessage:@"移动文件出错" Error:moveError];
        }
    }
    else {
#ifdef LOG_DEBUG
        NSLog(@"移动文件失败，源文件不存在");
#endif
    }
}

- (void)copyFileFromPath:(NSString *)srcFilePath toPath:(NSString *)desFilePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:srcFilePath]) {
        if ([fileManager fileExistsAtPath:desFilePath]) { // 如果文件存在于目标路径中，先将其移除
            NSError *removeError = nil;
            [fileManager removeItemAtPath:desFilePath error:&removeError];
            if (removeError) {
                [JCAlert alertWithMessage:@"移除目标文件失败" Error:removeError];
                return;
            }
        }
        
        // 从源路径移动文件到目标路径
        NSError *copyError = nil;
        [fileManager copyItemAtPath:srcFilePath toPath:desFilePath error:&copyError];
        if (copyError) {
            [JCAlert alertWithMessage:@"移动文件出错" Error:copyError];
        }
    }
    else {
#ifdef LOG_DEBUG
        NSLog(@"复制文件失败，源文件不存在");
#endif
    }
}

@end
