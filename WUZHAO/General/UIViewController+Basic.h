//
//  UIViewController+Basic.h
//  WUZHAO
//
//  Created by yiyi on 15/8/2.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Basic)

@property (nonatomic) BOOL shouldRefreshData;
@property (nonatomic, strong) UIActivityIndicatorView *refreshaiv;


//设置统一回退按钮
-(void)setBackItem;

//push时隐藏底部tabbar
-(void)pushToViewController:(UIViewController *)viewController animated:(BOOL)animated hideBottomBar:(BOOL)hidden;

//设置透明导航栏
-(void)setTransparentNavigationBar;

//right bar aiv
-(void)setupRightBarRefreshAiv;
-(void)starRightBartAiv;
-(void)stopRightBarAiv;

@end
