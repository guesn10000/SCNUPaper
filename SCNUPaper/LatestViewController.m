//
//  LatestViewController.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-22.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "LatestViewController.h"
#import "AppDelegate.h"
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
    
#ifdef LOCAL_TEST
    self.navigationItem.rightBarButtonItem.title = @"本地测试";
#else
    self.navigationItem.leftBarButtonItem.title   = @"";
    self.navigationItem.leftBarButtonItem.enabled = NO;
#endif
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 加载登陆用户最近打开的文件列表
    AppDelegate       *appDelegate     = [AppDelegate sharedDelegate];
    JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
    self.userslist_ = [filePersistence loadMutableDictionaryFromDocumentFile:LATEST_OPEN_FILENAME];
    if (self.userslist_) {
        self.latestOpenArray_ = [self.userslist_ objectForKey:appDelegate.cookies.username];
        if (!self.latestOpenArray_) {
            self.latestOpenArray_ = [[NSMutableArray alloc] init];
        }
    }
    else {
        self.userslist_       = [[NSMutableDictionary alloc] init];
        self.latestOpenArray_ = [[NSMutableArray alloc] init];
    }
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 当视图将要消失时移除窗口中的spinners
    [[AppDelegate sharedDelegate] stopSpinnerAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    
    NSDictionary *latestInfo  = [self.latestOpenArray_ objectAtIndex:indexPath.row];
    cell.textLabel.text       = [latestInfo objectForKey:kLatest_FileName]; // 文件名
    cell.detailTextLabel.text = [latestInfo objectForKey:kLatest_OpenTime]; // 打开时间
    
    return cell;
}

#pragma mark - UITableView Delegate

/* 点击表格后，打开对应的doc或pdf文件 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AppDelegate  *appDelegate  = [AppDelegate sharedDelegate];
    NSDictionary *openInfo     = self.latestOpenArray_[indexPath.row];
    NSString     *filename     = openInfo[kLatest_FileName];
    NSString     *pureFileName = [filename substringToIndex:filename.length - 4];
    NSString     *fileDirect   = nil;
    
    if ([filename hasSuffix:DOC_SUFFIX]) {
        fileDirect = [NSString stringWithFormat:@"%@/%@/%@", appDelegate.cookies.username, pureFileName, DOC_FOLDER_NAME];
    }
    else if ([filename hasSuffix:PDF_SUFFIX]) {
        fileDirect = [NSString stringWithFormat:@"%@/%@/%@", appDelegate.cookies.username, pureFileName, PDF_FOLDER_NAME];
    }
    else {
        return;
    }
    
    JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
    NSString *filePath = [filePersistence getDirectoryInDocumentWithName:fileDirect];
    filePath = [filePath stringByAppendingPathComponent:filename];
    appDelegate.fileURL = [NSURL fileURLWithPath:filePath];
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
        if (info) {
            lastFileName = info[kLatest_FileName];
            openFileName = openInfo[kLatest_FileName];
            if ([lastFileName isEqualToString:openFileName]) {
                break;
            }
        }
    }
    
    // 没有打开过该文件
    if (i == self.latestOpenArray_.count) {
        // 如果最近打开记录超出最大记录数
        if (self.latestOpenArray_.count == kMaximum_LatestOpen) {
            // 清空最后一项对应的文件夹
            NSDictionary *tempInfo = [self.latestOpenArray_ lastObject];
            NSString *tempFileName = tempInfo[kLatest_FileName];
            tempFileName = [tempFileName substringToIndex:tempFileName.length - 4];
            [[FileCleaner sharedInstance] clearFolder:tempFileName];
            
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
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    [self.userslist_ setObject:self.latestOpenArray_ forKey:appDelegate.cookies.username];
    [[JCFilePersistence sharedInstance] saveMutableDictionary:self.userslist_ toDocumentFile:LATEST_OPEN_FILENAME];
}

#pragma mark - Open File

- (void)openFileURL {
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
#ifdef LOCAL_TEST
    NSString *filename;
    if ([appDelegate.cookies.username isEqualToString:TEMP_USERNAME]) {
        filename = @"中国的绘画精神.pdf";
//        filename = @"一页纸工程.pdf";
    }
    else if ([appDelegate.cookies.username isEqualToString:ROOT_USERNAME]) {
        filename = @"中国的绘画精神（长篇）.pdf";
    }
    else {
        [JCAlert alertWithMessage:@"本地测试：登陆的是学生，不能进入本地测试功能"];
        return;
    }
    
    [appDelegate.cookies setFileNamesWithPDFFileName:filename];
    JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
    NSString *srcFilePath = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
    NSString *desFilePath = [filePersistence getDirectoryInDocumentWithName:[NSString stringWithFormat:@"%@/%@/%@", appDelegate.cookies.username, appDelegate.cookies.pureFileName, PDF_FOLDER_NAME]];
    desFilePath = [desFilePath stringByAppendingPathComponent:filename];
    [filePersistence copyFileFromPath:srcFilePath toPath:desFilePath];
    
    [self openPDFFile];
#else
    // 关闭打开文件请求
    appDelegate.loginViewController.request_openFileURL = NO;
    
    // 1.获取文件名
    NSString *filename = [appDelegate.fileURL lastPathComponent];
    
    // 2.打开从邮箱打开的或最近打开列表中的文件
    if ([filename hasSuffix:DOC_SUFFIX]) {
        [appDelegate.cookies setFileNamesWithDOCFileName:filename];
        [self uploadFileWithSuffix:DOC_SUFFIX]; // 上传doc文件到服务器进行转换
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
    AppDelegate *appDelegate  = [AppDelegate sharedDelegate];
    NSString    *pureFilename = appDelegate.cookies.pureFileName;
    NSString    *postFilename = [pureFilename stringByAppendingString:suffix];
    JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
    
    // 进入等待打开文件提示状态
    [appDelegate startSpinnerAnimating];
    
    if ([suffix isEqualToString:DOC_SUFFIX]) { // 打开doc文件
        appDelegate.fromInboxFile = NO;
        
        // 获取文件的源路径
        NSString *srcFileDirectory = [filePersistence getDirectoryOfInboxFolder];
        NSString *srcFilePath      = [srcFileDirectory stringByAppendingPathComponent:postFilename];
        
        // 获取文件的目标路径
        NSString *desFileDirectory = [appDelegate.cookies getDOCFolderDirectory];
        NSString *desFilePath      = [filePersistence getDirectoryInDocumentWithName:desFileDirectory];
        desFilePath = [desFilePath stringByAppendingPathComponent:postFilename];
        
        // 将从邮箱或网页或其它应用下载的doc文件移动到指username/purefilename/DOC目录下
        [filePersistence moveFileFromPath:srcFilePath toPath:desFilePath];
        
        // 将doc文件上传到服务器进行转换
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:desFilePath]) {
            URLConnector *urlConnector = [URLConnector sharedInstance];
            [urlConnector convertDocFileInPath:desFilePath toPDFFileInFolder:pureFilename];
        }
    }
    else if ([suffix isEqualToString:PDF_SUFFIX]) {
        [self downloadZipFile];
        [self downloadPDFFile];
        
        if (appDelegate.fromInboxFile) {
            [filePersistence removeFilesAtInboxFolder];
            appDelegate.fromInboxFile = NO;
        }
    }
    else {
        appDelegate.fromInboxFile = NO;
        return;
    }
}

#pragma mark - Download Files

/* 下载该doc文件在服务器对应的zip包（如果已经存在） */
- (void)downloadZipFile {
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    [[URLConnector sharedInstance] downloadFile:appDelegate.cookies.zipFileName
                                           Type:ZIP_SUFFIX
                             FromServerInFolder:appDelegate.cookies.pureFileName];
}

/* 获取下载成功的zip数据，zipData : 由DownloadHanler回传 */
- (void)getDownload_ZIP_Data:(NSMutableData *)zipData {
    if (zipData && zipData.length > 0) {
        AppDelegate       *appDelegate     = [AppDelegate       sharedDelegate];
        JCFilePersistence *filePersistence = [JCFilePersistence sharedInstance];
        
        // 保存zip数据到tmp文件夹中
        if ([filePersistence saveMutableData:zipData toTmpFile:appDelegate.cookies.zipFileName]) {
            // 解压前先清除pureFileName文件夹中的PDF文件夹
            [[FileCleaner sharedInstance] clearFilesInPDFFolder:appDelegate.cookies.pureFileName];
            
            // 解压zip包并将zip包中的数据移动到对应位置
            NSString *zipFilePath = [filePersistence getDirectoryOfTmpFileWithName:appDelegate.cookies.zipFileName];
            [[MyPDFCreator sharedInstance] unzipFilesInPath:zipFilePath];
            
            // 清空tmp目录下的文件，防止影响后面的解压
            [filePersistence removeFilesAtTmpFolder];
        }
    }
    else {
        [JCAlert alertWithMessage:@"下载zip文件失败"];
    }
}

/* 从服务器下载pdf文件数据 */
- (void)downloadPDFFile {
    // 在转换完成后从服务器的文件夹purefilename中下载pdf文件数据，并保存到username/purefilename/pdf/目录下
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    [[URLConnector sharedInstance] downloadFile:appDelegate.cookies.pdfFileName
                                           Type:PDF_SUFFIX
                             FromServerInFolder:appDelegate.cookies.pureFileName];
}

/* 获取下载成功的pdf数据，pdfData : 由DownloadHanler回传 */
- (void)getDownload_PDF_Data:(NSMutableData *)pdfData {
    if (pdfData && pdfData.length > 0) {
        AppDelegate *appDelegate = [AppDelegate sharedDelegate];
        NSString *pdfFileDirectory = [appDelegate.cookies getPDFFolderDirectory];
        [[JCFilePersistence sharedInstance] saveMutableData:pdfData ToFile:appDelegate.cookies.pdfFileName inDocumentWithDirectory:pdfFileDirectory];
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
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    
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
    NSString *pdfFilePath = [[JCFilePersistence sharedInstance] getDirectoryInDocumentWithName:pdfFileDirectory];
    if (pdfFilePath) {
        pdfFilePath = [pdfFilePath stringByAppendingPathComponent:appDelegate.cookies.pdfFileName];
        appDelegate.mainPDFViewController.myPDFDocument = [[MyPDFDocument alloc] initWithPDFFilePath:pdfFilePath];
        
        // 将main pdf viewcontroller压入栈中
        [appDelegate.rootViewController pushViewController:appDelegate.mainPDFViewController animated:YES];
    }
}

#pragma mark - Quit Login

/* 退出登陆 */
- (IBAction)quitLogin:(id)sender {
    
#ifdef LOCAL_TEST
    [self openFileURL];
#else
    // 重置cookies和urlconnector的参数，并返回登陆页面
    AppDelegate  *appDelegate  = [AppDelegate sharedDelegate];
    appDelegate.fileURL = nil;
    appDelegate.fromInboxFile = NO;
    URLConnector *urlConnector = [URLConnector sharedInstance];
    urlConnector.isLoginSucceed = NO;
    [appDelegate.cookies removeCookies];
    [appDelegate.latestViewController.navigationController popToViewController:appDelegate.loginViewController animated:YES];
#endif
    
}

- (IBAction)quitLogin_localTest:(id)sender {
    AppDelegate  *appDelegate  = [AppDelegate sharedDelegate];
    appDelegate.fileURL = nil;
    appDelegate.fromInboxFile = NO;
    URLConnector *urlConnector = [URLConnector sharedInstance];
    urlConnector.isLoginSucceed = NO;
    [appDelegate.cookies removeCookies];
    [appDelegate.latestViewController.navigationController popToViewController:appDelegate.loginViewController animated:YES];
}

@end
