//
//  MyPDFAnnotation.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-20.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "MyPDFAnnotation.h"
#import "MyPDFButton.h"
#import "AnnotationView.h"

@implementation MyPDFAnnotation

#pragma mark - Constants

static const NSUInteger kTxtPDFAnno    = 1;
static const NSUInteger kVocPDFAnno    = 2;
static const NSUInteger kTxtVocPDFAnno = 3;

#pragma mark - Initialization

- (id)initWithFrame:(NSString *)frame
              Scale:(CGFloat)convertScale
                Key:(NSUInteger)keyNumber
          PageIndex:(size_t)pageIndex
     TextAnnotation:(BOOL)textAnno
    VoiceAnnotation:(BOOL)voiceAnno {
    
    self = [super init];
    
    if (self) {
        self.commentAnnotationFrame = frame;
        self.commentAnnotationKey = keyNumber;
        self.inPageIndex = pageIndex;
        CGRect rect = CGRectFromString(frame);
        if (IS_IPHONE) {
            rect.origin.x    *= convertScale;
            rect.origin.y    *= convertScale;
            rect.size.width  *= convertScale;
            rect.size.height *= convertScale;
        }
        
        NSUInteger type = 0;
        if (textAnno && voiceAnno) {
            type = kTxtVocPDFAnno;
        }
        else if (voiceAnno) {
            type = kVocPDFAnno;
        }
        else if (textAnno) {
            type = kTxtPDFAnno;
        }
        self.annotationView = [[AnnotationView alloc] initWithFrame:rect AnnotationType:type];
        
        self.pdfButton = [[MyPDFButton alloc] initWithFrame:rect ButtonKey:keyNumber PageIndex:pageIndex];
    }
    
    return self;
    
}

@end
