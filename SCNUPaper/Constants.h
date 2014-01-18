//
//  Constants.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-17.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#ifndef _______Constants_h
#define _______Constants_h


/* 程序常量 */

#define APPDELEGATE [[UIApplication sharedApplication] delegate]


/* 系统参数 */

#define STATUSBAR_HEIGHT 24.0
#define STATUS_NAVIGATIONBAR_HEIGHT 64.0
#define TOOLBAR_HEIGHT 44.0

#define IPHONE5_5S_SCREEN_WIDTH  320.0
#define IPHONE5_5S_SCREEN_HEIGHT 568.0

#define IPHONE4_4S_SCREEN_WIDTH  320.0
#define IPHONE4_4S_SCREEN_HEIGHT 480.0

#define IPAD_SCREEN_WIDTH  768.0
#define IPAD_SCREEN_HEIGHT 1024.0


/* 故事板相关 */

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPAD   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define IPHONE_STORYBOARD_NAME @"Main_iPhone"
#define IPAD_STORYBOARD_NAME   @"Main_iPad"
#define STORYBOARD_NAME ((IS_IPHONE) ? IPHONE_STORYBOARD_NAME : IPAD_STORYBOARD_NAME)

#define LOGINVIEWCONTROLLER_ID   @"LoginViewController"
#define LATESTVIEWCONTROLLER_ID  @"LatestViewController"
#define MAINPDFVIEWCONTROLLER_ID @"MainPDFViewController"

#define CELL_IDENTIFIER @"Cell"

#define PUSH_LOGIN_LATEST_SEGUE_ID @"push_LatestViewController"
#define PUSH_LATEST_MAIN_SEGUE_ID  @"push_MainPDFViewController"

#define IPAD_TOOLBARS_NIB   @"iPad_ToolBars"
#define IPHONE_TOOLBARS_NIB @"iPhone_ToolBars"

#define UNABLE_VIEW_ALPHA  0.9
#define DEFAULT_VIEW_ALPHA 1.0

#define INPUTTEXTVIEW_XIB @"InputTextView.xib"

/* 涂鸦常数 */

#define DRAW_STROKE_WIDTH 5.0

#define COMMENT_STROKE_WIDTH 10.0
#define COMMENT_STROKE_COLOR [[UIColor alloc] initWithRed:1.0 green:1.0 blue:0.0 alpha:0.5]


/* 文件保存常数 */

#define PDF_FOLDER_NAME   @"PDF"
#define DOC_FOLDER_NAME   @"DOC"
#define PPT_FOLDER_NAME   @"PPT"
#define INBOX_FOLDER_NAME @"Inbox"

#define TEXT_FOLDER_NAME            @"Text"
#define VOICE_FOLDER_NAME           @"Voice"
#define MP3_FOLDER_NAME             @"MP3"
#define COMMENT_STROKES_FOLDER_NAME @"CommentStrokes"
#define DRAW_STROKES_FOLDER_NAME    @"DrawStrokes"

#define PDF_SUFFIX @".pdf"
#define DOC_SUFFIX @".doc"
#define PPT_SUFFIX @".ppt"
#define ZIP_SUFFIX @".zip"
#define MP3_SUFFIX @".mp3"
#define CAF_SUFFIX @".caf"

#define ANNOTATION_KEYS_FILENAME @"AnnotationKeys.plist"

// 保存最近打开文件记录的文件
#define LATEST_OPEN_FILENAME @"LatestOpen.plist"


/* 临时信息 */
#define TEMP_USERNAME @"qwe"
#define TEMP_PASSWORD @"123"

#endif