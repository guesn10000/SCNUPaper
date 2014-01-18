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

- (void)showComments {
    // 1.获取基本参数
    AppDelegate *appDelegate = APPDELEGATE;
    
    // 2.初始化Text Comments的数组
    NSString *textFileName = [NSString stringWithFormat:@"%zu_%d_text.plist", self.pageIndex, self.buttonKey];
    NSString *textFileDirectory = [NSString stringWithFormat:@"%@/%@/%@/%@", appDelegate.cookies.username, appDelegate.cookies.pureFileName, PDF_FOLDER_NAME, TEXT_FOLDER_NAME];
    NSMutableArray *textArray = [appDelegate.filePersistence loadMutableArrayFromFile:textFileName inDocumentWithDirectory:textFileDirectory];
    if (!textArray) {
        textArray = [[NSMutableArray alloc] init];
    }
    appDelegate.mainPDFViewController.allComments.textComments = [[NSMutableArray alloc] initWithArray:[textArray mutableCopy]];
    
    // 3.初始化Voice Comments的数组
    NSString *voiceFileName = [NSString stringWithFormat:@"%zu_%d_voice.plist", self.pageIndex, self.buttonKey];
    NSString *voiceFileDirectory = [NSString stringWithFormat:@"%@/%@/%@/%@", appDelegate.cookies.username, appDelegate.cookies.pureFileName, PDF_FOLDER_NAME, VOICE_FOLDER_NAME];
    NSMutableArray *voiceArray = [appDelegate.filePersistence loadMutableArrayFromFile:voiceFileName inDocumentWithDirectory:voiceFileDirectory];
    if (!voiceArray) {
        voiceArray = [[NSMutableArray alloc] init];
    }
    appDelegate.mainPDFViewController.allComments.voiceComments = [[NSMutableArray alloc] initWithArray:[voiceArray mutableCopy]];
    
    // 4.设置Comments table view的page index和button key
    appDelegate.mainPDFViewController.allComments.currentPageIndex = self.pageIndex;
    appDelegate.mainPDFViewController.allComments.currentButtonKey = self.buttonKey;
    
    // 5.显示Comments Table
    [appDelegate.mainPDFViewController checkComments];
}

@end
