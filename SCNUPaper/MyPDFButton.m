//
//  MyPDFButton.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-20.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "MyPDFButton.h"
#import "AppDelegate.h"
#import "Cookies.h"
#import "Constants.h"
#import "CommentStroke.h"
#import "JCAlert.h"
#import "JCFilePersistence.h"
#import "Comments.h"
#import "MainPDFViewController.h"

@implementation MyPDFButton

- (id)initWithFrame:(CGRect)frame ButtonKey:(NSUInteger)key PageIndex:(NSUInteger)pageIndex {
    self = [super init];
    
    if (self) {
        self.myButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.myButton.backgroundColor = [UIColor clearColor];
        self.myButton.frame = frame;
        self.defaultFrame = frame;
        self.buttonKey = key;
        self.pageIndex = pageIndex;
    }
    
    return self;
}

- (void)addTargetForButton {
    [self.myButton addTarget:self action:@selector(showComments) forControlEvents:UIControlEventTouchUpInside];
}

- (void)removeTargetFromButton {
    [self.myButton removeTarget:self action:@selector(showComments) forControlEvents:UIControlEventTouchUpInside];
}

- (void)showComments {
    [Comments showCommentsWithPage:self.pageIndex Key:self.buttonKey];
}

@end
