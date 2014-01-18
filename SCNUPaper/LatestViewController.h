//
//  LatestViewController.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-22.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LatestViewController : UITableViewController

/* 最近打开的文件清单 */

@property (strong, nonatomic) NSMutableArray *latestOpenArray;

/* 退出登陆 */
- (IBAction)quitLogin:(id)sender;

/*
 * 打开来自邮件或其它途径的File URL
 * 这里的File URL保存在AppDelegate中
 */
- (void)openFileURL;


/*
 * 上传文件到服务器
 *
 * doc : 先转换成pdf，再下载转换好的pdf
 * 
 * pdf : 先查看在服务器是否存在zip包，如果存在则说明已经转换过，要下载对应的修改结果并渲染到页面上
 *
 */
- (void)uploadDOCFile;


/*
 * 从服务器下载文件
 * 下载完成后，获取下载的数据
 */
- (void)downloadZipFile;
- (void)downloadPDFFile;
- (void)getDownload_ZIP_Data:(NSMutableData *)zipData;
- (void)getDownload_PDF_Data:(NSMutableData *)pdfData;


/* 下载数据成功后，打开PDF文件 */
- (void)openPDFFile;

@end
