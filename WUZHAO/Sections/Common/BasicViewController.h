//
//  BasicViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/8/2.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MineViewController.h"
#import "AddressViewController.h"
#import "HomeTableViewController.h"
#import "User.h"
#import "WhatsGoingOn.h"
#import "POI.h"

@interface BasicViewController : UIViewController

@property (nonatomic) BOOL shouldRefreshData;
@property (nonatomic, strong) UIActivityIndicatorView *refreshaiv;


-(void)setTransparentNav;
//right bar aiv
-(void)setupRightBarRefreshAiv;
-(void)starRightBartAiv;
-(void)stopRightBarAiv;

//basic transition
-(void)pushToViewController:(UIViewController *)viewController animated:(BOOL)animated hideBottomBar:(BOOL)hidden;
-(void)goToPersonalPageWithUserInfo:(User *)user;
-(void)goToPOIPhotoListWithPoi:(POI *)poi;
-(void)gotoPostDetailPageWithPost:(WhatsGoingOn *)item;

@end
