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


@property (nonatomic) BOOL showBackButton;
@property (strong, nonatomic)  UIImageView *avator;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (strong, nonatomic)  UILabel *selfDescriptionLabel;


@property (nonatomic, strong ) User *userInfo; //当前页面载入的用户信息

@property (nonatomic, strong) NSMutableArray * myPhotosCollectionDatasource;
@property (nonatomic, strong) NSMutableArray * myAddressListDatasource;

@property (nonatomic) BOOL shouldBackToTop;

- (IBAction)MineButtonClick:(id)sender;

-(void)getLatestData;
@end
