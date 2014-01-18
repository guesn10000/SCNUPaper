//
//  JCFilePersistence.m
//  JuliaCoreFramework
//
//  Created by Jymn_Chen on 13-11-19.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "JCFilePersistence.h"
#import "JCAlert.h"

@implementation JCFilePersistence

#pragma mark - Handle files in document

- (NSString *)getDirectoryOfDocumentFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); // 获取所有Document文件夹路径
    NSString *documentsDirectory = paths[0]; // 搜索目标文件所在Document文件夹的路径，通常为第一个
    
    if (!documentsDirectory) {
        [JCAlert alertWithMessage:@"Document目录不存在"];
        return nil;
    }
    
    return documentsDirectory;
}

- (NSString *)getDirectoryOfDocumentFileWithName:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); // 获取所有Document文件夹路径
    NSString *documentsDirectory = paths[0]; // 搜索目标文件所在Document文件夹的路径，通常为第一个
    
    if (!documentsDirectory) {
        [JCAlert alertWithMessage:@"Document文件夹不存在，获取文件路径失败"];
        return nil;
    }
    
    return [documentsDirectory stringByAppendingPathComponent:fileName]; // 获取用于存取的目标文件的完整路径
}

- (BOOL)saveMutableDictionary:(NSMutableDictionary *)mdic toDocumentFile:(NSString *)fileName
{
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

- (NSMutableDictionary *)loadMutableDictionaryFromDocumentFile:(NSString *)fileName
{
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

- (BOOL)saveMutableArray:(NSMutableArray *)marray toDocumentFile:(NSString *)fileName
{
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

- (NSMutableArray *)loadMutableArrayFromDocumentFile:(NSString *)fileName
{
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

- (BOOL)saveMutableData:(NSMutableData *)mdata toDocumentFile:(NSString *)fileName
{
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

- (NSMutableData *)loadMutableDataFromDocumentFile:(NSString *)fileName
{
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
        [JCAlert alertWithMessage:@"文件路径不存在，无法写入文件"];
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
//            [JCAlert alertWithMessage:@"目标路径不存在"];
            NSLog(@"目标路径不存在");
            return nil;
        }
    }
    
    return folderDirectory;
}

- (BOOL)saveMutableDictionary:(NSMutableDictionary *)mdic toFile:(NSString *)fileName inDocumentWithDirectory:(NSString *)directory
{
    NSString *folderPath = [self getDirectoryInDocumentWithName:directory];
    NSString *filePath = [folderPath stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName]];
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
    NSString *filePath = [folderPath stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName]];
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
    NSString *filePath = [folderPath stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName]];
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
    NSString *filePath = [folderPath stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName]];
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
    NSString *filePath = [folderPath stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName]];
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
    NSString *filePath = [folderPath stringByAppendingString:[NSString stringWithFormat:@"/%@", fileName]];
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

@end
