//
//  UIViewController+HideBottomBar.m
//  WUZHAO
//
//  Created by yiyi on 15/6/26.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "UIViewController+HideBottomBar.h"

@implementation UIViewController (HideBottomBar)
-(void)pushToViewController:(UIViewController *)viewController animated:(BOOL)animated hideBottomBar:(BOOL)hidden
{
    if (hidden)
    {
        //[[NSNotificationCenter defaultCenter ]postNotificationName:@"hideTabBar" object:nil];
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [self.navigationController pushViewController:viewController animated:animated];
}
@end
