//
//  LoginViewController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-15.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "LoginViewController.h"
#import "AFHTTPAPIClient.h"

#import "SVProgressHUD.h"

#import "NSString+SHA1WithSalt.h"

@interface LoginViewController ()
@property (nonatomic,strong) NSString *userName;
@property (nonatomic,strong) NSString *password;
@property (nonatomic,strong) NSString *sPassword;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkLoginState];
    self.view.backgroundColor = [UIColor colorWithWhite:45.f/255.f alpha:1];


    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    //[self.navigationItem setHidesBackButton:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
   // [self.navigationItem setHidesBackButton:YES];
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)LoginButtonPressed:(id)sender {
    
    if(![self checkInput])
    {
        return;
    }
    self.LoginButton.enabled = NO;
    [self login];
   // [self performSegueWithIdentifier:@"HasLogin" sender:self];
    
}

- (IBAction)registerBtnPressed:(id)sender
{
        [self performSegueWithIdentifier:@"register" sender:sender];
}

-(void)checkLoginState
{
    if ([[AFHTTPAPIClient sharedInstance] IsAuthenticated])
    {
        [self performSegueWithIdentifier:@"HasLogin" sender:self];
    }

}


-(void)login
{
     NSURLSessionDataTask *loginTask = [[AFHTTPAPIClient sharedInstance]LoginWithUserName:self.userName password:self.sPassword complete:^(NSDictionary *result,NSError *error)
     {
         NSLog(@"got the result :***** %@ \nand the error %@",result,error);
        if (error)
        {
            [SVProgressHUD showErrorWithStatus:@"连接服务器失败"];
            self.LoginButton.enabled = YES;
            return ;
        }
         else
         {

             if ([result objectForKey:@"msg"])
             {

                 [SVProgressHUD showErrorWithStatus:[result objectForKey:@"msg"]];
                 self.LoginButton.enabled = YES;
                 return;
                 
             }
             else
             {
                 [SVProgressHUD dismiss];
                 
                 if ([[AFHTTPAPIClient sharedInstance] IsAuthenticated])
                 {
                     [self performSegueWithIdentifier:@"HasLogin" sender:nil];
                     self.LoginButton.enabled = YES;
                     User *userInfo = [[AFHTTPAPIClient sharedInstance] currentUser];
                     [self setDefaultUserInfoWithUser:userInfo];
                     
                 }
                 return;
             }
         }
     }];
    [SVProgressHUD showWithStatus:@"登录中"];
    NSLog(@"%@",loginTask);
    
   // [self performSegueWithIdentifier:@"HasLogin" sender:self];
    
}

-(BOOL)checkInput
{
    self.userName = self.UserNameTextField.text;
    self.password = self.PasswordTextField.text;
    
    self.sPassword = [self.password SHA1];
    return true;
}

#pragma mark ================textview delegate====================
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![self.UserNameTextField isExclusiveTouch])
    {
        [self.UserNameTextField resignFirstResponder];
    }
    if (![self.PasswordTextField isExclusiveTouch])

    {
        [self.PasswordTextField resignFirstResponder];
    }
}

#pragma mark ---------set userDefaultData
-(void)setDefaultUserInfoWithUser:(User *)user
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:user.UserID forKey:@"userId"];
    [userDefaults setObject:user.UserName forKey:@"userName"];
    NSLog(@"%lu",(long)[userDefaults integerForKey:@"userId"]);
    [userDefaults synchronize];
}



@end
