//
//  Recorder.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 14-1-17.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//

#import "Recorder.h"
#import "lame.h"
#import "AppDelegate.h"
#import "Cookies.h"
#import "KeyGeneraton.h"
#import "Constants.h"
#import "Comments.h"
#import "JCAlert.h"
#import "JCFilePersistence.h"
#import "MyPDFAnnotation.h"
#import "MainPDFViewController.h"

#pragma mark - Constants

static const int   Record_EncoderBitRate   = 16;
static const int   Record_NumberOfChannels = 2;
static const float Record_SampleRateKey    = 44100.0;

@interface Recorder ()

#pragma mark - Private

/* 负责录音功能 */
@property (strong, nonatomic) AVAudioRecorder *avrecorder_;

/* 当前录音按钮的点击次数，用于控制录音和重新录音 */
@property (assign, nonatomic) NSUInteger clicksOfRecorderButton_;

/* 录音后caf和mp3文件的信息 */
@property (strong, nonatomic) NSURL *cafFileURL;
@property (strong, nonatomic) NSURL *mp3FileURL;

@property (strong, nonatomic) NSString *cafFileName;
@property (strong, nonatomic) NSString *mp3FileName;

@end

@implementation Recorder

#pragma mark - Initialization

- (id)init {
    self = [super init];
    
    if (self) {
        self.isRecording = NO;
        self.clicksOfRecorderButton_ = 0;
        self.avrecorder_ = nil;
        
        self.cafFileName = @"";
        self.mp3FileName = @"";
        
        self.cafFileURL  = nil;
        self.mp3FileURL  = nil;
    }
    
    return self;
}

#pragma mark - Record

/* 录音或完成录音 */
- (void)doRecording {
    self.clicksOfRecorderButton_++;
    
    if (self.clicksOfRecorderButton_ >= 3)
    {
        self.clicksOfRecorderButton_ = 1;
        if (self.mp3FileURL || self.cafFileURL)
        {
            NSError *removeCAFError = nil;
            NSError *removeMP3Error = nil;
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm removeItemAtURL:self.cafFileURL error:&removeCAFError];
            [fm removeItemAtURL:self.mp3FileURL error:&removeMP3Error];
            if (removeCAFError)
            {
                [JCAlert alertWithMessage:@"移除caf文件出错" Error:removeCAFError];
            }
            if (removeMP3Error)
            {
                [JCAlert alertWithMessage:@"移除mp3文件出错" Error:removeMP3Error];
            }
        }
    }
    
    JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
    //  开始录音或完成录音
    if (!self.isRecording) { // Start to record
        self.isRecording = YES;
        
        // 用时间戳为caf文件签名，并保存对应信息
        NSError *error = nil;
        NSDateFormatter *fileNameFormatter = [[NSDateFormatter alloc] init];
        [fileNameFormatter setDateFormat:@"yyyyMMddhhmmss"];
        
        self.cafFileName      = [[fileNameFormatter stringFromDate:[NSDate date]] stringByAppendingString:@".caf"];
        NSString *cafFilePath = [[filePersistence getDirectoryOfDocumentFolder] stringByAppendingPathComponent:self.cafFileName];
        self.cafFileURL       = [NSURL fileURLWithPath:cafFilePath];
        
        
        // 设置录音参数，并开始录音
        NSDictionary *recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInt:AVAudioQualityMin],        AVEncoderAudioQualityKey, // 录音品质
                                       [NSNumber numberWithInt:Record_EncoderBitRate],    AVEncoderBitRateKey,      // 编码速率
                                       [NSNumber numberWithInt: Record_NumberOfChannels], AVNumberOfChannelsKey,    // 频道数
                                       [NSNumber numberWithFloat:Record_SampleRateKey],   AVSampleRateKey,          // 采样速率
                                       nil];
        self.avrecorder_ = [[AVAudioRecorder alloc] initWithURL:self.cafFileURL settings:recordSetting error:&error];
        if (!error) {
            [self.avrecorder_ setDelegate:self];
            [self.avrecorder_ prepareToRecord];
            self.avrecorder_.meteringEnabled = YES;  // 开启音量检测
            
            // 开始录音
            [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
            [self.avrecorder_ record];
        }
        else {
            [JCAlert alertWithMessage:@"录音出错" Error:error];
        }
    }
    else { // Finish recording
        // 将caf转换为m3
        [self convertCAFtoMP3];
        
        // 设置参数
        self.isRecording = NO;
        self.cafFileURL  = nil;
        [self.avrecorder_ stop];
        self.avrecorder_   = nil;
    }
}

/* 将caf文件转换为mp3文件 */
- (void)convertCAFtoMP3 {
    JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
    
    NSDateFormatter *fileNameFormat=[[NSDateFormatter alloc] init];
    [fileNameFormat setDateFormat:@"yyyyMMddhhmmss"];
    
    //  -- 设置mp3文件路径 --
    self.mp3FileName = [[fileNameFormat stringFromDate:[NSDate date]] stringByAppendingString:@".mp3"];
    NSString *mp3FilePath = [[filePersistence getDirectoryOfDocumentFolder] stringByAppendingPathComponent:self.mp3FileName];
    self.mp3FileURL = [NSURL fileURLWithPath:mp3FilePath];
    
    //  -- 获取caf文件路径 --
    NSString *cafFilePath = [[filePersistence getDirectoryOfDocumentFolder] stringByAppendingPathComponent:self.cafFileName];
    
    
    //  -- 开始转换 --
    @try {
        int read, write;
        
        //        NSLog(@"caffp = %@", cafFilePath);
        //        NSLog(@"mp3fp = %@", mp3FilePath);
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");//被转换的文件
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");//转换后文件的存放位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 44100);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        
        if(self.mp3FileURL && self.cafFileURL) {
            //  -- 移除caf文件 --
            NSError *error = nil;
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm removeItemAtURL:self.cafFileURL error:&error];
            if (error) {
                NSString *errorInfo = [NSString stringWithFormat:@"移除caf文件出错:%@", [error localizedDescription]];
                [JCAlert alertWithMessage:errorInfo];
            }
        }
    }
}

#pragma mark - Handle Recorded Voice

- (void)saveRecordVoiceForPDFAnnotaton:(MyPDFAnnotation *)pdfAnnotation toFolder:(NSString *)folderName {
    AppDelegate *appDelegate = APPDELEGATE;
    JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 1.将mp3文件移到Documents/Username/Foldername/PDF/MP3目录下
    NSString *srcMP3FilePath = [filePersistence getDirectoryOfDocumentFileWithName:self.mp3FileName];
    NSString *desMP3FileDirectory = [NSString stringWithFormat:@"%@/%@/%@/%@",
                                     appDelegate.cookies.username, folderName, PDF_FOLDER_NAME, MP3_FOLDER_NAME];
    NSString *desMP3FilePath = [filePersistence getDirectoryInDocumentWithName:[NSString stringWithFormat:@"%@/%@", desMP3FileDirectory, self.mp3FileName]];
    
    // 如果文件存在于目标路径中，先将其移除
    if ([fileManager fileExistsAtPath:desMP3FilePath isDirectory:NO]) {
        [fileManager removeItemAtPath:desMP3FilePath error:nil];
    }
    
    // 从源路径移动到目标路径
    NSError *error = nil;
    [fileManager moveItemAtPath:srcMP3FilePath toPath:desMP3FilePath error:&error];
    
    
    // 2.获取plist文件名：PageIndex_CommentAnnotationKey_voice.plist
    NSString *plistFileName = [NSString stringWithFormat:@"%zu_%d_voice.plist", pdfAnnotation.inPageIndex, pdfAnnotation.commentAnnotationKey];
    
    // 完整路径：Document / Username / PureFileName / PDF / Voice / PageIndex_ButtonKey_voice.plist
    NSString *plistFileDirectory = [NSString stringWithFormat:@"%@/%@/%@/%@", appDelegate.cookies.username, folderName, PDF_FOLDER_NAME, VOICE_FOLDER_NAME];
    
    
    // 3.从文件中加载数组数据，将mp3文件路径加入数组中
    NSMutableArray *voiceArray = [filePersistence loadMutableArrayFromFile:plistFileName inDocumentWithDirectory:plistFileDirectory];
    if (!voiceArray) {
        voiceArray = [[NSMutableArray alloc] init];
    }
    [voiceArray addObject:self.mp3FileName];
    
    
    // 4.将数组写回文件中
    [filePersistence saveMutableArray:voiceArray toFile:plistFileName inDocumentWithDirectory:plistFileDirectory];
    
    
    // 5.保存每一页的annotationkey
    [appDelegate.keyGeneration updateAnnotationKeysWithDocumentName:appDelegate.cookies.pureFileName];
    
    
    // 6.重置参数
    [self resetDefaults];
}

/* 删除当前的录音文件 */
- (void)unsaveRecordVoice {
    JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *mp3FilePath = [filePersistence getDirectoryOfDocumentFileWithName:self.mp3FileName];
    if ([fileManager fileExistsAtPath:mp3FilePath]) {
        [fileManager removeItemAtPath:mp3FilePath error:nil];
    }
    
    [self resetDefaults];
}

/* 重置参数 */
- (void)resetDefaults {
    self.isRecording             = NO;
    self.clicksOfRecorderButton_ = 0;
    self.avrecorder_             = nil;
    
    self.cafFileName = @"";
    self.mp3FileName = @"";
    
    self.cafFileURL = nil;
    self.mp3FileURL = nil;
}

- (void)addNewRecordVoiceToFolder:(NSString *)folderName Page:(size_t)pageIndex Key:(NSInteger)key {
    AppDelegate *appDelegate = APPDELEGATE;
    JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 1.将mp3文件移到Documents/Username/Foldername/PDF/MP3目录下
    NSString *srcMP3FilePath = [filePersistence getDirectoryOfDocumentFileWithName:self.mp3FileName];
    NSString *desMP3FileDirectory = [NSString stringWithFormat:@"%@/%@/%@/%@",
                                     appDelegate.cookies.username, folderName, PDF_FOLDER_NAME, MP3_FOLDER_NAME];
    NSString *desMP3FilePath = [filePersistence getDirectoryInDocumentWithName:[NSString stringWithFormat:@"%@/%@", desMP3FileDirectory, self.mp3FileName]];
    
    // 如果文件存在于目标路径中，先将其移除
    if ([fileManager fileExistsAtPath:desMP3FilePath isDirectory:NO]) {
        [fileManager removeItemAtPath:desMP3FilePath error:nil];
    }
    
    // 从源路径移动到目标路径
    NSError *error = nil;
    [fileManager moveItemAtPath:srcMP3FilePath toPath:desMP3FilePath error:&error];
    
    
    // 2.获取plist文件名：PageIndex_CommentAnnotationKey_voice.plist
    NSString *plistFileName = [NSString stringWithFormat:@"%zu_%d_voice.plist", pageIndex, key];
    
    // 完整路径：Document / Username / PureFileName / PDF / Voice / PageIndex_ButtonKey_voice.plist
    NSString *plistFileDirectory = [NSString stringWithFormat:@"%@/%@/%@/%@", appDelegate.cookies.username, folderName, PDF_FOLDER_NAME, VOICE_FOLDER_NAME];
    
    
    // 3.从文件中加载数组数据，将mp3文件路径加入数组中
    NSMutableArray *voiceArray = [filePersistence loadMutableArrayFromFile:plistFileName inDocumentWithDirectory:plistFileDirectory];
    if (!voiceArray) {
        voiceArray = [[NSMutableArray alloc] init];
    }
    [voiceArray addObject:self.mp3FileName];
    
    
    // 4.将数组写回文件中
    [filePersistence saveMutableArray:voiceArray toFile:plistFileName inDocumentWithDirectory:plistFileDirectory];
    
    
    // 5.重置参数
    [self resetDefaults];
}

@end
