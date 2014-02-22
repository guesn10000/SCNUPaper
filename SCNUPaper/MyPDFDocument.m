//
//  MyPDFDocument.m
//  论文批阅系统
//
//  Created by ; on 13-11-17.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "MyPDFDocument.h"
#import "JCAlert.h"

@interface MyPDFDocument ()

@end

@implementation MyPDFDocument

- (id)initWithPDFFilePath:(NSString *)pdfFilePath {
    self = [super init];
    
    if (self) {
        NSURL *pdfFileURL = [NSURL fileURLWithPath:pdfFilePath];
        CGPDFDocumentRef document = CGPDFDocumentCreateWithURL((__bridge CFURLRef)(pdfFileURL));
        
        self.totalPages = CGPDFDocumentGetNumberOfPages(document);
        
        if (self.totalPages == 0) {
            [JCAlert alertWithMessage:@"打开的文件已经损坏或内容为空"];
            self.currentIndex = 0;
        }
        else {
            self.currentIndex = 1;
        }
        
        self.pdfDocumentRef = document;
        CFRelease(document);
    }
    
    return self;
}

@end
