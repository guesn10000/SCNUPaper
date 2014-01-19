//
//  Cookies.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-21.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cookies : NSObject

/* 登陆参数 */
@property (assign, nonatomic) BOOL isTeacher;

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *nickname;

- (id)initWithUsername:(NSString *)username Password:(NSString *)password NickName:(NSString *)nickname;
- (id)initWithUsername:(NSString *)username Password:(NSString *)password;

- (void)saveUserInfo;

/* 文件名参数 */
@property (strong, nonatomic) NSString *docFileName;
@property (strong, nonatomic) NSString *pdfFileName;
@property (strong, nonatomic) NSString *zipFileName;
@property (strong, nonatomic) NSString *pureFileName;

- (void)setFileNamesWithDOCFileName:(NSString *)docFileName;
- (void)setFileNamesWithPDFFileName:(NSString *)pdfFileName;
- (void)setFileNamesWithPureFileName:(NSString *)pureFileName;

/* 获取文件夹的相对目录 */
- (NSString *)getDOCFolderDirectory;
- (NSString *)getPDFFolderDirectory;
- (NSString *)getDOCFileDirectory;
- (NSString *)getPDFFileDirectory;

@end
