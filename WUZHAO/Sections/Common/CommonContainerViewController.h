//  一个公共组建，创建一个container，container可容纳多个viewcontroller，并实现controller之间的切换显示
//  CommonContainerViewController.h
//  WUZHAO
//
//  Created by yiyi on 14-12-15.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Animator.h"
#import "PanGestureInteractiveTransition.h"
#import "SwipeGestureInteractiveTransition.h"

@protocol CommonContainerViewControllerDelegate <NSObject>
-(void)finishLoadChildController:(UIViewController *)childController;
-(void)beginLoadChildController:(UIViewController *)childController;
@end

@interface CommonContainerViewController : UIViewController

/// The gesture recognizer responsible for changing view controllers. (read-only)
@property (nonatomic, strong) UIGestureRecognizer *interactiveTransitionGestureRecognizer;

@property (nonatomic) BOOL isInteractive;

@property (strong ,nonatomic) NSArray *ChildrenName;

@property (nonatomic,strong) NSString * currentSegueIdentifier;

@property (nonatomic,strong) UIViewController *currentViewController;
@property (nonatomic,weak) id<CommonContainerViewControllerDelegate> delegate;

-(instancetype)initWithChildren:(NSArray *)childrenName;
-(void)swapViewControllersWithIdentifier:(NSString *)identifier;


@end
