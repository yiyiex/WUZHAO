//
//  ShareNavigationController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-19.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "ShareNavigationController.h"
#import "CaptureCameraViewController.h"
@implementation ShareNavigationController


-(void)viewDidLoad
{
    self.navigationBarHidden = YES;
    self.hidesBottomBarWhenPushed = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    //[self showCameraContorller];
    
    
}

-(void)showCameraWithParentController:(UIViewController *)parentController
{
    CaptureCameraViewController *controller = [[CaptureCameraViewController alloc]init];
   // [self setViewControllers:[NSArray arrayWithObjects:controller,nil]];
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)showCameraContorller
{
    CaptureCameraViewController *controller = [[CaptureCameraViewController alloc]init];
    // [self setViewControllers:[NSArray arrayWithObjects:controller,nil]];
    [self presentViewController:controller animated:YES completion:nil];
}




@end
