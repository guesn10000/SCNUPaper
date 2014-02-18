//
//  KeyGeneraton.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-20.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "KeyGeneraton.h"
#import "AppDelegate.h"
#import "Cookies.h"
#import "Constants.h"
#import "JCFilePersistence.h"

@interface KeyGeneraton ()

@end

@implementation KeyGeneraton

- (id)initWithDocumentName:(NSString *)documentName {
    self = [super init];
    
    if (self) {
        AppDelegate *appDelegate = [AppDelegate sharedDelegate];
        JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
        
        // key file的位置：Document / Username / PureFileName / PDF / AnnotationKeys.plist
        NSString *keyFileDirectory = [NSString stringWithFormat:@"%@/%@/%@",
                                      appDelegate.cookies.username, documentName, PDF_FOLDER_NAME];
        self.annotationKeys = [filePersistence loadMutableDictionaryFromFile:ANNOTATION_KEYS_FILENAME inDocumentWithDirectory:keyFileDirectory];
        if (!self.annotationKeys) {
            self.annotationKeys = [[NSMutableDictionary alloc] init];
        }
    }
    
    return self;
}

- (NSUInteger)getCommentAnnotationKeyWithPageIndex:(size_t)index {
    NSString *key = [NSString stringWithFormat:@"%zu", index];
    NSString *currentKeyNumberString = [self.annotationKeys objectForKey:key];
    if (!currentKeyNumberString) {
        return 0;
    }
    else {
        return [currentKeyNumberString integerValue];
    }
}

- (void)increaseCommentAnnotationKeyinPageIndex:(size_t)index {
    NSString *key = [NSString stringWithFormat:@"%zu", index];
    NSString *keyNumberString = [self.annotationKeys objectForKey:key];
    NSUInteger keyNumber = [keyNumberString integerValue];
    keyNumber++;
    keyNumberString = [NSString stringWithFormat:@"%d", keyNumber];
    [self.annotationKeys setObject:keyNumberString forKey:key];
}

- (void)decreaseCommentAnnotationKeyinPageIndex:(size_t)index {
    NSString *key = [NSString stringWithFormat:@"%zu", index];
    NSString *keyNumberString = [self.annotationKeys objectForKey:key];
    NSUInteger keyNumber = [keyNumberString integerValue];
    keyNumber--;
    keyNumberString = [NSString stringWithFormat:@"%d", keyNumber];
    [self.annotationKeys setObject:keyNumberString forKey:key];
}

- (void)updateAnnotationKeysWithDocumentName:(NSString *)documentName {
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
    // key file的位置：Document / Username / PureFileName / PDF / AnnotationKeys.plist
    NSString *keyFileDirectory = [NSString stringWithFormat:@"%@/%@/%@",
                                  appDelegate.cookies.username, documentName, PDF_FOLDER_NAME];
    [filePersistence saveMutableDictionary:self.annotationKeys toFile:ANNOTATION_KEYS_FILENAME inDocumentWithDirectory:keyFileDirectory];
}

@end
