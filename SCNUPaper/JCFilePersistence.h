//
//  JCFilePersistence.h
//  JuliaCoreFramework
//
//  Created by Jymn_Chen on 13-11-19.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCFilePersistence : NSObject

//  1.对文件进行存取数据，文件位于Documents目录下

/* 获取Document文件夹的路径 */
- (NSString *)getDirectoryOfDocumentFolder;

/* 获取Document文件夹下文件的路径 */
- (NSString *)getDirectoryOfDocumentFileWithName:(NSString *)fileName;

/* 存取位于Document文件夹下文件中的mutable dictionary数据 */
- (BOOL)saveMutableDictionary:(NSMutableDictionary *)mdic toDocumentFile:(NSString *)fileName;
- (NSMutableDictionary *)loadMutableDictionaryFromDocumentFile:(NSString *)fileName;

/* 存取位于Document文件夹下文件中的mutable array数据 */
- (BOOL)saveMutableArray:(NSMutableArray *)marray toDocumentFile:(NSString *)fileName;
- (NSMutableArray *)loadMutableArrayFromDocumentFile:(NSString *)fileName;

/* 存取位于Document文件夹下文件中的data数据 */
- (BOOL)saveMutableData:(NSMutableData *)mdata toDocumentFile:(NSString *)fileName;
- (NSMutableData *)loadMutableDataFromDocumentFile:(NSString *)fileName;

// -----------------------------------------------------------------------------------------------------------------------

//  2.对文件进行存取数据，文件位于Documents/Directory目录下

/* 在Document目录中创建一个directName命名的子目录 */
- (BOOL)createDirectoryInDocumentWithName:(NSString *)directName;

/* 获取在Document目录中directName命名的子目录的完整路径 */
- (NSString *)getDirectoryInDocumentWithName:(NSString *)directName;

/* 存取位于Document/directory下文件fileName中的mutable dictionary数据 */
- (BOOL)saveMutableDictionary:(NSMutableDictionary *)mdic toFile:(NSString *)fileName inDocumentWithDirectory:(NSString *)directory;
- (NSMutableDictionary *)loadMutableDictionaryFromFile:(NSString *)fileName inDocumentWithDirectory:(NSString *)directory;

/* 存取位于Document/directory下文件fileName中的mutable array数据 */
- (BOOL)saveMutableArray:(NSMutableArray *)marray toFile:(NSString *)fileName inDocumentWithDirectory:(NSString *)directory;
- (NSMutableArray *)loadMutableArrayFromFile:(NSString *)fileName inDocumentWithDirectory:(NSString *)directory;

/* 存取位于Document/directory下文件中的data数据 */
- (BOOL)saveMutableData:(NSMutableData *)mdata ToFile:(NSString *)fileName inDocumentWithDirectory:(NSString *)directory;
- (NSMutableData *)loadMutableDataFromFile:(NSString *)fileName inDocumentWithDirectory:(NSString *)directory;

@end
