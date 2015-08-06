//
//  BasicCollectionViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/8/4.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BasicCollectionViewController : UICollectionViewController

@property (nonatomic, copy) void(^getLatestDataBlock)();
@property (nonatomic, copy) void(^loadMoreDataBlock)();

@property (nonatomic,strong) NSMutableArray *datasource;

@property (nonatomic) BOOL shouldRefreshData;
@property (nonatomic, strong) UIActivityIndicatorView *refreshaiv;

-(void)initView;

-(void)setupRefreshControl;
-(void)getLatestData;

-(void)loadData;
-(void)endRefreshing;

@property (nonatomic) BOOL shouldLoadMore;
@property (nonatomic,strong) UIButton *loadMoreButton;
@property (nonatomic,strong) UIActivityIndicatorView *loadMoreAiv;
-(void)setupLoadMore;
-(void)loadMore;

-(void)pushToViewController:(UIViewController *)viewController animated:(BOOL)animated hideBottomBar:(BOOL)hidden;

@end
