//
//  UploadHandler.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-19.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadHandler : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

/* 判断上传文件后是否需要转换 */
@property (assign, nonatomic) BOOL needConvert;

- (id)initWithNeedConvert:(BOOL)need;

@end
