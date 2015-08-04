//
//  LoginViewController.h
//  WUZHAO
//
//  Created by yiyi on 14-12-15.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^loginSuccessBlock)(void);

@interface LoginViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *UserNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *PasswordTextField;
@property (strong, nonatomic) IBOutlet UIButton *LoginButton;
@property (strong, nonatomic) IBOutlet UILabel *forgotPasswordLabel;
@property (strong, nonatomic) loginSuccessBlock loginSuccess;


- (IBAction)LoginButtonPressed:(id)sender;


- (IBAction)userNameInputEnd:(id)sender;
- (IBAction)passWordInputEnd:(id)sender;
@end
