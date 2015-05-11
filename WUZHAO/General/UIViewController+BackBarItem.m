//
//  UIViewController+BackBarItem.m
//  WUZHAO
//
//  Created by yiyi on 15/4/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "UIViewController+BackBarItem.h"

@implementation UIViewController (BackBarItem)

-(void)setBackBarItem
{
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = backButton;
}

#pragma mark - backButtonPressed

-(void)backButtonPressed:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
