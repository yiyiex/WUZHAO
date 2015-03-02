//
//  GlobalAppearance.m
//  WUZHAO
//
//  Created by yiyi on 14-12-25.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "GlobalAppearance.h"
#import "macro.h"
#import "UIReadOnlyLabel.h"
#import "UIBoldBlackFontLabel.h"
#import "UIBlackLabel.h"
#import "UILightReadOnlyLabel.h"
#import "UIThemeLabel.h"
#import "WPHotspotLabel.h"

#import "CaptureItemContainerUIView.h"


@implementation GlobalAppearance


+(void)setGlobalAppearance
{
    [self setNavigationAppearance];
    //[self setTabBarAppearance];
    [self setLabelsAppearance];
    [self setButtonAppearance];
    [self setThemeLabelAppearance];
    
}

#pragma mark  =============set navigator appearance===========
+(void)setNavigationAppearance
{
    UINavigationBar *appearance = [UINavigationBar appearance];
    [appearance setBarTintColor:THEME_COLOR_WHITE];
    [appearance setTintColor:THEME_COLOR_DARK_GREY];
    [appearance setTitleTextAttributes:
     @{
       NSForegroundColorAttributeName:THEME_COLOR_BLACK,
       NSFontAttributeName:[UIFont boldSystemFontOfSize:18]
       
       }];
    [appearance setBarStyle:UIBarStyleDefault];
    
    //UIBarButtonItem *barItemAppearance = [UIBarButtonItem appearance];
    //[barItemAppearance setBackgroundImage:[UIImage new] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
}

    

#pragma mark ==============set TabBarAppearance==============
+(void)setTabBarAppearance
{
    UITabBar *appearance = [UITabBar appearance];
    [appearance setBarTintColor:VIEW_COLOR_DRAKGREY];
    [appearance setTintColor:[UIColor whiteColor]];
}


#pragma mark =============set Button Appearance==============
+(void)setButtonAppearance
{
    UIButton *appearance = [UIButton appearance];
    [appearance setTintColor:[UIColor whiteColor]];
    [appearance setBackgroundColor:VIEW_COLOR_BLACK];
    
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil]setBackgroundColor:[UIColor clearColor]];
    [[UIButton appearanceWhenContainedIn:[UITableViewCell class], nil] setBackgroundColor:[UIColor clearColor]];
    [[UIButton appearanceWhenContainedIn:[CaptureItemContainerUIView class], nil] setBackgroundColor:[UIColor blackColor]];
    
   
    
    
    
    
}

#pragma mark    ==========set Labels appearance=============
+(void)setLabelsAppearance
{
    [self setReadOnlyLabelAppearance];
    [self setBlodBlackLabelAppearance];
    [self setBlackLabelAppearance];
    [self setLightReadOnlyLabelAppearance];
    [self setWPHotLabelAppearance];
}

+(void)setReadOnlyLabelAppearance
{
    UIReadOnlyLabel *appearance = [UIReadOnlyLabel appearance];
    [appearance setTextColor:[UIColor darkGrayColor]];
    [appearance setFont:WZ_FONT__READONLY];
    //[appearance ]
    
}

+(void)setBlodBlackLabelAppearance
{
    UIBoldBlackFontLabel *appearance = [UIBoldBlackFontLabel appearance];
    [appearance setTextColor:[UIColor blackColor]];
    [appearance setFont:WZ_FONT_LARGE_SIZE];
    //[appearance ]
}

+(void)setBlackLabelAppearance
{
    UIBlackLabel *appearance = [UIBlackLabel appearance];
    [appearance setTextColor:[UIColor blackColor]];
    [appearance setFont:WZ_FONT_LARGE_SIZE];
    //[appearance ]
}

+(void)setLightReadOnlyLabelAppearance
{
    UILightReadOnlyLabel *appearance = [UILightReadOnlyLabel appearance];
    [appearance setTextColor:[UIColor lightGrayColor]];
    [appearance setFont:WZ_FONT__READONLY];
    //[appearance ]
}
+(void)setThemeLabelAppearance
{
    UIThemeLabel *appearance = [UIThemeLabel appearance];
    [appearance setTextColor:THEME_COLOR];
    [appearance setFont:WZ_FONT_COMMON_SIZE];
}

+(void)setWPHotLabelAppearance
{
    WPHotspotLabel *appearance = [WPHotspotLabel appearance];
    [appearance setFont:WZ_FONT__READONLY];
}
@end
