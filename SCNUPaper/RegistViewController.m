//
//  RegistViewController.m
//  SCNUPaper
//
//  Created by Jymn_Chen on 14-2-11.
//  Copyright (c) 2014年 Jymn_Chen. All rights reserved.
//

#import "RegistViewController.h"
#import "RegistAccount.h"

@interface RegistViewController ()

@end

@implementation RegistViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)regist:(id)sender {
    RegistAccount *registAccount = [RegistAccount sharedInstance];
    [registAccount registWithUsername:self.username_textField.text
                             Nickname:self.nickname_textField.text
                             Password:self.password_textField.text
                              Confirm:self.confirmPass_textField.text];
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)dismissKeyboard:(id)sender {
    [self.username_textField    resignFirstResponder];
    [self.nickname_textField    resignFirstResponder];
    [self.password_textField    resignFirstResponder];
    [self.confirmPass_textField resignFirstResponder];
}

@end
