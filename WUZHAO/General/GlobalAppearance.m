//
//  GlobalAppearance.m
//  WUZHAO
//
//  Created by yiyi on 14-12-25.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "GlobalAppearance.h"
#import "macro.h"


#import "CaptureItemContainerUIView.h"

#import "SVProgressHUD.h"


@implementation GlobalAppearance


+(void)setGlobalAppearance
{
    [self setNavigationAppearance];
    [self setTabBarAppearance];
    //[self setLabelsAppearance];
    [self setButtonAppearance];
    [SVProgressHUD setBackgroundColor:[UIColor darkGrayColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    
    
}

#pragma mark  =============set navigator appearance===========
+(void)setNavigationAppearance
{
    UINavigationBar *appearance = [UINavigationBar appearance];
    [appearance setBarTintColor:THEME_COLOR_WHITE];
    [appearance setTintColor:THEME_COLOR_DARK_GREY];
    [appearance setTitleTextAttributes:
     @{
       NSForegroundColorAttributeName:THEME_COLOR_DARK_GREY,
       NSFontAttributeName:WZ_FONT_TITLE,
       }];
    [appearance setBarStyle:UIBarStyleDefault];
    //UIBarButtonItem *barItemAppearance = [UIBarButtonItem appearance];
    //[barItemAppearance setBackgroundImage:[UIImage new] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
}

    

#pragma mark ==============set TabBarAppearance==============
+(void)setTabBarAppearance
{
    UITabBar *appearance = [UITabBar appearance];
    [appearance setBarTintColor:[UIColor whiteColor]];
    [appearance setTintColor:THEME_COLOR_DARK];
}


#pragma mark =============set Button Appearance==============
+(void)setButtonAppearance
{
   // UIButton *appearance = [UIButton appearance];
    //[appearance setTintColor:[UIColor whiteColor]];
    //[appearance setBackgroundColor:VIEW_COLOR_BLACK];
    
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil]setBackgroundColor:[UIColor clearColor]];
    [[UIButton appearanceWhenContainedIn:[UITableViewCell class], nil] setBackgroundColor:[UIColor clearColor]];
    [[UIButton appearanceWhenContainedIn:[CaptureItemContainerUIView class], nil] setBackgroundColor:[UIColor blackColor]];
    
   
    
    
    
    
}


@end
