//
//  MyPDFCreator.m
//  SCNUPaper
//
//  Created by Jymn_Chen on 14-1-19.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//

#import "MyPDFCreator.h"
#import "ZipArchive/ZipArchive.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "Cookies.h"
#import "JCFilePersistence.h"
#import "JCAlert.h"
#import "URLConnector.h"
#import "Stroke.h"
#import "CommentStroke.h"
#import "MyPDFDocument.h"
#import "MyPDFPage.h"
#import "PDFScrollView.h"
#import "TiledPDFView.h"
#import "MainPDFViewController.h"

#define ADD_TEXT_IMG  [UIImage imageNamed:@"addText.png"]
#define ADD_VOICE_IMG [UIImage imageNamed:@"addVoice.jpg"]
#define ANNO_SIZE 30.0

@implementation MyPDFCreator

#pragma mark - Singleton

+ (instancetype)sharedInstance {
    static MyPDFCreator *creator = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        creator = [[super allocWithZone:NULL] init];
    });
    
    return creator;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark - Create PDF file and upload files

- (void)createNewPDFFile {
    // 1.获取基本参数
    AppDelegate *appDelegate = APPDELEGATE;
    JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
    
    // 2.创建media box
    PDFScrollView *tempPDFScrollView = [appDelegate.mainPDFViewController.viewsForThesisPages objectForKey:@"cur"];
    CGRect tempFrame = tempPDFScrollView.bounds;
    MyPDFDocument *tempDocument = appDelegate.mainPDFViewController.myPDFDocument;
    MyPDFPage *tempPDFPage = tempPDFScrollView.myPDFPage;
    CGRect  originRect   = CGPDFPageGetBoxRect(tempPDFPage.pdfPageRef, kCGPDFMediaBox);
    CGFloat myPageWidth  = originRect.size.width;
    CGFloat myPageHeight = originRect.size.height;
    CGRect  mediaBox     = CGRectMake(0, 0, myPageWidth, myPageHeight);
    
    // 3.设置pdf文档存储的路径
    
    // 目录： tmp / PDFFileName
    NSString *pdfFilePath = [filePersistence getDirectoryOfTmpFolder];
    pdfFilePath = [pdfFilePath stringByAppendingPathComponent:appDelegate.cookies.pdfFileName];
    
    const char *cPDFFilePath = [pdfFilePath UTF8String];
    CFStringRef pathRef = CFStringCreateWithCString(NULL, cPDFFilePath, kCFStringEncodingUTF8);
    
    
    // 4.设置当前pdf页面的属性
    CFStringRef myKeys[2];
    CFTypeRef myValues[2];
    myKeys[0]   = kCGPDFContextMediaBox;
    myValues[0] = (CFTypeRef) CFDataCreate(NULL,(const UInt8 *)&mediaBox, sizeof (CGRect));
    myKeys[1]   = kCGPDFContextCreator;
    myValues[1] = CFSTR("Jymn_Chen");
    CFDictionaryRef pageDictionary;
    CGFloat widthScale  = mediaBox.size.width  / tempPDFScrollView.frame.size.width;
    CGFloat heightScale = mediaBox.size.height / tempPDFScrollView.frame.size.height;
    CGFloat pageScale   = MAX(widthScale, heightScale); // 注意这里是maximum
    
    
    // 5.获取pdf绘图上下文
    CGContextRef myPDFContext = MyPDFContextCreate(&mediaBox, pathRef);
    
    
    // 6.开始绘图
    // 设置scroll view中的内容s
    for (int j = 1; j <= tempDocument.totalPages; j++) {
        CGRect tempRect = tempFrame;
        tempRect.origin.x = (j - 1) * tempFrame.size.width;
        PDFScrollView *pdfScrollView = [[PDFScrollView alloc] initWithFrame:tempRect
                                                                   Document:tempDocument.pdfDocumentRef
                                                                  PageIndex:j];
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
            
            create_drawCommentFrame(myPDFContext, commStroke.frame, type);
        }
        
        CGPDFContextEndPage(myPDFContext);
        CGContextRestoreGState(myPDFContext);
        
        CFRelease(pageDictionary);
    }
    
    
    // 7.释放创建的对象
    CGContextRelease(myPDFContext);
    CFRelease(myValues[0]);
    CFRelease(pathRef);
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
void create_drawCommentFrame(CGContextRef context, NSString *frame, NSInteger type) {
    CGRect rect = CGRectFromString(frame);
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
    CGContextAddRect(context, rect);
    CGContextSetFillColorWithColor(context, COMMENT_STROKE_COLOR.CGColor);
    CGContextSetLineWidth(context, COMMENT_STROKE_WIDTH);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextDrawPath(context, kCGPathFill);
    drawAnnotationViews(context, rect, type);
}

void drawAnnotationViews(CGContextRef context, CGRect rect, NSInteger type) {
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
    CGContextTranslateCTM(context, 0.0, ANNO_SIZE);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
    
    CGRect rect1 = CGRectMake(rect.origin.x, rect.origin.y, ANNO_SIZE, ANNO_SIZE);
    CGRect rect2 = CGRectMake(rect.origin.x + ANNO_SIZE, rect.origin.y, ANNO_SIZE, ANNO_SIZE);
    
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
    
    CGContextRestoreGState(context);
}

- (void)uploadFilesToServer {
    if (![URLConnector canConnectToSCNUServer]) {
        return;
    }
    
    // 1.初始化各个参数
    AppDelegate *appDelegate = APPDELEGATE;
    URLConnector *urlConnector = [URLConnector sharedInstance];
    JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
    
    // 2.定位文件夹路径，所有要上传的文件位于Document / Username / PureFileName / PDF /
    NSString *folderDirectory = [appDelegate.cookies getPDFFolderDirectory];
    NSString *folderPath = [filePersistence getDirectoryInDocumentWithName:folderDirectory];
    
    // 3.压缩文件夹中的所有文件
    NSString *zipFilePath = [self zipFilesInPath:folderPath];
    
    // 4.将打包后的zip文件上传到服务器
    [urlConnector uploadFileInPath:zipFilePath toServerInFolder:appDelegate.cookies.pureFileName];
    
    // 5.上传成功后删除zip文件
    // 该动作由urlconnection的delegate调用完成
    
    // 6.上传新创建的pdf文件到pureFileName_created文件夹
    NSString *pdfFilePath = [[filePersistence getDirectoryOfTmpFolder] stringByAppendingPathComponent:appDelegate.cookies.pdfFileName];
    NSString *createdPDFFolder = [appDelegate.cookies.pureFileName stringByAppendingString:@"_created"];
    [urlConnector uploadFileInPath:pdfFilePath toServerInFolder:createdPDFFolder];
}

#pragma mark - Zip files

/* 将folderPath中的文件全部打包成zip文件 */
- (NSString *)zipFilesInPath:(NSString *)folderPath {
    
    // 1.设置基本参数
    AppDelegate *appDelegate = APPDELEGATE;
    JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
    
    // 压缩步骤（Documents / Username / PureFileName / PDF / 目录下）：
    // (1)先压缩Text文件夹
    // (2)再压缩Voice文件夹
    // (3)后压缩MP3文件夹
    // (4)接着压缩DrawStrokes和CommentStrokes文件夹
    // (5)最后压缩Text.zip  Voice.zip  MP3.zip  CommentStrokes.zip  DrawStrokes.zip AnnotationKeys.plist到一个zip中
    
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
    NSString *zipFilePath = [filePersistence getDirectoryOfTmpFileWithName:zipFileName]; // 将zip创建在tmp目录中
    BOOL isSuccessful = [appDelegate.zipArchiver CreateZipFile2:zipFilePath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *keysPlistFilePath = [folderPath stringByAppendingPathComponent:ANNOTATION_KEYS_FILENAME];
    if (![fileManager fileExistsAtPath:keysPlistFilePath isDirectory:NO]) {
        keysPlistFilePath = nil;
    }
    
    if (textZipFilePath && [fileManager fileExistsAtPath:textZipFilePath isDirectory:NO]) {
        [appDelegate.zipArchiver addFileToZip:textZipFilePath newname:@"Text.zip"];
    }
    
    if (voiceZipFilePath && [fileManager fileExistsAtPath:voiceZipFilePath isDirectory:NO]) {
        [appDelegate.zipArchiver addFileToZip:voiceZipFilePath newname:@"Voice.zip"];
    }
    
    if (mp3ZipFilePath && [fileManager fileExistsAtPath:mp3ZipFilePath isDirectory:NO]) {
        [appDelegate.zipArchiver addFileToZip:mp3ZipFilePath newname:@"MP3.zip"];
    }
    
    if (commentStrokesZipFilePath && [fileManager fileExistsAtPath:commentStrokesZipFilePath isDirectory:NO]) {
        [appDelegate.zipArchiver addFileToZip:commentStrokesZipFilePath newname:@"CommentStrokes.zip"];
    }
    
    if (drawStrokesZipFilePath && [fileManager fileExistsAtPath:drawStrokesZipFilePath isDirectory:NO]) {
        [appDelegate.zipArchiver addFileToZip:drawStrokesZipFilePath newname:@"DrawStrokes.zip"];
    }
    
    if (keysPlistFilePath && [fileManager fileExistsAtPath:keysPlistFilePath isDirectory:NO]) {
        [appDelegate.zipArchiver addFileToZip:keysPlistFilePath newname:ANNOTATION_KEYS_FILENAME];
    }
    
    
    // 5.关闭创建的zip文件
    if (![appDelegate.zipArchiver CloseZipFile2]) {
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

/* 将subPath中的文件全部打包成zip文件 */
- (NSString *)zipFilesInSubPath:(NSString *)subPath {
    // 1.设置基本参数
    NSFileManager *fileManager = [NSFileManager defaultManager];
    AppDelegate *appDelegate = APPDELEGATE;
    JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
    
    // 2.获取文件夹中所有文件
    NSArray *filesInFolder = [fileManager contentsOfDirectoryAtPath:subPath error:NULL];
    
    if (filesInFolder && filesInFolder.count > 0) {
        // 3.设置zip文件的存放路径
        NSString *folderName = [subPath lastPathComponent];
        NSString *zipFileName = [folderName stringByAppendingString:ZIP_SUFFIX];
        NSString *zipFilePath = [filePersistence getDirectoryOfTmpFileWithName:zipFileName]; // 创建的子zip文件放在tmp目录下
        
        // 4.开始zip
        BOOL isSuccessful = [appDelegate.zipArchiver CreateZipFile2:zipFilePath];
        for (NSString *file in filesInFolder) {
            NSString *eachFilePath = [subPath stringByAppendingPathComponent:file];
            NSString *nFileName = [file stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if ([fileManager fileExistsAtPath:eachFilePath isDirectory:NO]) {
                isSuccessful = [appDelegate.zipArchiver addFileToZip:eachFilePath newname:nFileName];
            }
        }
        
        // 5.关闭创建的zip文件
        if (![appDelegate.zipArchiver CloseZipFile2]) {
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

/*
 * 解压zipFilePath路径下的zip文件
 *
 * 1.zip文件放在tmp文件夹下，先将其解压到当前的tmp目录下
 * 2.将解压后的文件从tmp目录移动到Documents / username / purefilename / PDF目录下
 * 3.如果有子zip文件，要先将其解压，再移动，通过unzipFilesInSubPath方法完成
 *
 */
- (void)unzipFilesInPath:(NSString *)zipFilePath {
    // 1.获取基本参数
    AppDelegate *appDelegate = APPDELEGATE;
    JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
    
    // 2.解压文件
    if (zipFilePath && [appDelegate.zipArchiver UnzipOpenFile:zipFilePath]) {
        // 文件解压的目标路径：tmp文件夹
        NSString *unzipPath = [filePersistence getDirectoryOfTmpFolder];
        
        // 设定解压后文件的存放目录：username / purefilename / PDF
        NSString *pdfFileDirectory = [appDelegate.cookies getPDFFolderDirectory];
        NSString *pdfFilePath = [filePersistence getDirectoryInDocumentWithName:pdfFileDirectory];
        
        // 开始解压
        if([appDelegate.zipArchiver UnzipFileTo:unzipPath overWrite:YES]) {
            // AnnotationKey.plist
            NSString *srcPlistFilePath = [unzipPath   stringByAppendingPathComponent:ANNOTATION_KEYS_FILENAME];
            NSString *desPlistFilePath = [pdfFilePath stringByAppendingPathComponent:ANNOTATION_KEYS_FILENAME];
            [filePersistence moveFileFromPath:srcPlistFilePath toPath:desPlistFilePath];
            
            // Text Folder
            NSString *textFolderPath = [unzipPath stringByAppendingPathComponent:
                                        [NSString stringWithFormat:@"%@.zip", TEXT_FOLDER_NAME]];
            [self unzipFilesInSubPath:textFolderPath];
            
            // Voice Folder
            NSString *voiceFolderPath = [unzipPath stringByAppendingPathComponent:
                                         [NSString stringWithFormat:@"%@.zip", VOICE_FOLDER_NAME]];
            [self unzipFilesInSubPath:voiceFolderPath];
            
            // MP3 Folder
            NSString *mp3FolderPath = [unzipPath stringByAppendingPathComponent:
                                       [NSString stringWithFormat:@"%@.zip", MP3_FOLDER_NAME]];
            [self unzipFilesInSubPath:mp3FolderPath];
            
            // DrawStrokes Folder
            NSString *drawStrokesFolderPath = [unzipPath stringByAppendingPathComponent:
                                               [NSString stringWithFormat:@"%@.zip", DRAW_STROKES_FOLDER_NAME]];
            [self unzipFilesInSubPath:drawStrokesFolderPath];
            
            // CommentStrokes Folder
            NSString *commentStrokesFolderPath = [unzipPath stringByAppendingPathComponent:
                                                  [NSString stringWithFormat:@"%@.zip", COMMENT_STROKES_FOLDER_NAME]];
            [self unzipFilesInSubPath:commentStrokesFolderPath];
            
            // 关闭zip文件
            [appDelegate.zipArchiver UnzipCloseFile];
        }
    }
}

/*
 * 解压subFilePath路径下的子zip文件
 *
 * 1.先将其解压到当前的tmp目录下zipname文件夹下
 * 2.将解压后的文件从tmp / zipname文件夹移动到Documents / username / purefilename / PDF目录下
 * 3.这里不能再有子zip文件
 *
 */
- (void)unzipFilesInSubPath:(NSString *)subFilePath {
    AppDelegate *appDelegate = APPDELEGATE;
    JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *folderName = [subFilePath lastPathComponent];
    folderName = [folderName substringToIndex:folderName.length - 4];
    
    if (![fileManager fileExistsAtPath:subFilePath isDirectory:NO]) {
        return;
    }
    
    if ([appDelegate.zipArchiver UnzipOpenFile:subFilePath]) {
        NSString *unzipDirectory = [NSString stringWithFormat:@"%@/%@/%@/%@", appDelegate.cookies.username, appDelegate.cookies.pureFileName, PDF_FOLDER_NAME, folderName];
        NSString *unzipPath = [filePersistence getDirectoryInDocumentWithName:unzipDirectory];
        if (![appDelegate.zipArchiver UnzipFileTo:unzipPath overWrite:YES]) {
            [JCAlert alertWithMessage:@"解压zip文件失败"];
        }
        [appDelegate.zipArchiver UnzipCloseFile];
    }
}

@end
