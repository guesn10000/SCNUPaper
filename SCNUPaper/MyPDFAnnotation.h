//
//  MyPDFAnnotation.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-20.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MyPDFButton;
@class AnnotationView;

@interface MyPDFAnnotation : NSObject

@property (strong, nonatomic) NSString *commentAnnotationFrame;

@property (assign, nonatomic) NSUInteger commentAnnotationKey;

@property (assign, nonatomic) size_t inPageIndex;

@property (strong, nonatomic) MyPDFButton *pdfButton;

@property (strong, nonatomic) AnnotationView *annotationView;

- (id)initWithFrame:(NSString *)frame
                Key:(NSUInteger)keyNumber
          PageIndex:(size_t)pageIndex
     TextAnnotation:(BOOL)textAnno
    VoiceAnnotation:(BOOL)voiceAnno;

@end
