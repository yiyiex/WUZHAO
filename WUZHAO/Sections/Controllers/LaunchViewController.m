//
//  LaunchViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/3/2.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "LaunchViewController.h"
#import "UIButton+ChangeAppearance.h"

#import "LoginViewController.h"
#import "RegistViewController.h"

#import "MainTabBarViewController.h"

#import "macro.h"
#import "QDYHTTPClient.h"

@implementation LaunchViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavigationAppearance];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self initAppearance];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNavigationAppearance];
     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"token"])
    {
        [self.LoginButton setHidden:YES];
        [self.RegisterButton setHidden:YES];
    }
}


-(void)setNavigationAppearance
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}
-(void)initAppearance
{
    [self.view setBackgroundColor:rgba_WZ(253, 253, 253, 1.0)];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"token"])
    {
        NSLog(@"user defaults in launch%@",[userDefaults objectForKey:@"token"]);
        sleep(1);
        [[QDYHTTPClient sharedInstance]updateLocalUserInfo];
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MainTabBarViewController *main = [mainStoryboard instantiateViewControllerWithIdentifier:@"mainTabBarController"];
        [self.navigationController pushViewController:main animated:YES];
        
    }
    else
    {
        [self.LoginButton setHidden:NO];
        [self.RegisterButton setHidden:NO];
        [self.LoginButton setBigButtonAppearance];
        [self.LoginButton setThemeFrameAppearence];
        [self.RegisterButton setBigButtonAppearance];
        [self.RegisterButton setThemeBackGroundAppearance];
    }
    
}




@end
