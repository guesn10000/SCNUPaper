//
//  VoicePlayer.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-24.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "VoicePlayer.h"
#import "AppDelegate.h"
#import "Cookies.h"
#import "Constants.h"
#import "JCFilePersistence.h"
#import "JCAlert.h"
#import "MainPDFViewController.h"

@interface VoicePlayer ()

@end

@implementation VoicePlayer

#pragma mark - Initialization

- (id)initWithCenter:(CGPoint)center {
    self = [super init];
    
    if (self) {
        AppDelegate *appDelegate = APPDELEGATE;
        
        self.playing_spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.playing_spinner.frame            = CGRectMake(0.0, 0.0, 60.0, 60.0);
        self.playing_spinner.center           = center;
        self.playing_spinner.hidesWhenStopped = YES;
        [appDelegate.window addSubview:self.playing_spinner];
        
        self.player = nil;
        self.isPlaying = NO;
    }
    
    return self;
}

#pragma mark - Play Voice

- (void)playRecordVoice:(NSString *)mp3FileName {
    AppDelegate *appDelegate = APPDELEGATE;
    JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
    
    appDelegate.window.alpha = UNABLE_VIEW_ALPHA;
    appDelegate.mainPDFViewController.view.userInteractionEnabled = NO;
    
    NSError *error = nil;
    NSString *mp3FileDirectory = [NSString stringWithFormat:@"%@/%@/%@/%@", appDelegate.cookies.username, appDelegate.cookies.pureFileName, PDF_FOLDER_NAME, MP3_FOLDER_NAME];
    mp3FileDirectory = [filePersistence getDirectoryInDocumentWithName:mp3FileDirectory];
    NSString *mp3FilePath = [mp3FileDirectory stringByAppendingPathComponent:mp3FileName];
    NSURL *url = [NSURL fileURLWithPath:mp3FilePath];
    if (url) {
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    }
    else {
        [JCAlert alertWithMessage:@"文件尚未保存完成，请稍后再试"];
    }
    
    if (error)
    {
        [JCAlert alertWithMessage:@"播放录音失败" Error:error];
        [self.playing_spinner stopAnimating];
        return;
    }
    self.player.delegate = self;
    
    [self.playing_spinner startAnimating];
    [self.player play];
}

- (void)stopRecordVoicePlaying {
    self.isPlaying = NO;
    [self.playing_spinner stopAnimating];
    [self.player stop]; // 停止播放
    self.player = nil;  // 释放player
    
    AppDelegate *appDelegate = APPDELEGATE;
    appDelegate.mainPDFViewController.stopPlaying_button.hidden = YES;
    appDelegate.mainPDFViewController.view.userInteractionEnabled = YES;
    appDelegate.window.alpha = DEFAULT_VIEW_ALPHA;
}

#pragma mark - Audio player delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self stopRecordVoicePlaying];
}

@end
