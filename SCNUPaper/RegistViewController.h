//
//  RegistViewController.h
//  SCNUPaper
//
//  Created by Jymn_Chen on 14-2-11.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegistViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *username_textField;
@property (weak, nonatomic) IBOutlet UITextField *nickname_textField;
@property (weak, nonatomic) IBOutlet UITextField *password_textField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPass_textField;

- (IBAction)regist:(id)sender;
- (IBAction)cancel:(id)sender;

- (IBAction)dismissKeyboard:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *username_label;
@property (weak, nonatomic) IBOutlet UILabel *nickname_label;
@property (weak, nonatomic) IBOutlet UILabel *password_label;
@property (weak, nonatomic) IBOutlet UILabel *confirmPass_label;
@end
