//
//  UIViewController+Basic.m
//  WUZHAO
//
//  Created by yiyi on 15/8/2.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "UIViewController+Basic.h"

@implementation UIViewController (Basic)

-(void)setBackItem
{
    //导航栏
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarItem;
}

-(void)setTransparentNavigationBar
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"transparent_nav"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"transparent_nav"];
}

-(void)pushToViewController:(UIViewController *)viewController animated:(BOOL)animated hideBottomBar:(BOOL)hidden
{
    if (hidden)
    {
        //[[NSNotificationCenter defaultCenter ]postNotificationName:@"hideTabBar" object:nil];
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [self.navigationController pushViewController:viewController animated:animated];
}

//navigation right refresh aiv
-(void)setupRightBarRefreshAiv
{
    self.refreshaiv = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc]initWithCustomView:self.refreshaiv];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}
-(void)starRightBartAiv
{
    [self.refreshaiv startAnimating];
}
-(void)stopRightBarAiv
{
    if (self.refreshaiv)
    {
        if ([self.refreshaiv isAnimating])
        {
            [self.refreshaiv stopAnimating];
        }
    }
}
@end
