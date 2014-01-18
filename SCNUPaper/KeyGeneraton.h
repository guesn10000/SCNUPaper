//
//  KeyGeneraton.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-20.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyGeneraton : NSObject

@property (strong, nonatomic) NSMutableDictionary *annotationKeys;

- (id)initWithDocumentName:(NSString *)documentName;

- (NSUInteger)getCommentAnnotationKeyWithPageIndex:(size_t)index;

- (void)increaseCommentAnnotationKeyinPageIndex:(size_t)index;

- (void)decreaseCommentAnnotationKeyinPageIndex:(size_t)index;

- (void)updateAnnotationKeysWithDocumentName:(NSString *)documentName;

@end
