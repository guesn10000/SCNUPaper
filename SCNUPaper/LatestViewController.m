//
//  LatestViewController.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-22.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "LatestViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "JCAlert.h"
#import "JCTimer.h"
#import "JCFilePersistence.h"
#import "Cookies.h"
#import "URLConnector.h"
#import "MyPDFDocument.h"
#import "MyPDFCreator.h"
#import "FileCleaner.h"
#import "LoginViewController.h"
#import "MainPDFViewController.h"

#pragma mark - Constants

static NSString * const kLatest_FileName = @"filename"; // 最近打开的文件名
static NSString * const kLatest_OpenTime = @"opentime"; // 最近打开的时间

static const NSUInteger kMaximum_LatestOpen = 10; // 最近打开历史记录最大数

@interface LatestViewController ()

#pragma mark - Private

/* 从最近打开文件中加载用户列表 */
@property (strong, nonatomic) NSMutableDictionary *userslist_;

/* 最近打开的文件清单 */
@property (strong, nonatomic) NSMutableArray *latestOpenArray_;

@end

@implementation LatestViewController

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 隐藏返回按钮
    self.navigationItem.hidesBackButton = YES;
    
    // 记载登陆用户最近打开的文件列表
    AppDelegate *appDelegate = APPDELEGATE;
    self.userslist_ = [appDelegate.filePersistence loadMutableDictionaryFromDocumentFile:LATEST_OPEN_FILENAME];
    if (self.userslist_) {
        self.latestOpenArray_ = [self.userslist_ objectForKey:appDelegate.cookies.username];
        if (!self.latestOpenArray_) {
            self.latestOpenArray_ = [[NSMutableArray alloc] init];
        }
    }
    else {
        self.userslist_ = [[NSMutableDictionary alloc] init];
        self.latestOpenArray_ = [[NSMutableArray alloc] init];
    }
}

/* 当视图将要消失时移除窗口中的spinner */
- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 视图消失后移除spinner
    AppDelegate *appDelegate = APPDELEGATE;
    [appDelegate.app_spinner stopAnimating];
    [appDelegate.app_spinner removeFromSuperview];
    
    appDelegate.window.alpha = DEFAULT_VIEW_ALPHA;
    appDelegate.window.userInteractionEnabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    self.userslist_ = nil;
    self.latestOpenArray_ = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.latestOpenArray_.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CELL_IDENTIFIER];
    }
    
    // configuring cell
    NSDictionary *latestInfo  = [self.latestOpenArray_ objectAtIndex:indexPath.row];
    cell.textLabel.text       = [latestInfo objectForKey:kLatest_FileName]; // 文件名
    cell.detailTextLabel.text = [latestInfo objectForKey:kLatest_OpenTime]; // 打开时间
    
    return cell;
}

#pragma mark - UITableView Delegate

/* 点击表格后，打开对应的doc或pdf文件 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AppDelegate *appDelegate = APPDELEGATE;
    NSDictionary *openInfo = [self.latestOpenArray_ objectAtIndex:indexPath.row];
    NSString *filename = [openInfo objectForKey:kLatest_FileName];
    NSString *pureFileName = [filename substringToIndex:filename.length - 4];
    NSString *fileDirect;
    if ([filename hasSuffix:DOC_SUFFIX]) {
        fileDirect = [NSString stringWithFormat:@"%@/%@/%@", appDelegate.cookies.username, pureFileName, DOC_FOLDER_NAME];
    }
    else if ([filename hasSuffix:PDF_SUFFIX]) {
        fileDirect = [NSString stringWithFormat:@"%@/%@/%@", appDelegate.cookies.username, pureFileName, PDF_FOLDER_NAME];
    }
    else {
        return;
    }
    
    NSString *filePath = [appDelegate.filePersistence getDirectoryInDocumentWithName:fileDirect];
    filePath = [filePath stringByAppendingPathComponent:filename];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    appDelegate.fileURL = fileURL;
    [self openFileURL];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

/* 更新或新增最近打开记录 */
- (void)updateLatestOpenWithRecord:(NSMutableDictionary *)openInfo {
    // 搜索打开记录列表，看看是否曾经打开过
    NSDictionary *info;
    NSString *lastFileName;
    NSString *openFileName;
    int i;
    for (i = 0; i < self.latestOpenArray_.count; i++) {
        info = [self.latestOpenArray_ objectAtIndex:i];
        lastFileName = [info     objectForKey:kLatest_FileName];
        openFileName = [openInfo objectForKey:kLatest_FileName];
        if ([lastFileName isEqualToString:openFileName]) {
            break;
        }
    }
    
    // 没有打开过该文件
    if (i == self.latestOpenArray_.count) {
        // 如果最近打开记录超出最大记录数
        if (self.latestOpenArray_.count == kMaximum_LatestOpen) {
            // 清空最后一项对应的文件夹
            NSDictionary *tempInfo = [self.latestOpenArray_ lastObject];
            NSString *tempFileName = [tempInfo objectForKey:kLatest_FileName];
            tempFileName = [tempFileName substringToIndex:tempFileName.length - 4];
            AppDelegate *appDelegate = APPDELEGATE;
            [appDelegate.fileCleaner clearFolder:tempFileName];
            
            // 移除数组中的元素
            [self.latestOpenArray_ removeLastObject];
        }
    }
    else {
        [self.latestOpenArray_ removeObjectAtIndex:i];
    }
    
    [self.latestOpenArray_ insertObject:openInfo atIndex:0];
    
    // 异步刷新页面
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
    // 保存记录到文件中
    AppDelegate *appDelegate = APPDELEGATE;
    [self.userslist_ setObject:self.latestOpenArray_ forKey:appDelegate.cookies.username];
    [appDelegate.filePersistence saveMutableDictionary:self.userslist_ toDocumentFile:LATEST_OPEN_FILENAME];
}

#pragma mark - Open File

- (void)openFileURL {
    AppDelegate *appDelegate = APPDELEGATE;
    
#ifdef LOCAL_TEST
    NSString *filename = @"中国的绘画精神（长篇）.pdf";
    [appDelegate.cookies setFileNamesWithPDFFileName:filename];
    [self openPDFFile];
#else
    // 1.获取文件名
    NSString *filename = [appDelegate.fileURL lastPathComponent];
    
    // 2.打开从邮箱打开的或最近打开列表中的文件
    if ([filename hasSuffix:DOC_SUFFIX]) {
        [appDelegate.cookies setFileNamesWithDOCFileName:filename];
        
        // 上传doc文件到服务器进行转换
        [self uploadFileWithSuffix:DOC_SUFFIX];
    }
    else if ([filename hasSuffix:PDF_SUFFIX]) {
        [appDelegate.cookies setFileNamesWithPDFFileName:filename];
        [self uploadFileWithSuffix:PDF_SUFFIX];
    }
    else {
        [JCAlert alertWithMessage:@"打开文件失败，该文件格式不是doc或pdf"];
    }
#endif
    
}

#pragma mark - Upload Files

/* 上传suffix格式的文件到服务器 */
- (void)uploadFileWithSuffix:(NSString *)suffix {
    // 获取基本参数
    AppDelegate *appDelegate  = APPDELEGATE;
    NSString *pureFilename = appDelegate.cookies.pureFileName;
    NSString *postFilename = [pureFilename stringByAppendingString:suffix];
    
    appDelegate.window.alpha = UNABLE_VIEW_ALPHA;
    appDelegate.window.userInteractionEnabled = NO;
    
    // 进入等待打开文件提示状态
    dispatch_async(dispatch_get_main_queue(), ^{
        [appDelegate.window addSubview:appDelegate.app_spinner];
        [appDelegate.app_spinner startAnimating];
    });
    
    if ([suffix isEqualToString:DOC_SUFFIX]) { // 打开doc文件
        // 获取文件的源路径
        NSString *srcFileDirectory = [appDelegate.filePersistence getDirectoryOfInboxFolder];
        NSString *srcFilePath = [srcFileDirectory stringByAppendingPathComponent:postFilename];
        
        // 获取文件的目标路径
        NSString *desFileDirectory = [appDelegate.cookies getDOCFolderDirectory];
        NSString *desFilePath = [appDelegate.filePersistence getDirectoryInDocumentWithName:desFileDirectory];
        desFilePath = [desFilePath stringByAppendingPathComponent:postFilename];
        
        // 将从邮箱或网页或其它应用下载的doc文件移动到指username/purefilename/DOC目录下
        [appDelegate.filePersistence moveFileFromPath:srcFilePath toPath:desFilePath];
        
        // 3.将doc文件上传到服务器进行转换
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:desFilePath isDirectory:NO]) {
            [appDelegate.urlConnector convertDocFileInPath:desFilePath toPDFFileInFolder:pureFilename];
        }
    }
    else if ([suffix isEqualToString:PDF_SUFFIX]) {
        [self downloadDOCFile];
    }
    else {
        [JCAlert alertWithMessage:@"请检查您的文件格式"];
        return;
    }
}

#pragma mark - Download Files

- (void)downloadDOCFile {
    AppDelegate *appDelegate = APPDELEGATE;
    [appDelegate.urlConnector downloadFile:appDelegate.cookies.docFileName
                                      Type:DOC_SUFFIX
                        FromServerInFolder:appDelegate.cookies.pureFileName];
}

- (void)getDownload_DOC_Data:(NSMutableData *)docData {
    AppDelegate *appDelegate = APPDELEGATE;
    
    // 保存doc文件数据到Documents / Inbox文件夹中
    if (docData && docData.length > 0) {
        [appDelegate.filePersistence saveMutableData:docData ToFile:appDelegate.cookies.docFileName inDocumentWithDirectory:INBOX_FOLDER_NAME];
    }
    else {
        [JCAlert alertWithMessage:@"打开文件失败，下载的数据为空"];
    }
    
    // 上传doc文件进行转换
    [self uploadFileWithSuffix:DOC_SUFFIX];
    
    // 清除Inbox目录下需要直接打开的pdf文件
    [appDelegate.filePersistence removeFilesAtInboxFolder];
}

/* 下载该doc文件在服务器对应的zip包（如果已经存在） */
- (void)downloadZipFile {
    AppDelegate *appDelegate = APPDELEGATE;
    [appDelegate.urlConnector downloadFile:appDelegate.cookies.zipFileName
                                      Type:ZIP_SUFFIX
                        FromServerInFolder:appDelegate.cookies.pureFileName];
}

/* 获取下载成功的zip数据，zipData : 由DownloadHanler回传 */
- (void)getDownload_ZIP_Data:(NSMutableData *)zipData {
    if (zipData && zipData.length > 0) {
        AppDelegate *appDelegate = APPDELEGATE;
        
        // 保存zip数据到tmp文件夹中
        if ([appDelegate.filePersistence saveMutableData:zipData toTmpFile:appDelegate.cookies.zipFileName]) {
            // 解压前先清除pureFileName文件夹中的PDF文件夹
            [appDelegate.fileCleaner clearFilesInPDFFolder:appDelegate.cookies.pureFileName];
            
            // 解压zip包并将zip包中的数据移动到对应位置
            NSString *zipFilePath = [appDelegate.filePersistence getDirectoryOfTmpFileWithName:appDelegate.cookies.zipFileName];
            [appDelegate.pdfCreator unzipFilesInPath:zipFilePath];
            
            // 清空tmp目录下的文件，防止影响后面的解压
            [appDelegate.filePersistence removeFilesAtTmpFolder];
        }
    }
    else {
        [JCAlert alertWithMessage:@"下载zip文件失败"];
    }
}

/* 从服务器下载pdf文件数据 */
- (void)downloadPDFFile {
    // 在转换完成后从服务器的文件夹purefilename中下载pdf文件数据，并保存到username/purefilename/pdf/目录下
    AppDelegate *appDelegate = APPDELEGATE;
    [appDelegate.urlConnector downloadFile:appDelegate.cookies.pdfFileName
                                      Type:PDF_SUFFIX
                        FromServerInFolder:appDelegate.cookies.pureFileName];
}

/* 获取下载成功的pdf数据，pdfData : 由DownloadHanler回传 */
- (void)getDownload_PDF_Data:(NSMutableData *)pdfData {
    if (pdfData && pdfData.length > 0) {
        AppDelegate *appDelegate = APPDELEGATE;
        NSString *pdfFileDirectory = [appDelegate.cookies getPDFFolderDirectory];
        [appDelegate.filePersistence saveMutableData:pdfData ToFile:appDelegate.cookies.pdfFileName inDocumentWithDirectory:pdfFileDirectory];
    }
    else {
        [JCAlert alertWithMessage:@"打开文件失败，下载的数据为空"];
    }
    
    // 打开pdf文件
    [self openPDFFile];
}

/* 打开pdf文件 */
- (void)openPDFFile {
    // 1.获取基本参数
    AppDelegate *appDelegate = APPDELEGATE;
    
    // 2.保存当前打开的文件到最近打开数组中
    NSMutableDictionary *openInfo = [[NSMutableDictionary alloc] init];
    
    // 文件名
#ifdef LOCAL_TEST
    NSString *filename = appDelegate.cookies.pdfFileName;
#else
    NSString *filename = appDelegate.fileURL.lastPathComponent;
#endif
    
    // 更新最近打开记录
    [openInfo setObject:filename forKey:kLatest_FileName];
    [openInfo setObject:[JCTimer get_yyMMddhhmm_StringOfCurrentTime] forKey:kLatest_OpenTime];
    [self updateLatestOpenWithRecord:openInfo];
    
    // 初始化PDF文件
    NSString *pdfFileDirectory = [appDelegate.cookies getPDFFolderDirectory];
    NSString *pdfFilePath = [appDelegate.filePersistence getDirectoryInDocumentWithName:pdfFileDirectory];
    pdfFilePath = [pdfFilePath stringByAppendingPathComponent:appDelegate.cookies.pdfFileName];
    appDelegate.mainPDFViewController.myPDFDocument = [[MyPDFDocument alloc] initWithPDFFilePath:pdfFilePath];
    
    // 关闭打开文件请求
    appDelegate.loginViewController.request_openFileURL = NO;
    
    // 将main pdf viewcontroller压入栈中
    [appDelegate.rootViewController pushViewController:appDelegate.mainPDFViewController animated:YES];
}

#pragma mark - Quit Login

/* 退出登陆 */
- (IBAction)quitLogin:(id)sender {
    
#ifdef LOCAL_TEST
    [self openFileURL];
#else
    // 重置cookies和urlconnector的参数，并返回登陆页面
    AppDelegate *appDelegate = APPDELEGATE;
    [appDelegate.cookies cookiesQuitLogin];
    appDelegate.urlConnector.isLoginSucceed = NO;
    [appDelegate.latestViewController.navigationController popToViewController:appDelegate.loginViewController animated:YES];

#endif
    
}

@end
