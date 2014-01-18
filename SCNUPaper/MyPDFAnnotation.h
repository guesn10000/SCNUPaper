//
//  MyPDFAnnotation.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-20.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyPDFAnnotation : NSObject

@property (strong, nonatomic) NSMutableArray *commentAnnotationFrames;

@property (assign, nonatomic) NSUInteger commentAnnotationKey;

@property (assign, nonatomic) size_t inPageIndex;

@property (strong, nonatomic) NSMutableArray *buttonsForComments;

@property (strong, nonatomic) UIView *annotationView;

- (id)initWithFrames:(NSMutableArray *)frames
                 Key:(NSUInteger)keyNumber
           PageIndex:(size_t)pageIndex
      TextAnnotation:(BOOL)textAnno
     VoiceAnnotation:(BOOL)voiceAnno;

@end
