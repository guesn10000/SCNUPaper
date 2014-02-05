//
//  JCFilePersistence.m
//  JuliaCoreFramework
//
//  Created by Jymn_Chen on 13-11-19.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "JCFilePersistence.h"
#import "JCAlert.h"

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

#pragma mark - Handle files in document

- (NSString *)getDirectoryOfDocumentFolder {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); // 获取所有Document文件夹路径
    NSString *documentsDirectory = paths[0]; // 搜索目标文件所在Document文件夹的路径，通常为第一个
    
    if (!documentsDirectory) {
        [JCAlert alertWithMessage:@"Document目录不存在"];
        return nil;
    }
    
    return documentsDirectory;
}

- (NSString *)getDirectoryOfInboxFolder {
    NSString *documentPath = [self getDirectoryOfDocumentFolder];
    if (!documentPath) {
        [JCAlert alertWithMessage:@"Document文件夹不存在，获取文件路径失败"];
        return nil;
    }
    else {
        if ([self createDirectoryInDocumentWithName:SANDBOX_INBOX]) {
            return [documentPath stringByAppendingPathComponent:SANDBOX_INBOX];
        }
        else {
            [JCAlert alertWithMessage:@"在Document目录下创建Inbox文件夹失败"];
            return nil;
        }
    }
}

- (NSString *)getDirectoryOfTmpFolder {
    NSString *tmpDirectory = NSTemporaryDirectory();
    if (!tmpDirectory) {
        [JCAlert alertWithMessage:@"tmp目录不存在"];
        return nil;
    }
    return tmpDirectory;
}

- (NSString *)getDirectoryOfDocumentFileWithName:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); // 获取所有Document文件夹路径
    NSString *documentsDirectory = paths[0]; // 搜索目标文件所在Document文件夹的路径，通常为第一个
    
    if (!documentsDirectory) {
        [JCAlert alertWithMessage:@"Document文件夹不存在，获取文件路径失败"];
        return nil;
    }
    
    return [documentsDirectory stringByAppendingPathComponent:fileName]; // 获取用于存取的目标文件的完整路径
}

- (NSString *)getDirectoryOfTmpFileWithName:(NSString *)fileName {
    NSString *tempFolderPath = [self getDirectoryOfTmpFolder];
    if (!tempFolderPath) {
        [JCAlert alertWithMessage:@"tmp文件夹不存在，获取文件路径失败"];
        return nil;
    }
    else {
        return [tempFolderPath stringByAppendingPathComponent:fileName];
    }
}

- (BOOL)saveMutableDictionary:(NSMutableDictionary *)mdic toDocumentFile:(NSString *)fileName {
    NSString *filePath = [self getDirectoryOfDocumentFileWithName:fileName];
    
    if (filePath) {
        BOOL succeed = [mdic writeToFile:filePath atomically:YES]; // 将数据写入文件中
        if (succeed == NO) {
            [JCAlert alertWithMessage:@"将Mutable Dictionary数据写入文件失败"];
        }
        return succeed;
    }
    else {
        [JCAlert alertWithMessage:@"文件路径不存在，无法写入文件"];
        return NO;
    }
}

- (NSMutableDictionary *)loadMutableDictionaryFromDocumentFile:(NSString *)fileName {
    NSString *filePath = [self getDirectoryOfDocumentFileWithName:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSMutableDictionary *mdic = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath]; // 从文件中获取数据
        if (mdic) {
            return mdic;
        }
        else {
            [JCAlert alertWithMessage:@"加载Mutable Dictionary数据失败，文件内容为空"];
            return nil;
        }
    }
    else {
//        [JCAlert alertWithMessage:@"文件不存在，加载数据失败"];
        return nil;
    }
}

- (BOOL)saveMutableArray:(NSMutableArray *)marray toDocumentFile:(NSString *)fileName {
    NSString *filePath = [self getDirectoryOfDocumentFileWithName:fileName];
    
    if (filePath) {
        BOOL succeed = [marray writeToFile:filePath atomically:YES]; // 将数据写入文件中
        if (succeed == NO) {
            [JCAlert alertWithMessage:@"将Mutable Array数据写入文件失败"];
        }
        return succeed;
    }
    else {
        [JCAlert alertWithMessage:@"文件路径不存在，无法写入文件"];
        return NO;
    }
}

- (NSMutableArray *)loadMutableArrayFromDocumentFile:(NSString *)fileName {
    NSString *filePath = [self getDirectoryOfDocumentFileWithName:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSMutableArray *marray = [[NSMutableArray alloc] initWithContentsOfFile:filePath]; // 从文件中获取数据
        if (marray) {
            return marray;
        }
        else {
            [JCAlert alertWithMessage:@"加载Mutable Array数据失败，文件内容为空"];
            return nil;
        }
    }
    else {
//        [JCAlert alertWithMessage:@"文件不存在，加载数据失败"];
        return nil;
    }
}

- (BOOL)saveMutableData:(NSMutableData *)mdata toDocumentFile:(NSString *)fileName {
    NSString *filePath = [self getDirectoryOfDocumentFileWithName:fileName];
    
    if (filePath) {
        BOOL succeed = [mdata writeToFile:filePath atomically:YES];
        if (succeed == NO) {
            [JCAlert alertWithMessage:@"将Mutable Data数据写入文件失败"];
        }
        return succeed;
    }
    else {
        [JCAlert alertWithMessage:@"文件路径不存在，无法写入文件"];
        return NO;
    }
}

- (NSMutableData *)loadMutableDataFromDocumentFile:(NSString *)fileName {
    NSString *filePath = [self getDirectoryOfDocumentFileWithName:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSMutableData *mdata = [[NSMutableData alloc] initWithContentsOfFile:filePath]; // 从文件中获取数据
        if (mdata) {
            return mdata;
        }
        else {
            [JCAlert alertWithMessage:@"加载Mutable Data数据失败，文件内容为空"];
            return nil;
        }
    }
    else {
        [JCAlert alertWithMessage:@"文件路径不存在，无法读取文件"];
        return nil;
    }
}

- (BOOL)saveMutableData:(NSMutableData *)mdata toTmpFile:(NSString *)fileName {
    NSString *filePath = [self getDirectoryOfTmpFileWithName:fileName];
    if (filePath) {
        BOOL succeed = [mdata writeToFile:filePath atomically:YES];
        if (succeed == NO) {
            [JCAlert alertWithMessage:@"将Mutable Data数据写入文件失败"];
        }
        return succeed;
    }
    else {
        [JCAlert alertWithMessage:@"文件路径不存在，无法写入文件"];
        return NO;
    }
}
    
- (NSMutableData *)loadMutableDataFromTmpFile:(NSString *)fileName {
    NSString *filePath = [self getDirectoryOfTmpFileWithName:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSMutableData *mdata = [[NSMutableData alloc] initWithContentsOfFile:filePath]; // 从文件中获取数据
        if (mdata) {
            return mdata;
        }
        else {
            [JCAlert alertWithMessage:@"加载Mutable Data数据失败，文件内容为空"];
            return nil;
        }
    }
    else {
        [JCAlert alertWithMessage:@"文件路径不存在，无法读取文件"];
        return nil;
    }
}


#pragma mark - Handle files in subdirectory of document

/* 在Documents目录下创建文件夹 */
- (BOOL)createDirectoryInDocumentWithName:(NSString *)directName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [self getDirectoryOfDocumentFolder];
    NSString *folderDirectory = [NSString stringWithFormat:@"%@/%@", documentsDirectory, directName];
    if (![fileManager fileExistsAtPath:folderDirectory]) {
        BOOL isCreated = [fileManager createDirectoryAtPath:folderDirectory withIntermediateDirectories:YES attributes:nil error:nil];
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

/* 获取文件夹存放的路径 */
- (NSString *)getDirectoryInDocumentWithName:(NSString *)directName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [self getDirectoryOfDocumentFolder];
    NSString *folderDirectory = [NSString stringWithFormat:@"%@/%@", documentsDirectory, directName];
    if (![fileManager fileExistsAtPath:folderDirectory]) {
        BOOL isCreated = [fileManager createDirectoryAtPath:folderDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        if (isCreated) {
            return folderDirectory;
        }
        else {
            NSLog(@"目标路径不存在");
            return nil;
        }
    }
    
    return folderDirectory;
}

- (BOOL)saveMutableDictionary:(NSMutableDictionary *)mdic toFile:(NSString *)fileName inDocumentWithDirectory:(NSString *)directory
{
    NSString *folderPath = [self getDirectoryInDocumentWithName:directory];
    NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
    if (filePath) {
        BOOL succeed = [mdic writeToFile:filePath atomically:YES]; // 将数据写入文件中
        if (succeed == NO) {
            [JCAlert alertWithMessage:@"保存Mutable Dictionary数据失败"];
        }
        return succeed;
    }
    else {
        [JCAlert alertWithMessage:@"文件路径不存在，保存数据失败"];
        return NO;
    }
}

- (NSMutableDictionary *)loadMutableDictionaryFromFile:(NSString *)fileName inDocumentWithDirectory:(NSString *)directory
{
    NSString *folderPath = [self getDirectoryInDocumentWithName:directory];
    NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSMutableDictionary *mdic = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath]; // 从文件中获取数据
        if (mdic) {
            return mdic;
        }
        else {
//            [JCAlert alertWithMessage:@"数据为空，加载数据失败"];
            return nil;
        }
    }
    else {
//        [JCAlert alertWithMessage:@"文件不存在，加载数据失败"];
        return nil;
    }
}

- (BOOL)saveMutableArray:(NSMutableArray *)marray toFile:(NSString *)fileName inDocumentWithDirectory:(NSString *)directory
{
    NSString *folderPath = [self getDirectoryInDocumentWithName:directory];
    NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
    if (filePath) {
        BOOL succeed = [marray writeToFile:filePath atomically:YES]; // 将数据写入文件中
        if (succeed == NO) {
            [JCAlert alertWithMessage:@"保存Mutable Array数据失败"];
        }
        return succeed;
    }
    else {
        [JCAlert alertWithMessage:@"文件路径不存在，保存数据失败"];
        return NO;
    }
}

- (NSMutableArray *)loadMutableArrayFromFile:(NSString *)fileName inDocumentWithDirectory:(NSString *)directory
{
    NSString *folderPath = [self getDirectoryInDocumentWithName:directory];
    NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSMutableArray *marray = [[NSMutableArray alloc] initWithContentsOfFile:filePath]; // 从文件中获取数据
        if (marray) {
            return marray;
        }
        else {
//            [JCAlert alertWithMessage:@"数据为空，加载数据失败"];
            return nil;
        }
    }
    else {
//        [JCAlert alertWithMessage:@"文件不存在，加载数据失败"];
        return nil;
    }
}

- (BOOL)saveMutableData:(NSMutableData *)mdata ToFile:(NSString *)fileName inDocumentWithDirectory:(NSString *)directory
{
    NSString *folderPath = [self getDirectoryInDocumentWithName:directory];
    NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
    if (filePath) {
        BOOL succeed = [mdata writeToFile:filePath atomically:YES];
        if (succeed == NO) {
            [JCAlert alertWithMessage:@"保存Mutable Data数据失败"];
        }
        return succeed;
    }
    else {
        [JCAlert alertWithMessage:@"文件路径不存在，保存数据失败"];
        return NO;
    }
}

- (NSMutableData *)loadMutableDataFromFile:(NSString *)fileName inDocumentWithDirectory:(NSString *)directory
{
    NSString *folderPath = [self getDirectoryInDocumentWithName:directory];
    NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSMutableData *mdata = [[NSMutableData alloc] initWithContentsOfFile:filePath]; // 从文件中获取数据
        if (mdata) {
            return mdata;
        }
        else {
//            [JCAlert alertWithMessage:@"数据为空，加载数据失败"];
            return nil;
        }
    }
    else {
//        [JCAlert alertWithMessage:@"文件不存在，加载数据失败"]; 
        return nil;
    }
}

#pragma mark - Remove files

- (void)removeFilesAtInboxFolder {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 清空Inbox文件夹中的文件
    NSString *inboxPath = [self getDirectoryOfInboxFolder];
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
        if ([fileManager fileExistsAtPath:filePath isDirectory:NO]) {
            [fileManager removeItemAtPath:filePath error:NULL];
        }
    }
}

- (void)removeFilesAtTmpFolder {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 清空tmp文件夹中的文件
    NSString *tmpPath = [self getDirectoryOfTmpFolder];
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
            return;
        }
    }
    else {
//        NSLog(@"目标路径的文件不存在");
    }
}

#pragma mark - Move file

- (void)moveFileFromPath:(NSString *)srcFilePath toPath:(NSString *)desFilePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:srcFilePath]) {
        NSError *removeError = nil;
        NSError *moveError = nil;
        if ([fileManager fileExistsAtPath:desFilePath]) { // 如果文件存在于目标路径中，先将其移除
            [fileManager removeItemAtPath:desFilePath error:&removeError];
            if (removeError) {
                [JCAlert alertWithMessage:@"移除文件失败" Error:removeError];
                return;
            }
        }
        
        // 从源路径移动文件到目标路径
        [fileManager moveItemAtPath:srcFilePath toPath:desFilePath error:&moveError];
        if (moveError) {
            [JCAlert alertWithMessage:@"移动文件出错" Error:moveError];
            return;
        }
    }
}

@end
