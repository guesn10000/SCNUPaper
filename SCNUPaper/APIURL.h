//
//  APIURL.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-17.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef _______APIURL_h
#define _______APIURL_h

/* 基本参数 */
#define REQUEST_SUCCEED_STATUS_CODE 200
#define REDIRECT_STATUS_CODE        302
#define FILE_NOT_FOUND_CODE         404

#define SCNU_SERVER_URL @"http://192.168.4.104:8080/scnuoffice/"


/* 登陆 */
/*
 <form action="user/login" method="post">
    Username:<input type="text"     name="username"/><br/>
    Password:<input type="password" name="password"/><br/>
    <input type="submit"/>
 </form>
 */
#define LOGIN_URL @"http://192.168.4.104:8080/scnuoffice/user/login"
#define kUsername @"username"
#define kPassword @"password"


/* 注册 */
/*
 <form action="./register" method="post">
    Username:<input type="text"     name="username"/><br/>
    Nickname:<input type="text"     name="nickname"/><br/>
    Password:<input type="password" name="password"/><br/>
    <input type="submit"/>
 </form>
 */
#define REGISTER_URL @"http://192.168.4.104:8080/scnuoffice/register"
#define kNickname    @"nickname"


/* 上传文件 */
/*
 <form method="post" action="../../user/qwe/upload" enctype="multipart/form-data">
    <input type="text"   name="folder"/><br/>
    <input type="file"   name="data01"/><br/>
    <input type="submit" value="Submit"/>
 </form>
 */
#define UPLOAD_FILES_URL(_username) [NSString stringWithFormat:@"http://192.168.4.104:8080/scnuoffice/user/%@/upload", _username]
#define kFoldername @"folder"
#define kFilename   @"data01"


/* 转换doc成pdf */
/*
 <form method="post" action="../../../../user/qwe/conv/to/pdf" enctype="multipart/form-data">
    <input type="text"   name="folder"/><br/>
    <input type="file"   name="data01"/><br/>
    <input type="submit" value="Submit"/>
 </form>
 */
#define CONVERT_DOC_TO_PDF_URL(_username) [NSString stringWithFormat:@"http://192.168.4.104:8080/scnuoffice/user/%@/conv/to/pdf", _username]


/* 查看资源 */
#define SHOW_DOWNLOADLIST_URL(_username) [NSString stringWithFormat:@"http://192.168.4.104:8080/scnuoffice/user/%@/show/download-list", _username]


/* 下载文件 */
/*
 下载资源: {
 <label> Folder :</label><input id="folder_input" type="text" name="folder"/><br/>
 <label> Data01 :</label><input id="data01_input" type="text" name="data01"  onkeypress="if(event.keyCode==13) {submit_btn();return false;}"/><br/>
 <input type="button" value="Submit" onclick="submit_btn()"/>
 }
 
 function submit_btn(){
 var
 folder_v = encodeURI(document.getElementById("folder_input").value),
 data01_v = encodeURI(document.getElementById("data01_input").value);
 post(
 "../../user/qwe/download",
 {folder:folder_v, data01:data01_v}
 );
 }
 */
#define DOWNLOAD_FILES_URL(_username) [NSString stringWithFormat:@"http://192.168.4.104:8080/scnuoffice/user/%@/download", _username]

#endif
