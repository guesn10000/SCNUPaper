//
//  TextAnnotation.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-21.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MyPDFAnnotation;

@interface TextAnnotation : NSObject

+ (void)saveInputText:(NSString *)inputText PDFAnnotation:(MyPDFAnnotation *)pdfAnnotation toFolder:(NSString *)folderName;

+ (void)addNewInputText:(NSString *)inputText toFolder:(NSString *)foldername Page:(size_t)pageIndex Key:(NSInteger)annoKey;

+ (void)editInputText:(NSString *)inputText toFolder:(NSString *)foldername Page:(size_t)pageIndex Key:(NSInteger)annoKey Row:(NSInteger)row;

@end
