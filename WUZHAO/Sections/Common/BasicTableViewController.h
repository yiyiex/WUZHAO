//
//  BasicTableViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/8/2.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "POI.h"

#import "UserListTableViewController.h"
#import "MineViewController.h"

@interface BasicTableViewController : UITableViewController

@property (nonatomic, copy) void(^getLatestDataBlock)();
@property (nonatomic, copy) void(^loadMoreDataBlock)();

@property (nonatomic,strong) NSMutableArray *datasource;

@property (nonatomic) BOOL shouldRefreshData;
@property (nonatomic, strong) UIActivityIndicatorView *refreshaiv;

-(void)initView;

-(void)setupRefreshControl;
-(void)getLatestData;

-(void)loadData;

@property (nonatomic) BOOL shouldLoadMore;
@property (nonatomic,strong) UIButton *loadMoreButton;
@property (nonatomic,strong) UIActivityIndicatorView *loadMoreAiv;
-(void)setupLoadMore;
-(void)loadMore;

//right bar aiv
-(void)setupRightBarRefreshAiv;
-(void)starRightBartAiv;
-(void)stopRightBarAiv;

//basic transition
#pragma mark - transiation
-(void)pushToViewController:(UIViewController *)viewController animated:(BOOL)animated hideBottomBar:(BOOL)hidden;
-(void)goToPersonalPageWithUserInfo:(User *)user;
#pragma mark - transition
-(void)goToPOIPhotoListWithPoi:(POI *)poi;

@end
