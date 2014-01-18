//
//  JCAlert.h
//  JuliaCoreFramework
//
//  Created by Jymn_Chen on 13-11-17.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JCAlert : NSObject

+ (void)alertWithMessage:(NSString *)message;

+ (void)alertWithError:(NSError *)error;

+ (void)alertWithMessage:(NSString *)message Error:(NSError *)error;

@end
