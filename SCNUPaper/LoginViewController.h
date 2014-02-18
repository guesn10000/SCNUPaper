//
//  LoginViewController.h
//  论文批阅系统
//
//  Created by Jymn_Chen on 13-11-28.
//  Copyright (c) 2013年 Jymn_Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>

/* 选择老师或学生 */
@property (assign, nonatomic) BOOL isTeacher; // yes is teacher, no is student
@property (weak, nonatomic) IBOutlet UIButton *isTeacher_button;
@property (weak, nonatomic) IBOutlet UIButton *isStudent_button;
- (IBAction)select_teacher:(id)sender;
- (IBAction)select_student:(id)sender;

/* 输入用户名和密码 */
@property (weak, nonatomic) IBOutlet UITextField *input_username_textField;
@property (weak, nonatomic) IBOutlet UITextField *input_password_textField;
- (IBAction)dismissKeyboard:(id)sender; // 让键盘消失

/* 记住密码或自动登录 */
@property (assign, nonatomic) BOOL shouldRememberPassword;
@property (assign, nonatomic) BOOL shouldLoginAutomatically;
@property (weak, nonatomic) IBOutlet UIButton *remember_button;
@property (weak, nonatomic) IBOutlet UIButton *loginAutomatically_button;
- (IBAction)remeberPassword:(id)sender;
- (IBAction)loginAutomatically:(id)sender;

/* 登陆 */
- (IBAction)loginToServer:(id)sender;

/* YES表示处于请求打开File URL状态，NO表示处于正常登陆状态 */
@property (assign, nonatomic) BOOL request_openFileURL;

@end
