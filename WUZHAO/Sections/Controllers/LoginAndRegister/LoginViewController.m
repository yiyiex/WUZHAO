//
//  LoginViewController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-15.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "LoginViewController.h"
#import "AFHTTPAPIClient.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    [self checkLoginState];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
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
    
    NSString *userName = self.UserNameTextField.text;
    NSString *password = self.PasswordTextField.text;
    if([self checkInput])
    {
        [self loginWithUser:userName Password:password];
    }
    
}

-(void)checkLoginState
{
    if ([[AFHTTPAPIClient sharedInstance] IsAuthenticated])
    {
        [self performSegueWithIdentifier:@"HasLogin" sender:self];
    }

}


-(void)loginWithUser:(NSString *)userName Password:(NSString *)Password
{
    /* NSURLSessionDataTask *loginTask = [[AFHTTPAPIClient sharedInstance]LoginWithUserName:userName password:Password complete:^
     {
         if ( [[AFHTTPAPIClient sharedInstance] IsAuthenticated])
         {
             [self performSegueWithIdentifier:@"HasLogin" sender:self];
         }
         else
         {
     
         }
     }];*/
     
    
    NSLog(@"get login button pressed");
    [self performSegueWithIdentifier:@"HasLogin" sender:self];
    
}

-(BOOL)checkInput
{
    return true;
}
@end
