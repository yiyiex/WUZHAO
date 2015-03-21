//
//  RegistViewController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-25.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "RegistViewController.h"
#import "MainTabBarViewController.h"

#import "User.h"

#import "QDYHTTPClient.h"

#import "SVProgressHUD.h"
#import "PhotoCommon.h"

#import "UIButton+ChangeAppearance.h"

#import "macro.h"

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

    [self setNavigationAppearance];
    [self drawRegisterViewAppearance];
    [self initView];
    
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNavigationAppearance];
}

#pragma mark - appearance

-(void)setNavigationAppearance
{
    [self setTitle:@"注册"];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    UIBarButtonItem *close = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"close_cha"] style:UIBarButtonItemStylePlain target:self action:@selector(returnToLaunch)];
    [self.navigationItem setLeftBarButtonItem:close];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    //[[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}



-(void)initView
{
    
    
    self.emailTextField.placeholder = @"邮 箱";
    self.emailTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.emailTextField.keyboardType = UIKeyboardTypeAlphabet;
    
    self.userNameTextField.placeholder = @"用户名";
    self.userNameTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.userNameTextField.keyboardType = UIKeyboardTypeAlphabet;
    
    self.passwordTextField.placeholder = @"密 码";
    self.passwordTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.passwordTextField.keyboardType = UIKeyboardTypeAlphabet;
    
    
    [self.registerButton setTitle:@"注  册" forState:UIControlStateNormal];
    [self.registerButton setDarkGreyBackGroundAppearance];
    [self.registerButton setBigButtonAppearance];
    [self.registerButton setEnabled:NO];
    
}
-(void)drawRegisterViewAppearance
{
    float lineWidth = WZ_APP_FRAME.size.width - 72;
    float lineHeight = 0.5;
    float LineX = 36;
    float FirstLineY = self.emailTextField.frame.origin.y+27;
    float verticalDistance = 50;
    CGRect emailLine = CGRectMake(LineX, FirstLineY, lineWidth, lineHeight);

    CGRect userNameLine = CGRectMake(LineX, FirstLineY + verticalDistance, lineWidth, lineHeight);
    CGRect passwordLine = CGRectMake(LineX, FirstLineY + verticalDistance *2, lineWidth, lineHeight);
    [PhotoCommon drawALineWithFrame:emailLine andColor:THEME_COLOR_LIGHT_GREY inLayer:self.view.layer];
    [PhotoCommon drawALineWithFrame:userNameLine andColor:THEME_COLOR_LIGHT_GREY inLayer:self.view.layer];
      [PhotoCommon drawALineWithFrame:passwordLine andColor:THEME_COLOR_LIGHT_GREY inLayer:self.view.layer];
    
}
#pragma mark - buttn action
- (IBAction)registerToServer:(id)sender {
   if (![self checkInput])
   {
       return;
   }
    self.registerButton.enabled = NO;
    [self registerNewUser];

    
}
- (IBAction)emailTextFieldEditEnd:(id)sender {
    [self checkInput];

    [self.userNameTextField becomeFirstResponder];
}

- (IBAction)userNameTextFieldEditEnd:(id)sender {

    [self checkInput];
    [self.passwordTextField becomeFirstResponder];
}

-(IBAction)passwordTextFieldEditEnd:(id)sender
{

    [self checkInput];
    [self.registerButton setEnabled:YES];
    [self registerNewUser];
    [self.registerButton setEnabled:NO];
}

- (IBAction)dismisButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)returnToLaunch
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - basic methond


-(void)registerNewUser
{
    NSURLSessionDataTask *registerTask = [[QDYHTTPClient sharedInstance]RegisterWithUserName:self.userName email:self.email password:self.password complete:^(NSDictionary *result, NSError *error) {
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
                NSLog(@"register success info %@",result);
                NSDictionary *data = [result objectForKey:@"data"];
                User *user = [[User alloc]init];
                
                user.UserID = [(NSNumber *)[data objectForKey:@"user_id"] integerValue];
                user.userToken = [data objectForKey:@"token"];
                
                [self setDefaultUserInfoWithUser:user];
                if ( [[QDYHTTPClient sharedInstance] IsAuthenticated])
                {
                    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    MainTabBarViewController *main = [mainStoryboard instantiateViewControllerWithIdentifier:@"mainTabBarController"];
                    [self showViewController:main sender:nil];
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
    self.email= self.emailTextField.text;
    
    if ([self.userNameTextField.text isEqualToString:@""])
    {
        [self.registerButton setEnabled:NO];
        return false;
    }
    if ([self.passwordTextField.text isEqualToString:@""])
    {
        [self.registerButton setEnabled:NO];
        return false;
    }
    if ([self.emailTextField.text isEqualToString:@""])
    {
        [self.registerButton setEnabled:NO];
        return false;
    }
    [self.registerButton setEnabled:YES];
    return true;
}

#pragma mark - textView Delegate
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![self.userNameTextField isExclusiveTouch])
    {
        [self.userNameTextField resignFirstResponder];
        [self checkInput];
    }
    if (![self.passwordTextField isExclusiveTouch])
        
    {
        [self.passwordTextField resignFirstResponder];
        [self checkInput];
    }
    
    if (![self.emailTextField isExclusiveTouch])
    {
        [self.emailTextField resignFirstResponder];
        [self checkInput];
        
    }
}
#pragma mark -set userDefaultData
-(void)setDefaultUserInfoWithUser:(User *)user
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:user.UserID forKey:@"userId"];
    NSLog(@"%@",[userDefaults objectForKey:@"userId"]);
    [userDefaults setObject:self.userName forKey:@"userName"];
    if (![user.userToken isEqualToString:@""] && user.userToken)
    {
        [userDefaults setObject:user.userToken forKey:@"token"];
    }
    NSLog(@"%lu",(long)[userDefaults integerForKey:@"userId"]);
    [userDefaults synchronize];
}
@end
