//
//  UIViewController+HideBottomBar.h
//  WUZHAO
//
//  Created by yiyi on 15/6/26.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (HideBottomBar)

-(void)pushToViewController:(UIViewController *)viewController animated:(BOOL)animated hideBottomBar:(BOOL)hidden;

@end
