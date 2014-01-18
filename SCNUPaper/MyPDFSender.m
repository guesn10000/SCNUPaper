//
//  MyPDFSender.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-22.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "MyPDFSender.h"
#import "ZipArchive/ZipArchive.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "Cookies.h"
#import "JCFilePersistence.h"
#import "JCAlert.h"
#import "URLConnector.h"
#import "Stroke.h"
#import "CommentStroke.h"
#import "MyPDFPage.h"
#import "PDFScrollView.h"
#import "TiledPDFView.h"
#import "MainPDFViewController.h"

@interface MyPDFSender ()

@end

@implementation MyPDFSender

#define ADD_TEXT_IMG  [UIImage imageNamed:@"addText.png"]
#define ADD_VOICE_IMG [UIImage imageNamed:@"addVoice.jpg"]
#define ANNO_SIZE 30.0

CGFloat tempHeight;

#pragma mark - Create PDF file and upload files

- (void)createNewPDFFile {
    // 1.获取基本参数
    AppDelegate *appDelegate = APPDELEGATE;
    
    // 2.创建media box
    MyPDFPage *tempPDFPage;
    PDFScrollView *tempPDFScrollView;
    NSArray *viewsForPDFScrollView = appDelegate.mainPDFViewController.viewsForThesisPages;
    tempPDFScrollView = viewsForPDFScrollView[0];
    tempPDFPage = tempPDFScrollView.myPDFPage;
    CGRect originRect = CGPDFPageGetBoxRect(tempPDFPage.pdfPageRef, kCGPDFMediaBox);
    CGFloat myPageWidth = originRect.size.width;
    CGFloat myPageHeight = originRect.size.height;
    CGRect mediaBox = CGRectMake (0, 0, myPageWidth, myPageHeight);
    tempHeight = mediaBox.size.height;
    
    // 3.设置pdf文档存储的路径
    
    // 目录： Document / Username / PureFileName / PDF / PDFFileName
    NSString *pdfDirectory = [appDelegate.cookies getPDFFolderDirectory];
    NSString *tempPDFFilePath = [appDelegate.filePersistence getDirectoryInDocumentWithName:pdfDirectory];
    NSString *pdfFileName = appDelegate.cookies.pdfFileName;
    NSString *pdfFilePath = [tempPDFFilePath stringByAppendingPathComponent:pdfFileName];
    
    const char *cPDFFilePath = [pdfFilePath UTF8String];
    CFStringRef pathRef = CFStringCreateWithCString(NULL, cPDFFilePath, kCFStringEncodingUTF8);
    
    
    // 生成时间戳
    NSDateFormatter *fileNameFormatter = [[NSDateFormatter alloc] init];
    [fileNameFormatter setDateFormat:@"yyyyMMddhhmmss"];
    NSString *timeStamp = [fileNameFormatter stringFromDate:[NSDate date]];
    
    
    // 4.设置当前pdf页面的属性
    CFStringRef myKeys[3];
    CFTypeRef myValues[3];
    myKeys[0] = kCGPDFContextMediaBox;
    myValues[0] = (CFTypeRef) CFDataCreate(NULL,(const UInt8 *)&mediaBox, sizeof (CGRect));
    // 用时间戳给context title签名，用于文件名同名的情况下进行配对
    myKeys[1] = kCGPDFContextTitle;
    myValues[1] = (__bridge CFStringRef)timeStamp; // 用时间戳给文件签名
    myKeys[2] = kCGPDFContextCreator;
    myValues[2] = CFSTR("Jymn_Chen");
    CFDictionaryRef pageDictionary;
    CGFloat widthScale  = mediaBox.size.width / tempPDFScrollView.frame.size.width;
    CGFloat heightScale = mediaBox.size.height / tempPDFScrollView.frame.size.height;
    CGFloat pageScale   = MIN(widthScale, heightScale);
    
    
    // 5.获取pdf绘图上下文
    CGContextRef myPDFContext = MyPDFContextCreate(&mediaBox, pathRef);
    
    
    // 6.开始绘图
    for (PDFScrollView *pdfScrollView in viewsForPDFScrollView) {
        pageDictionary = NULL;
        CFDictionaryRef pageDictionary = CFDictionaryCreate(NULL, (const void **) myKeys, (const void **) myValues, 3,
                                                            &kCFTypeDictionaryKeyCallBacks, & kCFTypeDictionaryValueCallBacks);
        
        
        // 6.1 Draw pdf page
        CGPDFContextBeginPage(myPDFContext, pageDictionary);
        CGContextSetRGBFillColor(myPDFContext, 1.0, 1.0, 1.0, 1.0);
        CGContextFillRect(myPDFContext, pdfScrollView.bounds);
        
        CGContextSaveGState(myPDFContext);
        CGContextDrawPDFPage(myPDFContext, pdfScrollView.myPDFPage.pdfPageRef);
        CGContextRestoreGState(myPDFContext);
        
        
        // 6.2 Draw停留在本页上的点集
        CGContextSaveGState(myPDFContext);
        CGContextTranslateCTM(myPDFContext, 0.0, mediaBox.size.height);
        CGContextScaleCTM(myPDFContext, 1.0, -1.0);
        CGContextScaleCTM(myPDFContext, pageScale, pageScale);
        
        // 笔注部分
        create_drawDrawStrokes(myPDFContext, pdfScrollView.myPDFPage.previousDrawStrokes);
        
        // 批注部分
        for (int i = 0; i < pdfScrollView.myPDFPage.previousStrokesForComments.count; i++) {
            CommentStroke *commStroke = [pdfScrollView.myPDFPage.previousStrokesForComments objectAtIndex:i];
            NSMutableArray *frames = commStroke.frames;
            
            NSInteger type = 0;
            if (commStroke.hasTextAnnotation && commStroke.hasVoiceAnnotation) {
                type = 3;
            }
            else if (commStroke.hasVoiceAnnotation) {
                type = 2;
            }
            else if (commStroke.hasTextAnnotation) {
                type = 1;
            }
            
            create_drawCommentFrames(myPDFContext, frames, type);
        }
        
        CGPDFContextEndPage(myPDFContext);
        CGContextRestoreGState(myPDFContext);
        
        CFRelease(pageDictionary);
    }
    
    
    // 7.释放创建的对象
    CFRelease(myValues[0]);
    CGContextRelease(myPDFContext);
}

CGContextRef MyPDFContextCreate(const CGRect *inMediaBox, CFStringRef path) {
    CGContextRef myOutContext = NULL;
    CFURLRef url;
    CGDataConsumerRef dataConsumer;
    
    url = CFURLCreateWithFileSystemPath (NULL, path, kCFURLPOSIXPathStyle, false);
    
    if (url != NULL)
    {
        dataConsumer = CGDataConsumerCreateWithURL(url);
        if (dataConsumer != NULL)
        {
            myOutContext = CGPDFContextCreate (dataConsumer, inMediaBox, NULL);
            CGDataConsumerRelease (dataConsumer);
        }
        CFRelease(url);
    }
    return myOutContext;
}

/* draw笔注的所有笔画 */
void create_drawDrawStrokes(CGContextRef context, NSMutableArray *drawStrokes) {
    if (drawStrokes && drawStrokes.count > 0) {
        for (Stroke *stroke in drawStrokes) {
            NSMutableArray *points = stroke.points;
            UIColor        *color  = stroke.color;
            CGFloat         width  = stroke.width;
            
            if (points && points.count > 0) {
                UIBezierPath *linesPath = [UIBezierPath bezierPath];
                CGPoint startPoint = CGPointFromString(points[0]);
                [linesPath moveToPoint:startPoint];
                
                for (int i = 1; i < points.count; i++) {
                    CGPoint nextPoint = CGPointFromString(points[i]);
                    [linesPath addLineToPoint:nextPoint];
                }
                
                CGContextAddPath(context, linesPath.CGPath);
                CGContextSetStrokeColorWithColor(context, color.CGColor);
                CGContextSetLineWidth(context, width);
                CGContextSetLineCap(context, kCGLineCapRound);
                CGContextSetLineJoin(context, kCGLineJoinRound);
                CGContextDrawPath(context, kCGPathStroke);
            }
        }
    }
}

/* draw批注对应的边界 */
void create_drawCommentFrames(CGContextRef context, NSMutableArray *frames, NSInteger type) {
    for (int j = 0; j < frames.count; j++) {
        NSString *frame = [frames objectAtIndex:j];
        CGRect rect = CGRectFromString(frame);
        CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
        CGContextAddRect(context, rect);
        CGContextSetFillColorWithColor(context, COMMENT_STROKE_COLOR.CGColor);
        CGContextSetLineWidth(context, COMMENT_STROKE_WIDTH);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextDrawPath(context, kCGPathFill);
        drawAnnotationViews(context, type, rect);
    }
}

void drawAnnotationViews(CGContextRef context, NSInteger type, CGRect rect) {
    CGRect rect1 = CGRectMake(rect.origin.x, tempHeight - rect.origin.y, ANNO_SIZE, ANNO_SIZE);
    CGRect rect2 = CGRectMake(rect.origin.x + ANNO_SIZE, tempHeight - rect.origin.y - ANNO_SIZE, ANNO_SIZE, ANNO_SIZE);
    
    if (type == 1) {
        CGContextDrawImage(context, rect1, [ADD_TEXT_IMG CGImage]);
    }
    else if (type == 2) {
        CGContextDrawImage(context, rect1, [ADD_VOICE_IMG CGImage]);
    }
    else if (type == 3) {
        CGContextDrawImage(context, rect1, [ADD_TEXT_IMG CGImage]);
        CGContextDrawImage(context, rect2, [ADD_VOICE_IMG CGImage]);
    }
}

- (void)uploadFilesToServer {
    // 1.初始化各个参数
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    
    // 2.定位文件夹路径，所有要上传的文件位于Document / Username / PureFileName / PDF /
    NSString *folderDirectory = [NSString stringWithFormat:@"%@/%@/%@", appDelegate.cookies.username, appDelegate.cookies.pureFileName, PDF_FOLDER_NAME];
    NSString *folderPath = [appDelegate.filePersistence getDirectoryInDocumentWithName:folderDirectory];
    
    
    // 3.压缩文件夹中的所有文件
    NSString *zipFilePath = [self zipFilesInPath:folderPath];
    
    
    // 4.将打包后的zip文件上传到服务器
    [appDelegate.urlConnector uploadFileInPath:zipFilePath toServerInFolder:appDelegate.cookies.pureFileName];
    
    
    // 5.上传成功后删除zip文件
    // 该动作由urlconnection的delegate调用完成
    
    
    // 6.上传新创建的pdf文件到pureFileName_created文件夹
    NSString *pdfFilePath = [folderPath stringByAppendingPathComponent:appDelegate.cookies.pdfFileName];
    NSString *createdPDFFolder = [appDelegate.cookies.pureFileName stringByAppendingString:@"_created"];
    [appDelegate.urlConnector uploadFileInPath:pdfFilePath toServerInFolder:createdPDFFolder];
}


#pragma mark - Zip files

/* 将folderPath中的文件全部打包成zip文件 */
- (NSString *)zipFilesInPath:(NSString *)folderPath {
    
    // 1.设置基本参数
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    ZipArchive *zipArchiver = [[ZipArchive alloc] init];
    
    
    // 压缩步骤（Documents / Username / PureFileName / PDF / 目录下）：
    // (1)先压缩Text文件夹
    // (2)再压缩Voice文件夹
    // (3)后压缩MP3文件夹
    // (4)接着压缩CommentRects和CommentStrokes文件夹
    // (5)最后压缩Text.zip  Voice.zip  MP3.zip  CommentRects.zip  CommentStrokes.zip  DrawStrokes.zip 和 PureFileName.pdf 及 AnnotationKeys.plist到一个zip中
    
    // 2.定位文件夹路径，所有要上传的文件位于Document / Username / PureFileName / PDF /
    NSString *textFolderPath            = [folderPath stringByAppendingPathComponent:TEXT_FOLDER_NAME];
    NSString *voiceFolderPath           = [folderPath stringByAppendingPathComponent:VOICE_FOLDER_NAME];
    NSString *mp3FolderPath             = [folderPath stringByAppendingPathComponent:MP3_FOLDER_NAME];
    NSString *drawStrokesFolderPath     = [folderPath stringByAppendingPathComponent:DRAW_STROKES_FOLDER_NAME];
    NSString *commentStrokesFolderPath  = [folderPath stringByAppendingPathComponent:COMMENT_STROKES_FOLDER_NAME];
    
    
    // 3.压缩子文件夹
    NSString *textZipFilePath           = [self zipFilesInSubPath:textFolderPath];
    NSString *voiceZipFilePath          = [self zipFilesInSubPath:voiceFolderPath];
    NSString *mp3ZipFilePath            = [self zipFilesInSubPath:mp3FolderPath];
    NSString *drawStrokesZipFilePath    = [self zipFilesInSubPath:drawStrokesFolderPath];
    NSString *commentStrokesZipFilePath = [self zipFilesInSubPath:commentStrokesFolderPath];
    
    
    // 4.开始压缩所有文件
    NSString *zipFileName = appDelegate.cookies.zipFileName;
    NSString *zipFilePath = [appDelegate.filePersistence getDirectoryOfDocumentFileWithName:zipFileName];
    BOOL isSuccessful = [zipArchiver CreateZipFile2:zipFilePath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *keysPlistFilePath = [folderPath stringByAppendingPathComponent:ANNOTATION_KEYS_FILENAME];
    if (![fileManager fileExistsAtPath:keysPlistFilePath isDirectory:NO]) {
        keysPlistFilePath = nil;
    }
    
    if (textZipFilePath && [fileManager fileExistsAtPath:textZipFilePath isDirectory:NO]) {
        [zipArchiver addFileToZip:textZipFilePath newname:@"Text.zip"];
    }
    
    if (voiceZipFilePath && [fileManager fileExistsAtPath:voiceZipFilePath isDirectory:NO]) {
        [zipArchiver addFileToZip:voiceZipFilePath newname:@"Voice.zip"];
    }
    
    if (mp3ZipFilePath && [fileManager fileExistsAtPath:mp3ZipFilePath isDirectory:NO]) {
        [zipArchiver addFileToZip:mp3ZipFilePath newname:@"MP3.zip"];
    }
    
    if (commentStrokesZipFilePath && [fileManager fileExistsAtPath:commentStrokesZipFilePath isDirectory:NO]) {
        [zipArchiver addFileToZip:commentStrokesZipFilePath newname:@"CommentStrokes.zip"];
    }
    
    if (drawStrokesZipFilePath && [fileManager fileExistsAtPath:drawStrokesZipFilePath isDirectory:NO]) {
        [zipArchiver addFileToZip:drawStrokesZipFilePath newname:@"DrawStrokes.zip"];
    }
    
    if (keysPlistFilePath && [fileManager fileExistsAtPath:keysPlistFilePath isDirectory:NO]) {
        [zipArchiver addFileToZip:keysPlistFilePath newname:ANNOTATION_KEYS_FILENAME];
    }
    
    
    // 5.关闭创建的zip文件
    if (![zipArchiver CloseZipFile2]) {
        zipFilePath = @"";
    }
    
    if (isSuccessful) {
        return zipFilePath;
    }
    else {
        [JCAlert alertWithMessage:@"压缩文件失败"];
        return nil;
    }
}

- (NSString *)zipFilesInSubPath:(NSString *)subPath {
    // 1.设置基本参数
    NSFileManager *fileManager = [NSFileManager defaultManager];
    ZipArchive *zipArchiver = [[ZipArchive alloc] init];
    AppDelegate *appDelegate = APPDELEGATE;
    
    
    // 2.获取文件夹中所有文件
    NSArray *filesInFolder = [fileManager contentsOfDirectoryAtPath:subPath error:NULL];
//    NSLog(@"files = %@", filesInFolder);
    
    if (filesInFolder && filesInFolder.count > 0) {
        
        // 3.设置zip文件的存放路径
        NSString *folderName = [subPath lastPathComponent];
        NSString *zipFileName = [folderName stringByAppendingString:ZIP_SUFFIX];
        NSString *zipFilePath = [appDelegate.filePersistence getDirectoryOfDocumentFileWithName:zipFileName];
        
        
        // 4.开始zip
        BOOL isSuccessful = [zipArchiver CreateZipFile2:zipFilePath];
        for (NSString *file in filesInFolder) {
            NSString *eachFilePath = [subPath stringByAppendingString:[NSString stringWithFormat:@"/%@", file]];
//            NSLog(@"eachFilePath = %@", eachFilePath);
            NSString *nFileName = [file stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if ([fileManager fileExistsAtPath:eachFilePath isDirectory:NO]) {
                isSuccessful = [zipArchiver addFileToZip:eachFilePath newname:nFileName];
            }
        }
        
        
        // 5.关闭创建的zip文件
        if (![zipArchiver CloseZipFile2]) {
            zipFilePath = @"";
        }
        
        if (isSuccessful) {
            return zipFilePath;
        }
        else {
            [JCAlert alertWithMessage:@"压缩文件失败"];
            return nil;
        }
    }
    else {
        return nil;
    }
}


#pragma mark - Unzip fils

- (void)unzipFilesInPath:(NSString *)zipFilePath {
    // 1.获取基本参数
    ZipArchive *zipUnarchiver          = [[ZipArchive alloc] init];
    AppDelegate *appDelegate           = [[UIApplication sharedApplication] delegate];
    JCFilePersistence *filePersistence = [[JCFilePersistence alloc] init];
    
    
    // 2.解压文件
    if (zipFilePath && [zipUnarchiver UnzipOpenFile:zipFilePath]) {
        // 文件解压的目标路径
        NSString *unzipPath = [filePersistence getDirectoryOfDocumentFolder];
        
        // 设定解压后文件的存放目录
        NSString *pdfFileDirectory = [NSString stringWithFormat:@"%@/%@/%@", appDelegate.cookies.username, appDelegate.cookies.pureFileName, PDF_FOLDER_NAME];
        NSString *pdfFilePath = [filePersistence getDirectoryInDocumentWithName:pdfFileDirectory];
        
        // 开始解压
        if([zipUnarchiver UnzipFileTo:unzipPath overWrite:YES]) {
            // AnnotationKey.plist
            NSString *srcPlistFilePath = [unzipPath   stringByAppendingPathComponent:ANNOTATION_KEYS_FILENAME];
            NSString *desPlistFilePath = [pdfFilePath stringByAppendingPathComponent:ANNOTATION_KEYS_FILENAME];
            [self moveSourceFileInPath:srcPlistFilePath toDestinationFilePath:desPlistFilePath];
            
            // Text Folder
            NSString *textFolderPath = [unzipPath stringByAppendingPathComponent:
                                        [NSString stringWithFormat:@"%@.zip", TEXT_FOLDER_NAME]
                                        ];
            [self unzipFilesInSubPath:textFolderPath];
            
            // Voice Folder
            NSString *voiceFolderPath = [unzipPath stringByAppendingPathComponent:
                                         [NSString stringWithFormat:@"%@.zip", VOICE_FOLDER_NAME]
                                         ];
            [self unzipFilesInSubPath:voiceFolderPath];
            
            
            // MP3 Folder
            NSString *mp3FolderPath = [unzipPath stringByAppendingPathComponent:
                                       [NSString stringWithFormat:@"%@.zip", MP3_FOLDER_NAME]
                                       ];
            [self unzipFilesInSubPath:mp3FolderPath];
            
            
            // DrawStrokes Folder
            NSString *drawStrokesFolderPath = [unzipPath stringByAppendingPathComponent:
                                               [NSString stringWithFormat:@"%@.zip", DRAW_STROKES_FOLDER_NAME]
                                               ];
            [self unzipFilesInSubPath:drawStrokesFolderPath];
            
            // CommentStrokes Folder
            NSString *commentStrokesFolderPath = [unzipPath stringByAppendingPathComponent:
                                                  [NSString stringWithFormat:@"%@.zip", COMMENT_STROKES_FOLDER_NAME]
                                                  ];
            [self unzipFilesInSubPath:commentStrokesFolderPath];
            
            
            // 关闭zip文件
            [zipUnarchiver UnzipCloseFile];
        }
    }
}

- (void)unzipFilesInSubPath:(NSString *)subFilePath {
    ZipArchive *zipUnarchiver = [[ZipArchive alloc] init];
    JCFilePersistence *filePersistence = [[JCFilePersistence alloc] init];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *folderName = [subFilePath lastPathComponent];
    folderName = [folderName substringToIndex:folderName.length - 4];
    
    if (![fileManager fileExistsAtPath:subFilePath isDirectory:NO]) {
        return;
    }
    
    
    if ([zipUnarchiver UnzipOpenFile:subFilePath]) {
        
        NSString *unzipDirectory = [NSString stringWithFormat:@"%@/%@/%@/%@", appDelegate.cookies.username, appDelegate.cookies.pureFileName, PDF_FOLDER_NAME, folderName];
        NSString *unzipPath = [filePersistence getDirectoryInDocumentWithName:unzipDirectory];
        if ([zipUnarchiver UnzipFileTo:unzipPath overWrite:YES]) {
            [zipUnarchiver UnzipCloseFile];
        }
        
    }
}

- (void)moveSourceFileInPath:(NSString *)srcFilePath toDestinationFilePath:(NSString *)desFilePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:srcFilePath isDirectory:NO]) {
        if ([fileManager fileExistsAtPath:desFilePath isDirectory:NO]) {
            [fileManager removeItemAtPath:desFilePath error:nil];
        }
        
        [fileManager moveItemAtPath:srcFilePath toPath:desFilePath error:nil];
    }
}

@end
