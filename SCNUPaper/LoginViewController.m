//
//  LoginViewController.m
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-28.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "URLConnector.h"
#import "Cookies.h"

#ifdef LOCAL_TEST
#import "LatestViewController.h"
#endif

#define SEL_RADIO_IMG      [UIImage imageNamed:@"RadioButton-Selected.png"]
#define UNSEL_RADIO_IMG    [UIImage imageNamed:@"RadioButton-Unselected.png"]
#define SEL_CHECKBOX_IMG   [UIImage imageNamed:@"cb_glossy_on.png"]
#define UNSEL_CHECKBOX_IMG [UIImage imageNamed:@"cb_glossy_off.png"]

@interface LoginViewController ()

@end

@implementation LoginViewController

#pragma mark - View life cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 获取基本参数
    NSUserDefaults *userDefaults   = [NSUserDefaults standardUserDefaults];
    NSString       *tempUsername   = [userDefaults objectForKey:LATEST_USERNAME];
    NSString       *tempPassword   = [userDefaults objectForKey:LATEST_PASSWORD];
    NSString       *tempIsTeacher  = [userDefaults objectForKey:IS_LATESTUSER_TEACHER];
    NSString       *tempRemembPass = [userDefaults objectForKey:SHOULD_REMEMBER_PASSWORD];
    NSString       *tempLoginAuto  = [userDefaults objectForKey:SHOULD_LOGIN_AUTOMATICALLY];
    
    // 老师或学生的单选框
    self.isTeacher = (tempIsTeacher && [tempIsTeacher isEqualToString:@"YES"]) ? YES : NO;
    if (self.isTeacher) {
        [self.isTeacher_button setImage:SEL_RADIO_IMG   forState:UIControlStateNormal];
        [self.isStudent_button setImage:UNSEL_RADIO_IMG forState:UIControlStateNormal];
    }
    else {
        [self.isTeacher_button setImage:UNSEL_RADIO_IMG forState:UIControlStateNormal];
        [self.isStudent_button setImage:SEL_RADIO_IMG   forState:UIControlStateNormal];
    }
    
    // 用户名输入框和密码输入框
    self.input_username_textField.text = tempUsername;
    self.input_password_textField.text = tempPassword;
    
    // 记住密码选项的复选框
    self.shouldRememberPassword = (tempRemembPass && [tempRemembPass isEqualToString:@"YES"]) ? YES : NO;
    if (self.shouldRememberPassword) {
        [self.remember_button setImage:SEL_CHECKBOX_IMG forState:UIControlStateNormal];
    }
    else {
        [self.remember_button setImage:UNSEL_CHECKBOX_IMG forState:UIControlStateNormal];
    }
    
    // 自动登录选项的复选框
    self.shouldLoginAutomatically = (tempLoginAuto && [tempLoginAuto isEqualToString:@"YES"]) ? YES : NO;
    if (self.shouldLoginAutomatically) {
        [self.loginAutomatically_button setImage:SEL_CHECKBOX_IMG forState:UIControlStateNormal];
    }
    else {
        [self.loginAutomatically_button setImage:UNSEL_CHECKBOX_IMG forState:UIControlStateNormal];
    }
    
    // 是否需要自动登录
    if (self.shouldLoginAutomatically) {
        [self loginToServer:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.input_username_textField.delegate = self;
    self.input_password_textField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View Options

- (IBAction)select_teacher:(id)sender {
    self.isTeacher = YES;
    [self.isTeacher_button setImage:SEL_RADIO_IMG   forState:UIControlStateNormal];
    [self.isStudent_button setImage:UNSEL_RADIO_IMG forState:UIControlStateNormal];
}

- (IBAction)select_student:(id)sender {
    self.isTeacher = NO;
    [self.isTeacher_button setImage:UNSEL_RADIO_IMG forState:UIControlStateNormal];
    [self.isStudent_button setImage:SEL_RADIO_IMG   forState:UIControlStateNormal];
}

- (IBAction)remeberPassword:(id)sender {
    self.shouldRememberPassword = !self.shouldRememberPassword;
    if (self.shouldRememberPassword) {
        [self.remember_button setImage:SEL_CHECKBOX_IMG forState:UIControlStateNormal];
    }
    else {
        [self.remember_button setImage:UNSEL_CHECKBOX_IMG forState:UIControlStateNormal];
    }
}

- (IBAction)loginAutomatically:(id)sender {
    self.shouldLoginAutomatically = !self.shouldLoginAutomatically;
    if (self.shouldLoginAutomatically) {
        [self.loginAutomatically_button setImage:SEL_CHECKBOX_IMG forState:UIControlStateNormal];
    }
    else {
        [self.loginAutomatically_button setImage:UNSEL_CHECKBOX_IMG forState:UIControlStateNormal];
    }
}

#pragma mark - Login

- (IBAction)loginToServer:(id)sender {
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    [appDelegate startSpinnerAnimating];
    
    if ([self loginVerify]) {
        
#ifdef LOCAL_TEST
        // 设置好参数并保存用户的临时信息
        URLConnector *urlConnector = [URLConnector sharedInstance];
        urlConnector.isLoginSucceed = YES;
        appDelegate.cookies = [[Cookies alloc] initWithUsername:self.input_username_textField.text
                                                       Password:self.input_password_textField.text];
        appDelegate.cookies.isTeacher = appDelegate.loginViewController.isTeacher;
        [appDelegate.cookies saveUserInfo];
        // push LatestViewController进栈
        [appDelegate.rootViewController pushViewController:appDelegate.latestViewController animated:YES];
        [appDelegate stopSpinnerAnimating];
#else
        [[URLConnector sharedInstance] loginWithUsername:self.input_username_textField.text
                                                Password:self.input_password_textField.text];
#endif
        
    }
    else {
        [JCAlert alertWithMessage:@"登陆失败，请检查您的用户名密码是否正确"];
        [appDelegate stopSpinnerAnimating];
    }
}

- (BOOL)loginVerify {
    if ([self.input_username_textField.text isEqual:TEMP_USERNAME] &&
        [self.input_password_textField.text isEqual:TEMP_PASSWORD]) {
        return YES;
    }
    else if ([self.input_username_textField.text isEqual:ROOT_USERNAME] &&
             [self.input_password_textField.text isEqual:ROOT_PASSWORD]) {
        return YES;
    }
    else if ([self.input_username_textField.text isEqualToString:STUDENT_USERNAME] &&
             [self.input_password_textField.text isEqualToString:STUDENT_PASSWORD]) {
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.input_username_textField) {
        [self.input_username_textField resignFirstResponder];
        [self.input_password_textField becomeFirstResponder];
    }
    else if (textField == self.input_password_textField) {
        [self dismissKeyboard:nil];
    }
    
    return YES;
}

- (IBAction)dismissKeyboard:(id)sender {
    [self.input_username_textField resignFirstResponder];
    [self.input_password_textField resignFirstResponder];
}

@end
