//
//  LoginViewController.h
//  WUZHAO
//
//  Created by yiyi on 14-12-15.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *UserNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *PasswordTextField;
@property (strong, nonatomic) IBOutlet UIButton *LoginButton;

- (IBAction)LoginButtonPressed:(id)sender;

@end
