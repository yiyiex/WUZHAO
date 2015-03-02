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

@implementation LaunchViewController

-(void)viewDidLoad
{
    [self setNavigationAppearance];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self initAppearance];
}

-(void)viewWillAppear:(BOOL)animated
{
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
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}
-(void)initAppearance
{
    [self.view setBackgroundColor:rgba_WZ(253, 253, 253, 1.0)];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"token"])
    {
        NSLog(@"user defaults in launch%@",[userDefaults objectForKey:@"token"]);
        sleep(1);
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MainTabBarViewController *main = [mainStoryboard instantiateViewControllerWithIdentifier:@"mainTabBarController"];
        [self showViewController:main sender:nil];
        sleep(1);
        
    }
    else
    {
        [self.LoginButton setHidden:NO];
        [self.RegisterButton setHidden:NO];
        [self.LoginButton setWitheBackGroundAppearance];
        [self.RegisterButton setDarkGreyBackGroundAppearance];
    }
}


@end
