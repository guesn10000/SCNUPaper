//
//  RegistHandler.h
//  SCNUPaper
//
//  Created by Jymn_Chen on 14-2-18.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegistHandler : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

- (id)initWithUsername:(NSString *)aUsername Nickname:(NSString *)aNickname Password:(NSString *)aPassword;

@end
