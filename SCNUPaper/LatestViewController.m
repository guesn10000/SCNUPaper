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
#import "Cookies.h"
#import "JCFilePersistence.h"
#import "FileCleaner.h"
#import "URLConnector.h"
#import "JCAlert.h"
#import "MyPDFDocument.h"
#import "MyPDFCreator.h"
#import "LoginViewController.h"
#import "MainPDFViewController.h"

@interface LatestViewController ()

// 从最近打开文件中加载用户列表
@property (strong, nonatomic) NSMutableDictionary *userslist_;

@end

@implementation LatestViewController

#pragma mark - Constants

static NSString *kLatest_FileName = @"filename"; // 最近打开的文件名
static NSString *kLatest_OpenTime = @"opentime"; // 最近打开的时间

const NSUInteger Maximum_LatestOpen = 10; // 最近打开历史记录最大数

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 隐藏返回按钮
    self.navigationItem.hidesBackButton = YES;
    
    // 记载登陆用户最近打开的文件列表
    AppDelegate *appDelegate = APPDELEGATE;
    self.userslist_ = [appDelegate.filePersistence loadMutableDictionaryFromDocumentFile:LATEST_OPEN_FILENAME];
    if (self.userslist_) {
        self.latestOpenArray = [self.userslist_ objectForKey:appDelegate.cookies.username];
        if (!self.latestOpenArray) {
            self.latestOpenArray = [[NSMutableArray alloc] init];
        }
    }
    else {
        self.userslist_ = [[NSMutableDictionary alloc] init];
        self.latestOpenArray = [[NSMutableArray alloc] init];
    }
}

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
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.latestOpenArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CELL_IDENTIFIER];
    }
    
    // configuring cell
    NSDictionary *latestInfo = [self.latestOpenArray objectAtIndex:indexPath.row];
    cell.textLabel.text       = [latestInfo objectForKey:kLatest_FileName]; // 文件名
    cell.detailTextLabel.text = [latestInfo objectForKey:kLatest_OpenTime]; // 打开时间
    
    return cell;
}

/* 更新或新增最近打开记录 */
- (void)updateLatestOpenWithRecord:(NSMutableDictionary *)openInfo {
    // 搜索打开记录列表，看看是否曾经打开过
    NSDictionary *info;
    NSString *lastFileName;
    NSString *openFileName;
    NSString *openFileTime;
    int i;
    for (i = 0; i < self.latestOpenArray.count; i++) {
        info = [self.latestOpenArray objectAtIndex:i];
        lastFileName = [info objectForKey:kLatest_FileName];
        openFileName = [openInfo objectForKey:kLatest_FileName];
        openFileTime = [openInfo objectForKey:kLatest_OpenTime];
        if ([lastFileName isEqualToString:openFileName]) {
            break;
        }
    }
    
    if (i == self.latestOpenArray.count) {
        // 如果最近打开记录超出最大记录数
        if (self.latestOpenArray.count == Maximum_LatestOpen) {
            NSDictionary *tempInfo = [self.latestOpenArray lastObject];
            NSString *tempFileName = [tempInfo objectForKey:kLatest_FileName];
            tempFileName = [tempFileName substringToIndex:tempFileName.length - 4];
            AppDelegate *appDelegate = APPDELEGATE;
            [appDelegate.fileCleaner clearFolder:tempFileName];
            
            [self.latestOpenArray removeLastObject];
        }
    }
    else {
        [self.latestOpenArray removeObjectAtIndex:i];
    }
    
    [self.latestOpenArray insertObject:openInfo atIndex:0];
    
    // 保存到文件中
    AppDelegate *appDelegate = APPDELEGATE;
    [self.userslist_ setObject:self.latestOpenArray forKey:appDelegate.cookies.username];
    [appDelegate.filePersistence saveMutableDictionary:self.userslist_ toDocumentFile:LATEST_OPEN_FILENAME];
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 打开doc文件
    AppDelegate *appDelegate = APPDELEGATE;
    NSDictionary *openInfo = [self.latestOpenArray objectAtIndex:indexPath.row];
    NSString *filename = [openInfo objectForKey:kLatest_FileName];
    NSString *pureFileName = [filename substringToIndex:filename.length - 4];
    NSString *fileDirect;
    if ([filename hasSuffix:DOC_SUFFIX]) {
        fileDirect = [NSString stringWithFormat:@"%@/%@/%@", appDelegate.cookies.username, pureFileName, DOC_FOLDER_NAME];
    }
    else if ([filename hasSuffix:PDF_SUFFIX]) {
        fileDirect = [NSString stringWithFormat:@"%@/%@/%@", appDelegate.cookies.username, pureFileName, PDF_FOLDER_NAME];
    }
    
    NSString *filePath = [appDelegate.filePersistence getDirectoryInDocumentWithName:fileDirect];
    filePath = [filePath stringByAppendingPathComponent:filename];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    appDelegate.fileURL = fileURL;
    [self openFileURL];
    
    // 刷新最近打开论文列表
    [tableView reloadData];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

#pragma mark - Open Files

- (void)openFileURL {
    // 1.获取文件名
    AppDelegate *appDelegate = APPDELEGATE;
    NSString *filename = [appDelegate.fileURL lastPathComponent];
    
    // 2.打开下载的文件
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
}

#pragma mark - Upload Files

/* 上传suffix格式的文件到服务器 */
- (void)uploadFileWithSuffix:(NSString *)suffix {
    // 1.获取基本参数
    AppDelegate *appDelegate  = APPDELEGATE;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *pureFilename = appDelegate.cookies.pureFileName;
    NSString *postFilename = [pureFilename stringByAppendingString:suffix];
    
    appDelegate.window.alpha = UNABLE_VIEW_ALPHA;
    appDelegate.window.userInteractionEnabled = NO;
    
    // 进入等待打开文件提示状态
    dispatch_async(dispatch_get_main_queue(), ^{
        [appDelegate.window addSubview:appDelegate.app_spinner];
        [appDelegate.app_spinner startAnimating];
    });
    
    if ([suffix isEqualToString:DOC_SUFFIX]) {
        // 2.将从邮箱或网页或其它应用下载的doc文件移动到指username/purefilename/suffix目录下
        // 获取文件的源路径
        NSString *srcFileDirectory = [appDelegate.filePersistence getDirectoryInDocumentWithName:INBOX_FOLDER_NAME];
        NSString *srcFilePath = [srcFileDirectory stringByAppendingPathComponent:postFilename];
        // 获取文件的目标路径
        NSString *desFileDirectory = [appDelegate.cookies getDOCFolderDirectory];
        NSString *desFilePath = [appDelegate.filePersistence getDirectoryInDocumentWithName:desFileDirectory];
        desFilePath = [desFilePath stringByAppendingPathComponent:postFilename];
        
        if ([fileManager fileExistsAtPath:srcFilePath isDirectory:NO]) {
            // 如果文件存在于目标路径中，先将其移除
            NSError *error = nil;
            if ([fileManager fileExistsAtPath:desFilePath isDirectory:NO]) {
                [fileManager removeItemAtPath:desFilePath error:nil];
            }
            
            // 从源路径移动文件到目标路径
            [fileManager moveItemAtPath:srcFilePath toPath:desFilePath error:&error];
            if (error) {
                [JCAlert alertWithMessage:@"移动文件出错" Error:error];
            }
        }
        
        // 3.将doc文件上传到服务器进行转换
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
    
    // 保存doc文件数据到inbox文件夹中
    if (docData && docData.length > 0) {
        NSString *docFileDirectory = [NSString stringWithFormat:@"%@/%@/%@", appDelegate.cookies.username, appDelegate.cookies.pureFileName, DOC_FOLDER_NAME];
        [appDelegate.filePersistence saveMutableData:docData ToFile:appDelegate.cookies.docFileName inDocumentWithDirectory:docFileDirectory];
    }
    else {
        [JCAlert alertWithMessage:@"打开文件失败，下载的数据为空"];
    }
    
    // 上传doc文件进行转换
    [self uploadFileWithSuffix:DOC_SUFFIX];
    
    // 清除需要直接打开的pdf文件
    [appDelegate.fileCleaner clearInboxFiles];
}

/* 下载该doc文件在服务器对应的zip包（如果已经存在） */
- (void)downloadZipFile {
    AppDelegate *appDelegate = APPDELEGATE;
    [appDelegate.urlConnector downloadFile:appDelegate.cookies.zipFileName
                                      Type:ZIP_SUFFIX
                        FromServerInFolder:appDelegate.cookies.pureFileName];
}

/* 获取下载成功的zip数据
 *
 * 参数
 * zipData : 由DownloadHanler回传
 */
- (void)getDownload_ZIP_Data:(NSMutableData *)zipData {
    if (zipData && zipData.length > 0) {
        AppDelegate *appDelegate = APPDELEGATE;
        
        // 保存zip数据
        if ([appDelegate.filePersistence saveMutableData:zipData toDocumentFile:appDelegate.cookies.zipFileName]) {
            // 清除pureFileName文件夹中的PDF文件夹
            [appDelegate.fileCleaner clearFilesInPDFFolder:appDelegate.cookies.pureFileName];
            
            // 解压zip包并将zip包中的数据移动到对应位置
            NSString *zipFilePath = [appDelegate.filePersistence getDirectoryOfDocumentFileWithName:appDelegate.cookies.zipFileName];
            MyPDFCreator *pdfCreator = [[MyPDFCreator alloc] init];
            [pdfCreator unzipFilesInPath:zipFilePath];
            
            [appDelegate.fileCleaner clearFilesWithSuffix:ZIP_SUFFIX];
        }
    }
    else {
        [JCAlert alertWithMessage:@"下载zip文件失败"];
    }
}

/* 从服务器下载pdf文件数据 */
- (void)downloadPDFFile {
    // 在转换完成后从服务器的文件夹purefilename中下载pdf文件数据，并保存到username/purefilename/pdf/目录下
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.urlConnector downloadFile:appDelegate.cookies.pdfFileName
                                      Type:PDF_SUFFIX
                        FromServerInFolder:appDelegate.cookies.pureFileName];
}

/* 获取下载成功的pdf数据
 *
 * 参数
 * pdfData : 由DownloadHanler回传
 */
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
    NSString *filename = appDelegate.fileURL.lastPathComponent;
    [openInfo setObject:filename forKey:kLatest_FileName];
    
    // 生成时间戳
    NSDateFormatter *fileNameFormatter = [[NSDateFormatter alloc] init];
    [fileNameFormatter setDateFormat:@"yy年MM月dd日hh时mm分"];
    NSString *timeStamp = [fileNameFormatter stringFromDate:[NSDate date]];
    [openInfo setObject:timeStamp forKey:kLatest_OpenTime];
    
    // 添加到最近打开数组中
    [self updateLatestOpenWithRecord:openInfo];
    
    [self.tableView reloadData];
    
    appDelegate.mainPDFViewController = nil;
    appDelegate.mainPDFViewController = [[UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil]
                                         instantiateViewControllerWithIdentifier:MAINPDFVIEWCONTROLLER_ID];
    
    // 初始化PDF文件
    NSString *pdfFileDirectory = [appDelegate.cookies getPDFFolderDirectory];
    NSString *pdfFilePath = [appDelegate.filePersistence getDirectoryInDocumentWithName:pdfFileDirectory];
    pdfFilePath = [pdfFilePath stringByAppendingPathComponent:appDelegate.cookies.pdfFileName];
    appDelegate.mainPDFViewController.myPDFDocument = [[MyPDFDocument alloc] initWithPDFFilePath:pdfFilePath];
    
    appDelegate.loginViewController.request_openFileURL = NO;
    
    // 将main pdf viewcontroller压入栈中
    [appDelegate.rootViewController pushViewController:appDelegate.mainPDFViewController animated:YES];
}

#pragma mark - Quit Login

- (IBAction)quitLogin:(id)sender {
    AppDelegate *appDelegate = APPDELEGATE;
    appDelegate.cookies = nil;
    appDelegate.urlConnector = nil;
    appDelegate.urlConnector = [[URLConnector alloc] init];
    [appDelegate.latestViewController.navigationController popToViewController:appDelegate.loginViewController animated:YES];
}

@end
