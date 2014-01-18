//
//  Cookies.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-21.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "Cookies.h"
#import "Constants.h"
#import "AppDelegate.h"

@implementation Cookies

#pragma mark - Initialization

- (id)initWithUsername:(NSString *)username Password:(NSString *)password NickName:(NSString *)nickname {
    self = [super init];
    
    if (self) {
        self.username = username;
        self.password = password;
        self.nickname = nickname;
    }
    
    return self;
}

- (id)initWithUsername:(NSString *)username Password:(NSString *)password {
    self = [super init];
    
    if (self) {
        self.username = username;
        self.password = password;
    }
    
    return self;
}

#pragma mark - Set file names

- (void)setFileNamesWithDOCFileName:(NSString *)docFileName {
    self.docFileName = docFileName;
    self.pureFileName = [docFileName substringToIndex:docFileName.length - 4];
    self.pdfFileName = [self.pureFileName stringByAppendingString:PDF_SUFFIX];
    self.zipFileName = [self.pureFileName stringByAppendingString:ZIP_SUFFIX];
}

- (void)setFileNamesWithPDFFileName:(NSString *)pdfFileName {
    self.pdfFileName = pdfFileName;
    self.pureFileName = [pdfFileName substringToIndex:pdfFileName.length - 4];
    self.docFileName = [self.pureFileName stringByAppendingString:DOC_SUFFIX];
    self.zipFileName = [self.pureFileName stringByAppendingString:ZIP_SUFFIX];
}

- (void)setFileNamesWithPureFileName:(NSString *)pureFileName {
    self.pureFileName = pureFileName;
    self.pdfFileName = [pureFileName stringByAppendingString:PDF_SUFFIX];
    self.docFileName = [pureFileName stringByAppendingString:DOC_SUFFIX];
    self.zipFileName = [pureFileName stringByAppendingString:ZIP_SUFFIX];
}

#pragma mark - Get directory

- (NSString *)getDOCFolderDirectory {
    return [NSString stringWithFormat:@"%@/%@/%@", self.username, self.pureFileName, DOC_FOLDER_NAME];
}

- (NSString *)getPDFFolderDirectory {
    return [NSString stringWithFormat:@"%@/%@/%@", self.username, self.pureFileName, PDF_FOLDER_NAME];
}

- (NSString *)getDOCFileDirectory {
    return [NSString stringWithFormat:@"%@/%@/%@/%@", self.username, self.pureFileName, DOC_FOLDER_NAME, self.docFileName];
}

- (NSString *)getPDFFileDirectory {
    return [NSString stringWithFormat:@"%@/%@/%@/%@", self.username, self.pureFileName, PDF_FOLDER_NAME, self.pdfFileName];
}

@end
