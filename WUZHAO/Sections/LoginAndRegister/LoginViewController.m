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
{
    BOOL cancelLogin;
}
@property (nonatomic,strong) NSString *userName;
@property (nonatomic,strong) NSString *password;
@property (nonatomic,strong) NSString *sPassword;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    [self drawLoginViewAppearance];
    
    cancelLogin = false;
    
   
    


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
    self.UserNameTextField.placeholder = @"用户名/邮箱";
    self.UserNameTextField.keyboardType = UIKeyboardAppearanceDefault;
    self.UserNameTextField.keyboardType = UIKeyboardTypeDefault;
    [self.UserNameTextField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.UserNameTextField addTarget:self action:@selector(checkInput) forControlEvents:UIControlEventEditingDidEndOnExit];

    self.PasswordTextField.placeholder = @"密 码";
    self.PasswordTextField.keyboardType = UIKeyboardAppearanceDefault;
    self.PasswordTextField.keyboardType = UIKeyboardTypeDefault;
    [self.PasswordTextField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.PasswordTextField addTarget:self action:@selector(checkInput) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    [self.LoginButton setTitle:@"登  录" forState:UIControlStateNormal];
   // [self.LoginButton setThemeFrameAppearence];
    [self.LoginButton setBigButtonAppearance];
    [self.LoginButton setGreyBackGroundAppearance];
    [self.LoginButton setEnabled:NO];
    
    [self.forgotPasswordLabel setThemeLabelAppearance];
    UITapGestureRecognizer *forgotPasswordClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(forgotPasswordLabelClick:)];
    [self.forgotPasswordLabel addGestureRecognizer:forgotPasswordClick];
    
}
#pragma mark - basic method

-(void)login
{
    NSString *loginType = @"nick";
    if ( [self.userName rangeOfString:@"@"].location != NSNotFound)
    {
        loginType = @"email";
    }
    
    NSURLSessionDataTask *loginTask = [[QDYHTTPClient sharedInstance]LoginWithUserName:self.userName password:self.sPassword loginType:loginType complete:^(NSDictionary *result,NSError *error)
                                       {
                                           if (cancelLogin)
                                           {
                                               [SVProgressHUD dismiss];
                                               return ;
                                           }
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
                                                       [self dismissViewControllerAnimated:YES completion:^{
                                                           [[NSNotificationCenter defaultCenter]postNotificationName:@"loginSuccess" object:nil];
                                                           [[QDYHTTPClient sharedInstance]getLatestNoticeNumber];
                                                       }];
                                                       
                                                       
                                                     
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
    [self.LoginButton setEnabled:YES];
    
    //检查输入是否合法
    
    
    //密码加密
    self.sPassword = [self.password SHA1];
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
    if ([self.UserNameTextField isFirstResponder])
    {
        [self.UserNameTextField resignFirstResponder];
    }
    if ([self.PasswordTextField isFirstResponder])
    {
        [self.PasswordTextField resignFirstResponder];
    }
    self.LoginButton.enabled = NO;
    self.PasswordTextField.text = @"";
    [self login];
   // [self performSegueWithIdentifier:@"HasLogin" sender:self];
    
}

- (IBAction)userNameInputEnd:(id)sender {

    [self checkInput];
    [self.PasswordTextField becomeFirstResponder];
}

- (IBAction)passWordInputEnd:(id)sender {

    [self checkInput];
    [self.LoginButton setEnabled:NO];
    [self performSelectorOnMainThread:@selector(login) withObject:nil waitUntilDone:YES];
  
}

-(void)returnToLaunch
{
    cancelLogin = true;
    if ([self.UserNameTextField isFirstResponder])
    {
        [self.UserNameTextField resignFirstResponder];
    }
    if ([self.PasswordTextField isFirstResponder])
    {
        [self.PasswordTextField resignFirstResponder];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)forgotPasswordLabelClick:(UITapGestureRecognizer *)gesture
{
    [self performSegueWithIdentifier:@"findPassword" sender:nil];
}

#pragma mark -touch delegate
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
#pragma mark -textfield delegate

-(void)textFieldDidChanged:(id)sender
{
    if (![self.UserNameTextField.text isEqualToString:@""] && ![self.PasswordTextField.text isEqualToString:@""] )
    {
        [self.LoginButton setThemeFrameAppearence];
        [self.LoginButton setEnabled:YES];
    }
    else
    {
        [self.LoginButton setGreyBackGroundAppearance];
        [self.LoginButton setEnabled:NO];
    }
}

#pragma mark -set userDefaultData

-(void)updateLocalUserInfo
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger userId = [userDefaults integerForKey:@"userId"];
    [[QDYHTTPClient sharedInstance]GetPersonalSimpleInfoWithUserId:userId whenComplete:^(NSDictionary *returnData) {
        if ([returnData objectForKey:@"data"])
        {
            User *user = [returnData objectForKey:@"data"];
            [userDefaults setObject:user.UserName forKey:@"userName"];
            [userDefaults setObject:user.avatarImageURLString forKey:@"avatarUrl"];
            [userDefaults synchronize];
        }
        else
        {
            NSLog(@"更新个人信息失败");
            [userDefaults removeObjectForKey:@"avatarUrl"];
            
        }
    }];
}





@end
