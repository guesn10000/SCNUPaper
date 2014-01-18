//
//  MyPDFButton.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-20.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyPDFButton : NSObject

@property (strong, nonatomic) UIButton *myButton;

@property (assign, nonatomic) NSUInteger buttonKey;

@property (assign, nonatomic) size_t pageIndex;

@property (assign, nonatomic) CGRect defaultFrame;

- (id)initWithFrame:(CGRect)frame ButtonKey:(NSUInteger)key PageIndex:(NSUInteger)pageIndex;

- (void)addTargetForButton;

@end
