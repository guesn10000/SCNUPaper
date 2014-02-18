//
//  Constants.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-17.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#ifndef _______Constants_h
#define _______Constants_h


/* 声明本地测试的宏 */

#if 1
#define LOCAL_TEST
#endif


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
#define REGISTVIEWCONTROLLER_ID  @"RegistViewController"
#define LATESTVIEWCONTROLLER_ID  @"LatestViewController"
#define MAINPDFVIEWCONTROLLER_ID @"MainPDFViewController"

#define CELL_IDENTIFIER @"Cell"

#define UNABLE_VIEW_ALPHA  0.9
#define DEFAULT_VIEW_ALPHA 1.0

#define IPAD_TOOLBARS_NIB   @"iPad_ToolBars"
#define IPHONE_TOOLBARS_NIB @"iPhone_ToolBars"

#define IPAD_INPUT_PAGE_XIB   @"PageInputView"
#define IPHONE_INPUT_PAGE_XIB @"iPhone_PageInput"

#define IPAD_COMMENT_TABLE_XIB   @"CommentsTable"
#define IPHONE_COMMENT_TABLE_XIB @"CheckCommTable"

#define IPAD_COMMENT_DETAIL_XIB   @"CommentDetail"
#define IPHONE_COMMENT_DETAIL_XIB @"CheckCommDetail"


/* 应用常数 */

#define LATEST_USERNAME            @"kUsername"
#define LATEST_PASSWORD            @"kPassword"
#define IS_LATESTUSER_TEACHER      @"kIsTeacher"
#define SHOULD_REMEMBER_PASSWORD   @"kShouldRememberPassword"
#define SHOULD_LOGIN_AUTOMATICALLY @"kShouldLoginAutomatically"


/* 涂鸦常数 */

#define DRAW_STROKE_WIDTH 5.0

#define COMMENT_STROKE_WIDTH 10.0
#define COMMENT_STROKE_COLOR [[UIColor alloc] initWithRed:1.0 green:1.0 blue:0.0 alpha:0.5]


/* 文件保存常数 */

#define PDF_FOLDER_NAME        @"PDF"
#define DOC_FOLDER_NAME        @"DOC"
#define INBOX_FOLDER_NAME      @"Inbox"
#define PDF_CREATE_FOLDER_NAME @"PDF_Create"

#define TEXT_FOLDER_NAME            @"Text"
#define VOICE_FOLDER_NAME           @"Voice"
#define MP3_FOLDER_NAME             @"MP3"
#define COMMENT_STROKES_FOLDER_NAME @"CommentStrokes"
#define DRAW_STROKES_FOLDER_NAME    @"DrawStrokes"

#define PDF_SUFFIX @".pdf"
#define DOC_SUFFIX @".doc"
#define ZIP_SUFFIX @".zip"
#define MP3_SUFFIX @".mp3"
#define CAF_SUFFIX @".caf"

#define WORD_MIME_TYPE @"application/msword"
#define PDF_MIME_TYPE  @"application/pdf"

#define ANNOTATION_KEYS_FILENAME @"AnnotationKeys.plist"

// 保存最近打开文件记录的文件
#define LATEST_OPEN_FILENAME @"LatestOpen.plist"

// 常用图片
#define TEXT_ANNOTATION_IMAGE  [UIImage imageNamed:@"addText.png"]
#define VOICE_ANNOTATION_IMAGE [UIImage imageNamed:@"addVoice.jpg"]


/* 临时信息 */
#define TEMP_USERNAME @"qwe"
#define TEMP_PASSWORD @"123"

#endif
