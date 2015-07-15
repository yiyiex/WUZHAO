//
//  RecommendUserTableViewCell.h
//  WUZHAO
//
//  Created by yiyi on 15/7/14.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface RecommendUserTableViewCell : UITableViewCell
@property (nonatomic,weak) IBOutlet UIView *titleView;
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;

@property (nonatomic,weak) IBOutlet UIImageView *avatorImageView;
@property (nonatomic,weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *userNameLabelTopAlignment;
@property (nonatomic,weak) IBOutlet UILabel *userDescriptionLabel;

@property (nonatomic,weak) IBOutlet UIButton *followButton;

@property (nonatomic, strong) User *cellUser;

- (IBAction)followButtonPressed:(UIButton *)sender;
-(void)configWithUser:(User *)user ;
@end

