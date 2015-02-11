//
//  RegistViewController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-25.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "RegistViewController.h"

#import "AFHTTPAPIClient.h"

#import "SVProgressHUD.h"

@interface RegistViewController()
@property (nonatomic,strong) NSString *userName;
@property (nonatomic,strong) NSString *phoneNumber;
@property (nonatomic,strong) NSString *email;
@property (nonatomic,strong) NSString *password;

@end

@implementation RegistViewController
@synthesize userName;
@synthesize password;

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = NO;
    
}


- (IBAction)registerToServer:(id)sender {
   if (![self checkInput])
   {
       return;
   }
    self.registerButton.enabled = NO;
    [self registerNewUser];

    
}

-(void)registerNewUser
{
    NSURLSessionDataTask *registerTask = [[AFHTTPAPIClient sharedInstance]RegisterWithUserName:self.userName email:self.email password:self.password complete:^(NSDictionary *result, NSError *error) {
        if (error)
        {
            [SVProgressHUD showErrorWithStatus:@"服务器访问失败"];
            self.registerButton.enabled = YES;
            return ;
        }
        else
        {
            if ([result objectForKey:@"msg"])
            {
                [SVProgressHUD showErrorWithStatus:[result objectForKey:@"msg"]];
                self.registerButton.enabled = YES;
                return ;
                
            }
            else
            {
                [SVProgressHUD dismiss];
                if ( [[AFHTTPAPIClient sharedInstance] IsAuthenticated])
                {
                    [self performSegueWithIdentifier:@"hasRegisterAndLogin" sender:nil];
                    return ;
                }
                
            }
        }
    
        
    }];
    [SVProgressHUD showWithStatus:@"注册中" maskType:SVProgressHUDMaskTypeBlack];
   // [SVProgressHUD showWithStatus:@"注册中"];
}

-(BOOL)checkInput
{
    self.userName = self.userNameTextField.text;
    self.password = self.passwordTextField.text;
    self.email= self.phoneNumberTextField.text;
    return YES;
}

#pragma mark ================textview delegate====================
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![self.userNameTextField isExclusiveTouch])
    {
        [self.userNameTextField resignFirstResponder];
    }
    if (![self.passwordTextField isExclusiveTouch])
        
    {
        [self.passwordTextField resignFirstResponder];
    }
}
@end
