//
//  MyPDFAnnotation.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-20.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "MyPDFAnnotation.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "MyPDFButton.h"
#import "AnnotationViews.h"

@implementation MyPDFAnnotation

#pragma mark - Constants

//const NSInteger kTxtAnno    = 1;
//const NSInteger kVocAnno    = 2;
//const NSInteger kTxtVocAnno = 3;

#pragma mark - Initialization

- (id)initWithFrame:(NSString *)frame
                Key:(NSUInteger)keyNumber
          PageIndex:(size_t)pageIndex
     TextAnnotation:(BOOL)textAnno
    VoiceAnnotation:(BOOL)voiceAnno {
    
    self = [super init];
    
    if (self) {
        AppDelegate *appDelegate = APPDELEGATE;
        self.commentAnnotationFrame = frame;
        self.commentAnnotationKey = keyNumber;
        self.inPageIndex = pageIndex;
        
        NSInteger type = 0;
        if (textAnno && voiceAnno) {
            type = 3;
        }
        else if (voiceAnno) {
            type = 2;
        }
        else if (textAnno) {
            type = 1;
        }
        self.annotationView = [appDelegate.annoViewsProvider getAnnotationViewWithType:type];
        
        CGRect rect = CGRectFromString(frame);
        self.pdfButton = [[MyPDFButton alloc] initWithFrame:rect ButtonKey:keyNumber PageIndex:pageIndex];
    }
    
    return self;
    
}

@end
