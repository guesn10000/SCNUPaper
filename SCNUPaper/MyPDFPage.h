//
//  MyPDFPage.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-19.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MyPDFAnnotation;

@interface MyPDFPage : NSObject

@property (assign, nonatomic) CGPDFPageRef pdfPageRef;

@property (assign, nonatomic) size_t pageIndex;

@property (assign, nonatomic) CGFloat convertScale;

- (id)initWithDocument:(CGPDFDocumentRef)pdfDocument PageIndex:(size_t)pageIndex;

- (void)reloadPDFPage;


/* Add Strokes部分 */
@property (strong, nonatomic) NSMutableArray *currentDrawStrokes;
@property (strong, nonatomic) NSMutableArray *previousDrawStrokes;


/* Add Comments部分 */
/*
 StrokesArray的数据结构
 - StrokesArray [
    CommentStroke0,
    CommentStroke1,
    ...
 ]
 */
@property (strong, nonatomic) NSMutableArray *previousStrokesForComments;



/*
 CommentAnnotations的数据结构：
 - CommentAnnotations (Array) [
    
    - Annotation0 {
        Rectangles (Array)
        AnnotationKey (int)
    }
 
    - Annotation1 {
        Rectangles (Array)
        AnnotationKey (int)
    }
 
 ]
 */
@property (strong, nonatomic) NSMutableArray *currentAnnotationsForComments;
@property (strong, nonatomic) NSMutableArray *previousAnnotationsForComments;

@end
