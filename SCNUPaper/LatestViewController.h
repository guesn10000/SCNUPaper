//
//  LatestViewController.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-22.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LatestViewController : UITableViewController

/* 退出登陆 */
- (IBAction)quitLogin:(id)sender;

/* 打开来自邮件或其它途径的File URL，这里的File URL保存在AppDelegate中 */
- (void)openFileURL;

/*
 * 从服务器下载文件
 * 下载完成后，获取下载的数据
 */
- (void)downloadZipFile;
- (void)downloadPDFFile;
- (void)getDownload_ZIP_Data:(NSMutableData *)zipData;
- (void)getDownload_PDF_Data:(NSMutableData *)pdfData;

@end
