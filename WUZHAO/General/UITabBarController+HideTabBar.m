//
//  UITabBarController+HideTabBar.m
//  WUZHAO
//
//  Created by yiyi on 15-1-8.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "UITabBarController+HideTabBar.h"

@implementation UITabBarController (HideTabBar)

-(BOOL)isTabBarHidden
{
    CGRect viewFrame = self.view.frame;
    CGRect tabBarFrame = self.tabBar.frame;
    return tabBarFrame.origin.y >= viewFrame.size.height;
}

-(void)setTabBarHidden:(BOOL)tabBarHidden
{
    [self setTabBarHidden:tabBarHidden animated:NO];
}

-(void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated
{

    BOOL isHidden = self.tabBarHidden;
    UIView *transitionView;
    if (hidden == isHidden)
    {
        return;
    }
    for (UIView *view in [[self.view.subviews reverseObjectEnumerator ] allObjects])
    {
        if ([view isKindOfClass:NSClassFromString(@"UITransitionView")])
        {
            transitionView = view;
        }
    }

    if (transitionView == nil)
    {
        NSLog(@"could not get the container view");
        return;
    }
    CGRect viewFrame = self.view.frame;
    CGRect tabBarFrame = self.tabBar.frame;
    CGRect containerFrame = transitionView.frame;
    tabBarFrame.origin.y = viewFrame.size.height - (hidden ? 0 : tabBarFrame.size.height);
    containerFrame.size.height = viewFrame.size.height - (hidden ? 0 :tabBarFrame.size.height);
    if (animated)
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.tabBar.frame = tabBarFrame;
            transitionView.frame = containerFrame;
        }];
    }
    else
    {
        [UIView animateWithDuration:0 animations:^{
            self.tabBar.frame = tabBarFrame;
            transitionView.frame = containerFrame;
        }];
        
    }
    
}

@end
