//
//  MineViewController.h
//  WUZHAO
//
//  Created by yiyi on 14-12-17.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonContainerViewController.h"
#import "PhotosCollectionViewController.h"

#import "User.h"
#import "FootPrint.h"
#import "WhatsGoingOn.h"

@interface MineViewController : UIViewController <UITabBarDelegate,PhotoCollectionViewControllerDataSource>
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *scrollContentView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollContentViewHeightConstraint;

@property (strong, nonatomic) IBOutlet UIImageView *avator;

@property (strong, nonatomic) IBOutlet UIView *selfDescriptionView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *descriptionViewHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *descriptionTopConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *descriptionBottomConstraint;

@property (strong, nonatomic) IBOutlet UILabel *selfDescriptionLabel;

@property (strong, nonatomic) IBOutlet UIView *rightHeaderView;
@property (strong, nonatomic) IBOutlet UILabel *followsNumLabel;
@property (strong, nonatomic) IBOutlet UILabel *followsLabel;
@property (strong, nonatomic) IBOutlet UILabel *followersNumLabel;
@property (strong, nonatomic) IBOutlet UILabel *photosNumLabel;

@property (strong, nonatomic) IBOutlet UIButton *mineButton;

@property (strong, nonatomic) IBOutlet UITabBar *selectToShowTabbar;


@property (nonatomic, strong ) User *userInfo; //当前页面载入的用户信息

@property (nonatomic, strong) NSMutableArray * myPhotosCollectionDatasource;
@property (nonatomic, strong) NSMutableArray * myAddressListDatasource;

@property (nonatomic) BOOL shouldBackToTop;

- (IBAction)MineButtonClick:(id)sender;

-(void)getLatestData;
@end
