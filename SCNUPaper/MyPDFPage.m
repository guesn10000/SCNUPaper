//
//  MyPDFPage.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-19.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "MyPDFPage.h"
#import "MyPDFAnnotation.h"
#import "AppDelegate.h"
#import "Cookies.h"
#import "KeyGeneraton.h"
#import "Constants.h"
#import "JCFilePersistence.h"
#import "CommentStroke.h"

@implementation MyPDFPage

- (id)initWithDocument:(CGPDFDocumentRef)pdfDocument PageIndex:(size_t)pageIndex {
    self = [super init];
    
    if (self) {
        // 初始化参数
        AppDelegate *appDelegate = APPDELEGATE;
        
        // 设置pdfPage内容
        self.pdfPageRef = CGPDFDocumentGetPage(pdfDocument, pageIndex);
        self.pageIndex  = pageIndex;
        
        /* Add Strokes部分 */
        // 初始化add strokes的笔画
        self.currentDrawStrokes = [[NSMutableArray alloc] init];
        NSString *drawStrokesFileName = [NSString stringWithFormat:@"%zu_drawStrokes.plist", pageIndex];
        NSString *drawStrokesFileDirectory = [NSString stringWithFormat:@"%@/%@/%@/%@", appDelegate.cookies.username, appDelegate.cookies.pureFileName, PDF_FOLDER_NAME, DRAW_STROKES_FOLDER_NAME];
        
        // 解压从文件中加载的二进制数据
        NSMutableData *mdata = [appDelegate.filePersistence loadMutableDataFromFile:drawStrokesFileName inDocumentWithDirectory:drawStrokesFileDirectory];
        if (mdata) {
            @try {
                self.previousDrawStrokes = [NSKeyedUnarchiver unarchiveObjectWithData:mdata];
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception);
            }
            @finally {
                
            }
        }
        
        /* Add Comments部分 */
        // 初始化Comments的Strokes
        [self loadCommentStrokesAndAnnotationsFromFile];
        
        /* 防错的初始化 */
        if (!self.previousDrawStrokes) {
            self.previousDrawStrokes = [[NSMutableArray alloc] init];
        }
        if (!self.previousStrokesForComments) {
            self.previousStrokesForComments = [[NSMutableArray alloc] init];
        }
        if (!self.previousAnnotationsForComments) {
            self.previousAnnotationsForComments = [[NSMutableArray alloc] init];
        }
        self.currentAnnotationsForComments = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)reloadPDFPage {
    [self loadCommentStrokesAndAnnotationsFromFile];
}

- (void)loadCommentStrokesAndAnnotationsFromFile {
    AppDelegate *appDelegate = APPDELEGATE;
    
    NSString *strokesFileName = [NSString stringWithFormat:@"%zu_commentStrokes.plist", self.pageIndex];
    NSString *strokesFileDirectory = [NSString stringWithFormat:@"%@/%@/%@/%@", appDelegate.cookies.username, appDelegate.cookies.pureFileName, PDF_FOLDER_NAME, COMMENT_STROKES_FOLDER_NAME];
    NSMutableData *mcdata = [appDelegate.filePersistence loadMutableDataFromFile:strokesFileName inDocumentWithDirectory:strokesFileDirectory];
    if (mcdata) {
        @try {
            self.previousStrokesForComments = [NSKeyedUnarchiver unarchiveObjectWithData:mcdata];
            if (!self.previousStrokesForComments) {
                self.previousStrokesForComments = [[NSMutableArray alloc] init];
            }
            for (CommentStroke *stroke in self.previousStrokesForComments) {
                MyPDFAnnotation *tempPDFAnnotation = [[MyPDFAnnotation alloc] initWithFrame:stroke.frame
                                                                                      Scale:self.convertScale
                                                                                        Key:stroke.buttonKey
                                                                                  PageIndex:self.pageIndex
                                                                             TextAnnotation:stroke.hasVoiceAnnotation
                                                                            VoiceAnnotation:stroke.hasVoiceAnnotation];
                [self.previousAnnotationsForComments addObject:tempPDFAnnotation];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        @finally {
            
        }
    }
}

@end
