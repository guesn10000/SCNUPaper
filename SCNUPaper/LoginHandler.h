//
//  LoginHandler.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-19.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class URLConnector;

@interface LoginHandler : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

- (id)initWithUsername:(NSString *)username Password:(NSString *)password;

@end
