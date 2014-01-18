//
//  MyPDFDocument.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-17.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyPDFDocument : NSObject

/* PDF文档 */
@property (assign, nonatomic) CGPDFDocumentRef pdfDocumentRef;

/* PDF文档的总页数 */
@property (assign, nonatomic) size_t totalPages;

/* 当前的页号，从1开始 */
@property (assign, nonatomic) size_t currentIndex;

/* 初始化PDF文档，总页数，当前页号 */
- (id)initWithPDFFilePath:(NSString *)pdfFilePath;

@end
