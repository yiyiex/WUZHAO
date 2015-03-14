//
//  MineViewController.h
//  WUZHAO
//
//  Created by yiyi on 14-12-17.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonContainerViewController.h"

#import "User.h"
#import "FootPrint.h"
#import "WhatsGoingOn.h"

@interface MineViewController : UIViewController <UITabBarDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *avator;

@property (strong, nonatomic) IBOutlet UILabel *selfDescriptionLabel;

@property (strong, nonatomic) IBOutlet UIView *rightHeaderView;
@property (strong, nonatomic) IBOutlet UILabel *followsNumLabel;
@property (strong, nonatomic) IBOutlet UILabel *followsLabel;
@property (strong, nonatomic) IBOutlet UILabel *followersNumLabel;
@property (strong, nonatomic) IBOutlet UILabel *photosNumLabel;

@property (strong, nonatomic) IBOutlet UIButton *mineButton;

@property (strong, nonatomic) IBOutlet UITabBar *selectToShowTabbar;

@property (nonatomic, strong ) User *userInfo; //当前页面载入的用户信息


- (IBAction)MineButtonClick:(id)sender;


@end
