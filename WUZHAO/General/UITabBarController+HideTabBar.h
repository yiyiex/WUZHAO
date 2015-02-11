//
//  UITabBarController+HideTabBar.h
//  WUZHAO
//
//  Created by yiyi on 15-1-8.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarController (HideTabBar)

@property (nonatomic ,getter=isTabBarHidden) BOOL tabBarHidden;

-(void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;

@end
