//
//  Comments.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-19.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CommentsMenu;

@interface Comments : NSObject <UITableViewDataSource>

@property (assign, nonatomic) size_t currentPageIndex;

@property (assign, nonatomic) NSUInteger currentButtonKey;

@property (assign, nonatomic) NSInteger currentRow;

@property (strong, nonatomic) NSString *currentText;

@property (strong, nonatomic) NSMutableArray *textComments;

@property (strong, nonatomic) NSMutableArray *voiceComments;

+ (void)showCommentsWithPage:(size_t)pageIndex Key:(NSInteger)buttonKey;

@end
