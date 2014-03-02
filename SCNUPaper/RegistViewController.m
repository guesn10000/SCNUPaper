//
//  RegistViewController.m
//  SCNUPaper
//
//  Created by Jymn_Chen on 14-2-11.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//

#import "RegistViewController.h"
#import "AppDelegate.h"
#import "URLConnector.h"

@interface RegistViewController () {
    BOOL shouldAdjust_;
}

@end

@implementation RegistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    self.username_textField.delegate    = self;
    self.nickname_textField.delegate    = self;
    self.password_textField.delegate    = self;
    self.confirmPass_textField.delegate = self;
    
    // 当键盘出现时发送消息给self
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    // 当键盘消失时发送消息给self
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (IBAction)regist:(id)sender {
    AppDelegate *appDelegate = [AppDelegate sharedDelegate];
    [appDelegate startSpinnerAnimating];
    
    URLConnector *urlConnector = [URLConnector sharedInstance];
    [urlConnector registWithUsername:self.username_textField.text
                            Nickname:self.nickname_textField.text
                            Password:self.password_textField.text
                             Confirm:self.confirmPass_textField.text];
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.password_textField || textField == self.confirmPass_textField) {
        shouldAdjust_ = YES;
    }
    else {
        shouldAdjust_ = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.username_textField) {
        [self.username_textField resignFirstResponder];
        [self.nickname_textField becomeFirstResponder];
    }
    else if (textField == self.nickname_textField) {
        [self.nickname_textField resignFirstResponder];
        [self.password_textField becomeFirstResponder];
    }
    else if (textField == self.password_textField) {
        [self.password_textField resignFirstResponder];
        [self.confirmPass_textField becomeFirstResponder];
    }
    else if (textField == self.confirmPass_textField) {
        [self dismissKeyboard:nil];
    }
    
    return YES;
}

#pragma mark - Keyboard Management

- (IBAction)dismissKeyboard:(id)sender {
    [self.username_textField    resignFirstResponder];
    [self.nickname_textField    resignFirstResponder];
    [self.password_textField    resignFirstResponder];
    [self.confirmPass_textField resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)noti {
    if (IS_IPHONE && shouldAdjust_) {
        self.username_textField.hidden = YES;
        self.nickname_textField.hidden = YES;
        self.username_label.hidden     = YES;
        self.nickname_label.hidden     = YES;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        
        CGSize keyboardSize = [[[noti userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        CGFloat height = keyboardSize.height;
        
        
        CGFloat tempX = self.username_textField.frame.origin.x;
        CGFloat tempY = self.view.bounds.size.height - height;
        
        CGRect confirmFrame = self.confirmPass_textField.frame;
        confirmFrame.origin = CGPointMake(tempX, tempY - 40.0);
        self.confirmPass_textField.frame = confirmFrame;
        
        CGRect passFrame = self.password_textField.frame;
        passFrame.origin = CGPointMake(tempX, tempY - 40.0 - 30.0 - 70.0);
        self.password_textField.frame = passFrame;
        
        CGRect confirmLableFrame = self.confirmPass_label.frame;
        confirmLableFrame.origin = CGPointMake(confirmLableFrame.origin.x, confirmFrame.origin.y);
        self.confirmPass_label.frame = confirmLableFrame;
        
        CGRect passLableFrame = self.password_label.frame;
        passLableFrame.origin = CGPointMake(passLableFrame.origin.x, passFrame.origin.y);
        self.password_label.frame = passLableFrame;
        
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)noti {
    if (IS_IPHONE && shouldAdjust_) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.1];
        
        self.password_label.frame        = CGRectMake(29.0, 270.0, 34.0, 21.0);
        self.confirmPass_label.frame     = CGRectMake(29.0, 340.0, 68.0, 21.0);
        self.password_textField.frame    = CGRectMake(112.0, 266.0, 180.0, 30.0);
        self.confirmPass_textField.frame = CGRectMake(112.0, 336.0, 180.0, 30.0);
        
        [UIView commitAnimations];
        
        self.username_label.hidden     = NO;
        self.nickname_label.hidden     = NO;
        self.username_textField.hidden = NO;
        self.nickname_textField.hidden = NO;
    }
}

@end
