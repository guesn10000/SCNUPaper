//
//  TextAnnotation.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-21.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "TextAnnotation.h"
#import "AppDelegate.h"
#import "Cookies.h"
#import "Constants.h"
#import "KeyGeneraton.h"
#import "JCFilePersistence.h"
#import "MyPDFAnnotation.h"

@implementation TextAnnotation

+ (void)saveInputText:(NSString *)inputText PDFAnnotation:(MyPDFAnnotation *)pdfAnnotation toFolder:(NSString *)folderName {
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
    
    // 1.获取文件路径，文件名：PageIndex_CommentAnnotationKey_text.plist
    NSString *fileName = [NSString stringWithFormat:@"%zu_%d_text.plist", pdfAnnotation.inPageIndex, pdfAnnotation.commentAnnotationKey];
    // 完整路径：Document / Username / PureFileName / PDF / Text / PageIndex_ButtonKey_text.plist
    NSString *fileDirectory = [NSString stringWithFormat:@"%@/%@/%@/%@", appDelegate.cookies.username, folderName, PDF_FOLDER_NAME, TEXT_FOLDER_NAME];
    
    
    // 2.从文件中加载数组数据，将input text加入数组中
    NSMutableArray *textArray = [filePersistence loadMutableArrayFromFile:fileName inDocumentWithDirectory:fileDirectory];
    if (!textArray) {
        textArray = [[NSMutableArray alloc] init];
    }
    [textArray addObject:inputText];
    
    
    // 3.将数组写回文件中
    [filePersistence saveMutableArray:textArray toFile:fileName inDocumentWithDirectory:fileDirectory];
    
    
    // 4.保存每一页的annotationkey
    [appDelegate.keyGeneration updateAnnotationKeysWithDocumentName:appDelegate.cookies.pureFileName];
}

+ (void)addNewInputText:(NSString *)inputText toFolder:(NSString *)foldername Page:(size_t)pageIndex Key:(NSInteger)annoKey {
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
    
    // 1.获取文件路径，文件名：PageIndex_CommentAnnotationKey_text.plist
    NSString *fileName = [NSString stringWithFormat:@"%zu_%d_text.plist", pageIndex, annoKey];
    // 完整路径：Document / Username / PureFileName / PDF / Text / PageIndex_ButtonKey_text.plist
    NSString *fileDirectory = [NSString stringWithFormat:@"%@/%@/%@/%@", appDelegate.cookies.username, foldername, PDF_FOLDER_NAME, TEXT_FOLDER_NAME];
    
    
    // 2.从文件中加载数组数据，将input text加入数组中
    NSMutableArray *textArray = [filePersistence loadMutableArrayFromFile:fileName inDocumentWithDirectory:fileDirectory];
    if (!textArray) {
        textArray = [[NSMutableArray alloc] init];
    }
    [textArray addObject:inputText];
    
    
    // 3.将数组写回文件中
    [filePersistence saveMutableArray:textArray toFile:fileName inDocumentWithDirectory:fileDirectory];
}

+ (void)editInputText:(NSString *)inputText toFolder:(NSString *)foldername Page:(size_t)pageIndex Key:(NSInteger)annoKey Row:(NSInteger)row {
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
    
    // 1.获取文件路径，文件名：PageIndex_CommentAnnotationKey_text.plist
    NSString *fileName = [NSString stringWithFormat:@"%zu_%d_text.plist", pageIndex, annoKey];
    // 完整路径：Document / Username / PureFileName / PDF / Text / PageIndex_ButtonKey_text.plist
    NSString *fileDirectory = [NSString stringWithFormat:@"%@/%@/%@/%@", appDelegate.cookies.username, foldername, PDF_FOLDER_NAME, TEXT_FOLDER_NAME];
    
    
    // 2.从文件中加载数组数据，将input text加入数组中
    NSMutableArray *textArray = [filePersistence loadMutableArrayFromFile:fileName inDocumentWithDirectory:fileDirectory];
    if (!textArray) {
        return;
    }
    textArray[row] = inputText;
    
    // 3.将数组写回文件中
    [filePersistence saveMutableArray:textArray toFile:fileName inDocumentWithDirectory:fileDirectory];
    
}

@end
