//
//  RegistViewController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-25.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "RegistViewController.h"
#import "MainTabBarViewController.h"
#import "SetAvatarIntroductionViewController.h"

#import "User.h"

#import "QDYHTTPClient.h"

#import "SVProgressHUD.h"
#import "PhotoCommon.h"

#import "UIButton+ChangeAppearance.h"
#import "NSString+SHA1WithSalt.h"
#import "NSString+Verify.h"

#import "macro.h"

@interface RegistViewController()
{
    BOOL cancelRegist;
}
@property (nonatomic,strong) NSString *userName;
@property (nonatomic,strong) NSString *phoneNumber;
@property (nonatomic,strong) NSString *email;
@property (nonatomic,strong) NSString *password;
@property (nonatomic,strong) NSString *sPassword;

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
    
    cancelRegist = false;
    
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
}



-(void)initView
{
    self.emailTextField.placeholder = @"邮 箱";
    self.emailTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.emailTextField.keyboardType = UIKeyboardTypeAlphabet;
    [self.emailTextField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.emailTextField addTarget:self action:@selector(checkInput) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    
    self.userNameTextField.placeholder = @"用户名";
    self.userNameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.userNameTextField.keyboardType = UIKeyboardTypeDefault;
    [self.userNameTextField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.userNameTextField addTarget:self action:@selector(checkInput) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    self.passwordTextField.placeholder = @"密 码";
    self.passwordTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.passwordTextField.keyboardType = UIKeyboardTypeAlphabet;
    [self.passwordTextField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.passwordTextField addTarget:self action:@selector(checkInput) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    
    [self.registerButton setTitle:@"注  册" forState:UIControlStateNormal];
    [self.registerButton setThemeBackGroundAppearance];
    [self.registerButton setBigButtonAppearance];
    [self.registerButton setEnabled:NO];
    
    
    
    UIButton *testbutton = [[UIButton alloc]initWithFrame:CGRectMake(20, 300, 200, 30)];
    [testbutton setThemeBackGroundAppearance];
    [testbutton setTitle:@"test" forState:UIControlStateNormal];
    [testbutton addTarget:self action:@selector(testButtonClick) forControlEvents:UIControlEventTouchUpInside];
       // [self.view addSubview:testbutton];
    
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
#pragma mark - button action
- (IBAction)registerToServer:(id)sender {
   if (![self checkInput])
   {
       return;
   }
    if ([self.userNameTextField isFirstResponder])
    {
        [self.userNameTextField resignFirstResponder];
    }
    if ([self.emailTextField isFirstResponder])
    {
        [self.emailTextField resignFirstResponder];
    }
    if ([self.passwordTextField isFirstResponder])
    {
        [self.passwordTextField resignFirstResponder];
    }
    self.registerButton.enabled = NO;
    [self registerNewUser];

    
}
- (IBAction)emailTextFieldEditEnd:(id)sender {
    [self.userNameTextField becomeFirstResponder];
}

- (IBAction)userNameTextFieldEditEnd:(id)sender {
    
    [self.passwordTextField becomeFirstResponder];
    
}

-(IBAction)passwordTextFieldEditEnd:(id)sender
{
    if (![self checkInput])
    {
        return;
    }
    
    [self registerNewUser];
    [self.registerButton setEnabled:NO];
    self.passwordTextField.text = @"";
}

- (IBAction)dismisButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)returnToLaunch
{
    cancelRegist = true;
    if ([self.emailTextField isFirstResponder])
    {
        [self.emailTextField resignFirstResponder];
    }
    if ([self.userNameTextField isFirstResponder])
    {
        [self.userNameTextField resignFirstResponder];
    }
    if ([self.passwordTextField isFirstResponder])
    {
        [self.passwordTextField resignFirstResponder];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - basic methond


-(void)registerNewUser
{
    [[QDYHTTPClient sharedInstance]RegisterWithUserName:self.userName email:self.email password:self.sPassword complete:^(NSDictionary *result, NSError *error) {
        if (cancelRegist)
        {
            [SVProgressHUD dismiss];
            return ;
        }
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
                if ( [[QDYHTTPClient sharedInstance] IsAuthenticated])
                {
                    [self dismissViewControllerAnimated:YES completion:^{
                        
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"registSuccess" object:nil];
                    }];
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
    
    if ([self.emailTextField.text isEqualToString:@""])
    {
        [self.registerButton setEnabled:NO];
        return false;
    }
    if (![self.emailTextField.text isVaildEmail] )
    {
        [SVProgressHUD showInfoWithStatus:@"请输入正确的邮箱"];
        return false;
    }
    if ([self.userNameTextField.text isEqualToString:@""])
    {
        [self.registerButton setEnabled:NO];
        return false;
    }
    if (![self.userNameTextField.text isValidUsername] )
    {
        [SVProgressHUD showInfoWithStatus:@"请输入规范的用户名，可以包含汉子、字母、数字以及下划线"];
        return false;
    }

    if ([self.passwordTextField.text isEqualToString:@""])
    {
        [self.registerButton setEnabled:NO];
        return false;
    }
    if (![self.passwordTextField.text isValidPassword] )
    {
        [SVProgressHUD showInfoWithStatus:@"密码至少6位"];
        return false;
    }
    [self.registerButton setEnabled:YES];
   
    self.sPassword = [self.password SHA1];
    return true;
}

#pragma mark -textfield delegate

-(void)textFieldDidChanged:(id)sender
{
    if (![self.userNameTextField.text isEqualToString:@""] && ![self.passwordTextField.text isEqualToString:@""] && ![self.emailTextField.text isEqualToString:@""])
    {
        [self.registerButton setEnabled:YES];
    }
    else
    {
        [self.registerButton setEnabled:NO];
    }
}

#pragma mark - touch Delegate
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[[QDYHTTPClient sharedInstance]operationQueue]cancelAllOperations];
    if (![self.userNameTextField isExclusiveTouch])
    {
        [self.userNameTextField resignFirstResponder];
    }
    if (![self.passwordTextField isExclusiveTouch])
        
    {
        [self.passwordTextField resignFirstResponder];
    }
    
    if (![self.emailTextField isExclusiveTouch])
    {
        [self.emailTextField resignFirstResponder];
        
    }
}

-(void)testButtonClick
{
    UIStoryboard *introductionStoryboard = [UIStoryboard storyboardWithName:@"Introduction" bundle:nil];
    SetAvatarIntroductionViewController *introductionController = [introductionStoryboard instantiateViewControllerWithIdentifier:@"introduction"];
    [self.navigationController pushViewController:introductionController animated:YES];
}

@end
