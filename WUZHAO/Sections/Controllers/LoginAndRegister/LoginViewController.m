//
//  LoginViewController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-15.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "LoginViewController.h"
#import "MainTabBarViewController.h"
#import "QDYHTTPClient.h"

#import "SVProgressHUD.h"

#import "NSString+SHA1WithSalt.h"

#import "UIButton+ChangeAppearance.h"
#import "UILabel+ChangeAppearance.h"

#import "macro.h"

#import "PhotoCommon.h"

@interface LoginViewController ()
@property (nonatomic,strong) NSString *userName;
@property (nonatomic,strong) NSString *password;
@property (nonatomic,strong) NSString *sPassword;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    [self drawLoginViewAppearance];
    


    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNavigationAppearance];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

   // [self.navigationItem setHidesBackButton:YES];
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}


#pragma mark - appearance

-(void)setNavigationAppearance
{
    [self setTitle:@"登录"];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    UIBarButtonItem *close = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"close_cha"] style:UIBarButtonItemStylePlain target:self action:@selector(returnToLaunch)];
    [self.navigationItem setLeftBarButtonItem:close];
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

-(BOOL)prefersStatusBarHidden
{
    return NO;
}

-(void)drawLoginViewAppearance
{
    float lineWidth = WZ_APP_FRAME.size.width - 72;
    float lineHeight = 0.5;
    float LineX = 36;
    float FirstLineY = self.UserNameTextField.frame.origin.y+27;
    float verticalDistance = 50;
    CGRect userNameLine = CGRectMake(LineX, FirstLineY, lineWidth, lineHeight);
    CGRect passwordLine = CGRectMake(LineX, FirstLineY+verticalDistance, lineWidth, lineHeight);
    
    [PhotoCommon drawALineWithFrame:userNameLine andColor:THEME_COLOR_LIGHT_GREY inLayer:self.view.layer];
    [PhotoCommon drawALineWithFrame:passwordLine andColor:THEME_COLOR_LIGHT_GREY inLayer:self.view.layer];
    
}
-(void)initView
{
    self.UserNameTextField.placeholder = @"用户名";
    self.UserNameTextField.keyboardType = UIKeyboardAppearanceDark;
    self.UserNameTextField.keyboardType = UIKeyboardTypeDefault;

    self.PasswordTextField.placeholder = @"密 码";
    self.PasswordTextField.keyboardType = UIKeyboardAppearanceDark;
    self.PasswordTextField.keyboardType = UIKeyboardTypeAlphabet;
    
    [self.LoginButton setTitle:@"登  录" forState:UIControlStateNormal];
    [self.LoginButton setDarkGreyBackGroundAppearance];
    [self.LoginButton setBigButtonAppearance];
    [self.LoginButton setEnabled:NO];
    
    [self.forgotPasswordLabel setThemeLabelAppearance];
    UITapGestureRecognizer *forgotPasswordClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(forgotPasswordLabelClick:)];
    [self.forgotPasswordLabel addGestureRecognizer:forgotPasswordClick];
    
}
#pragma mark - basic method

-(void)login
{
    NSURLSessionDataTask *loginTask = [[QDYHTTPClient sharedInstance]LoginWithUserName:self.userName password:self.password complete:^(NSDictionary *result,NSError *error)
                                       {
                                           // NSLog(@"got the result :***** %@ \nand the error %@",result,error);
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
                                                   
                                                   if ([[QDYHTTPClient sharedInstance] IsAuthenticated])
                                                   {
                                                       User *userInfo = [[QDYHTTPClient sharedInstance] currentUser];
                                                       [self setDefaultUserInfoWithUser:userInfo];
                                                       
                                                       UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                       MainTabBarViewController *main = [mainStoryboard instantiateViewControllerWithIdentifier:@"mainTabBarController"];
                                                       [self showViewController:main sender:nil];
                                                      // [self performSegueWithIdentifier:@"HasLogin" sender:nil];
                                                       self.LoginButton.enabled = YES;
                                                      
                                                       
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
    
    //检查输入是否为空
    if ([self.UserNameTextField.text isEqualToString:@""])
    {
        [self.LoginButton setEnabled:NO];
        return  false;
    }
    if ([self.PasswordTextField.text isEqualToString:@""])
    {
        [self.LoginButton setEnabled:NO];
        return false;
    }
    
    //检查输入是否合法
    
    
    //密码加密
    self.sPassword = [self.password SHA1];
    
    [self.LoginButton setEnabled:YES];
    return true;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - button action

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
        //[self performSegueWithIdentifier:@"register" sender:sender];
}

- (IBAction)userNameInputEnd:(id)sender {

    [self checkInput];
    [self.PasswordTextField becomeFirstResponder];
}

- (IBAction)passWordInputEnd:(id)sender {

    [self checkInput];
    [self.LoginButton setEnabled:YES];
    [self login];
    [self.LoginButton setEnabled:NO];
}

-(void)returnToLaunch
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)forgotPasswordLabelClick:(UITapGestureRecognizer *)gesture
{
    [self performSegueWithIdentifier:@"findPassword" sender:nil];
}

#pragma mark -textview delegate
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![self.UserNameTextField isExclusiveTouch])
    {
        [self.UserNameTextField resignFirstResponder];
        [self checkInput];
    }
    if (![self.PasswordTextField isExclusiveTouch])

    {
        [self.PasswordTextField resignFirstResponder];
        [self checkInput];
    }
}

#pragma mark -set userDefaultData
-(void)setDefaultUserInfoWithUser:(User *)user
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:user.UserID forKey:@"userId"];
    NSLog(@"%@",[userDefaults objectForKey:@"userId"]);
    if (![user.userToken isEqualToString:@""] && user.userToken)
    {
        [userDefaults setObject:user.userToken forKey:@"token"];
    }
    [userDefaults setObject:self.userName forKey:@"userName"];
    [userDefaults setObject:@"" forKey:@"avatarUrl"];
    NSLog(@"%lu",(long)[userDefaults integerForKey:@"userId"]);
    [userDefaults synchronize];
}



@end
