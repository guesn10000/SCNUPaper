//
//  DownloadHandler.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-26.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadHandler : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

- (id)initWithFileType:(NSString *)fileType;

@end
