//
//  ViewController.h
//  testLogin
//
//  Created by yiyi on 14-11-24.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPAPIClient.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate>




@property (nonatomic,weak) IBOutlet UITextField *UserNameField;
@property (nonatomic,weak) IBOutlet UITextField *PasswordField;
@property (nonatomic,weak) IBOutlet UIButton *LoginButton;

-(IBAction)LoginButtonPressed:(id)sender;
@end

