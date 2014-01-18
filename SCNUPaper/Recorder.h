//
//  Recorder.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 14-1-17.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioServices.h>

@class MyPDFAnnotation;

@interface Recorder : NSObject <AVAudioRecorderDelegate, UIAlertViewDelegate>

/* YES表示正在录音，NO表示正在播音 */
@property (assign, nonatomic) BOOL isRecording;

/* 录音或完成录音 */
- (void)doRecording;

/* 保存音频的标记 */
- (void)saveRecordVoiceForPDFAnnotaton:(MyPDFAnnotation *)pdfAnnotation toFolder:(NSString *)folderName;

- (void)addNewRecordVoiceToFolder:(NSString *)folderName Page:(size_t)pageIndex Key:(NSInteger)key;

/* 取消保存录音文件记录 */
- (void)unsaveRecordVoice;

@end