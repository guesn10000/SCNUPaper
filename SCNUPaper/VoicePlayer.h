//
//  VoicePlayer.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-24.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioServices.h>
#import <MediaPlayer/MediaPlayer.h>

@interface VoicePlayer : NSObject <AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioPlayer *player;
@property (assign, nonatomic) BOOL isPlaying;
@property (strong, nonatomic) UIActivityIndicatorView *playing_spinner;

- (id)initWithCenter:(CGPoint)center;

/* 点击批注表格后播放录音 */
- (void)playRecordVoice:(NSString *)mp3FileName;
- (void)stopRecordVoicePlaying;

@end
