//
//  Comments.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-19.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "Comments.h"
#import "AppDelegate.h"
#import "Cookies.h"
#import "JCFilePersistence.h"
#import "JCAlert.h"
#import "Constants.h"
#import "CommentStroke.h"
#import "MyPDFPage.h"
#import "MainPDFViewController.h"
#import "PDFScrollView.h"

@interface Comments ()

@end

@implementation Comments

#pragma mark - Constants

static NSString *kCellIdentifier = @"Cell";

#pragma mark - Initialization

- (id)init {
    self = [super init];
    
    if (self) {
        self.currentText = @"";
    }
    
    return self;
}

#pragma mark - TableView DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.textComments.count;
            break;
        case 1:
            return self.voiceComments.count;
            break;
        default:
            return 0;
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"批注%d", indexPath.row];
    }
    else if (indexPath.section == 1) {
        cell.textLabel.text = [NSString stringWithFormat:@"语音%d", indexPath.row];
    }
    else {
        return nil;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) { // 删除批注
        AppDelegate *appDelegate = APPDELEGATE;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL showComments = YES;
        
        if (indexPath.section == 0) {
            // 1.获取文件路径，文件名：PageIndex_CommentAnnotationKey_text.plist
            NSString *fileName = [NSString stringWithFormat:@"%zu_%d_text.plist", self.currentPageIndex, self.currentButtonKey];
            // 完整路径：Document / Username / PureFileName / PDF / Text / PageIndex_ButtonKey_text.plist
            NSString *fileDirectory = [NSString stringWithFormat:@"%@/%@/%@/%@", appDelegate.cookies.username, appDelegate.cookies.pureFileName, PDF_FOLDER_NAME, TEXT_FOLDER_NAME];
            
            // 2.删除数组中对应的元素
            [self.textComments removeObjectAtIndex:indexPath.row];
            
            // 3.将数组写回文件中
            [appDelegate.filePersistence saveMutableArray:self.textComments toFile:fileName inDocumentWithDirectory:fileDirectory];
            
            // 4.更新表格
            [appDelegate.mainPDFViewController.checkCommentsTable reloadData];
        }
        else if (indexPath.section == 1) {
            // 1.获取文件路径
            NSString *fileName = [NSString stringWithFormat:@"%zu_%d_voice.plist", self.currentPageIndex, self.currentButtonKey];
            // 完整路径：Document / Username / PureFileName / PDF / Text / PageIndex_ButtonKey_voice.plist
            NSString *fileDirectory = [NSString stringWithFormat:@"%@/%@/%@/%@", appDelegate.cookies.username, appDelegate.cookies.pureFileName, PDF_FOLDER_NAME, VOICE_FOLDER_NAME];
            
            // 2.删除数组中对应的元素，删除mp3文件的路径
            NSString *mp3FilePath = self.voiceComments[indexPath.row];
            if ([fileManager fileExistsAtPath:mp3FilePath isDirectory:NO]) {
                [fileManager removeItemAtPath:mp3FilePath error:nil];
            }
            [self.voiceComments removeObjectAtIndex:indexPath.row];
            
            // 3.将数组写回文件中
            [appDelegate.filePersistence saveMutableArray:self.voiceComments toFile:fileName inDocumentWithDirectory:fileDirectory];
            
            // 4.更新表格
            [appDelegate.mainPDFViewController.checkCommentsTable reloadData];
        }
        else {
            return;
        }
        
        if (self.textComments.count == 0 || self.voiceComments.count == 0) {
            // 删除Comments对应的Strokes
            // Document / Username / PureFileName / PDF / CommentStrokes / PageIndex_strokes.plist
            NSString *strokesFileName = [NSString stringWithFormat:@"%zu_commentStrokes.plist", self.currentPageIndex];
            NSString *strokesFileDirectory = [NSString stringWithFormat:@"%@/%@/%@/%@", appDelegate.cookies.username, appDelegate.cookies.pureFileName, PDF_FOLDER_NAME, COMMENT_STROKES_FOLDER_NAME];
            NSMutableData *mdata = [appDelegate.filePersistence loadMutableDataFromFile:strokesFileName inDocumentWithDirectory:strokesFileDirectory];
            NSMutableArray *strokesArray = [NSKeyedUnarchiver unarchiveObjectWithData:mdata];
            CommentStroke *stroke;
            int i = 0;
            if (strokesArray) {
                for (i = 0; i < strokesArray.count; i++) {
                    stroke = [strokesArray objectAtIndex:i];
                    if (stroke.buttonKey == self.currentButtonKey) {
                        break;
                    }
                }
            }
            
            // 如果当前批注内容为空，就移除该批注
            if (self.textComments.count + self.voiceComments.count == 0) {
                [strokesArray removeObjectAtIndex:i];
                
                // 刷新tiledPDFScrollView，取消文字的高亮状态，并移除按钮
                [appDelegate.mainPDFViewController.viewsForThesisPages[self.currentPageIndex - 1] refreshTiledPDFView];
                
                showComments = NO;
            }
            else { // 否则修改批注状态
                if (self.textComments.count == 0) {
                    stroke.hasTextAnnotation = NO;
                }
                if (self.voiceComments.count == 0) {
                    stroke.hasVoiceAnnotation = NO;
                }
                [strokesArray removeObjectAtIndex:i];
                [strokesArray insertObject:stroke atIndex:i];
            }
            
            // 保存CommentStroke数据到文件中
            NSData *data  = [NSKeyedArchiver archivedDataWithRootObject:strokesArray];
            mdata = [[NSMutableData alloc] initWithData:data];
            [appDelegate.filePersistence saveMutableData:mdata
                                                  ToFile:strokesFileName
                                 inDocumentWithDirectory:strokesFileDirectory];
            
            appDelegate.mainPDFViewController.hasEdited = YES;
        }
        
        // 如果批注内容还没被清空，就显示批注列表
        if (showComments) {
            [Comments showCommentsWithPage:self.currentPageIndex Key:self.currentButtonKey];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        return;
    }
}


+ (void)showCommentsWithPage:(size_t)pageIndex Key:(NSInteger)buttonKey {
    // 1.获取基本参数
    AppDelegate *appDelegate = APPDELEGATE;
    
    // 2.初始化Text Comments的数组
    NSString *textFileName = [NSString stringWithFormat:@"%zu_%d_text.plist", pageIndex, buttonKey];
    NSString *textFileDirectory = [NSString stringWithFormat:@"%@/%@/%@/%@", appDelegate.cookies.username, appDelegate.cookies.pureFileName, PDF_FOLDER_NAME, TEXT_FOLDER_NAME];
    NSMutableArray *textArray = [appDelegate.filePersistence loadMutableArrayFromFile:textFileName inDocumentWithDirectory:textFileDirectory];
    if (!textArray) {
        textArray = [[NSMutableArray alloc] init];
    }
    appDelegate.mainPDFViewController.allComments.textComments = [[NSMutableArray alloc] initWithArray:[textArray mutableCopy]];
    
    // 3.初始化Voice Comments的数组
    NSString *voiceFileName = [NSString stringWithFormat:@"%zu_%d_voice.plist", pageIndex, buttonKey];
    NSString *voiceFileDirectory = [NSString stringWithFormat:@"%@/%@/%@/%@", appDelegate.cookies.username, appDelegate.cookies.pureFileName, PDF_FOLDER_NAME, VOICE_FOLDER_NAME];
    NSMutableArray *voiceArray = [appDelegate.filePersistence loadMutableArrayFromFile:voiceFileName inDocumentWithDirectory:voiceFileDirectory];
    if (!voiceArray) {
        voiceArray = [[NSMutableArray alloc] init];
    }
    appDelegate.mainPDFViewController.allComments.voiceComments = [[NSMutableArray alloc] initWithArray:[voiceArray mutableCopy]];
    
    // 4.设置Comments table view的page index和button key
    appDelegate.mainPDFViewController.allComments.currentPageIndex = pageIndex;
    appDelegate.mainPDFViewController.allComments.currentButtonKey = buttonKey;
    
    // 5.显示Comments Table
    [appDelegate.mainPDFViewController checkComments];
}

@end
