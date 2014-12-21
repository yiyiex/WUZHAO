//
//  ShareNavigationController.h
//  WUZHAO
//
//  Created by yiyi on 14-12-19.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShareNavigationControllerDelegate;

@interface ShareNavigationController : UINavigationController

-(void)showCameraWithParentController:(UIViewController *)parentController;

@property (nonatomic ,weak) id <ShareNavigationControllerDelegate> shareNavigationDelegate;
@end

@protocol ShareNavigationControllerDelegate <NSObject>

@optional
-(BOOL)willDismissNavigationController:(ShareNavigationController *)navigationController;

@end


