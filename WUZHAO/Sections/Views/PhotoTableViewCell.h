//
//  PhotoTableViewCell.h
//  WUZHAO
//
//  Created by yiyi on 14-12-15.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WhatsGoingOn.h"
#import "WPHotspotLabel.h"

#import "UIRoundedImageView.h"

@interface PhotoTableViewCell : UITableViewCell


@property (nonatomic, strong) IBOutlet UIImageView *homeCellAvatorImageView;
@property (nonatomic, strong) IBOutlet UILabel *postUserName;
@property (nonatomic, strong) IBOutlet UILabel *postUserSelfDescription;
@property (nonatomic, weak) IBOutlet UILabel *postTimeLabel;

@property (nonatomic, weak) IBOutlet UIImageView *homeCellImageView;

@property (nonatomic, weak) IBOutlet UIView *descriptionLabelView;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, strong) IBOutlet UIView *addressLabelView;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;

@property (nonatomic, weak) IBOutlet UIView *likeLabelView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *likeLabelHeightConstraint;
@property (nonatomic, weak) IBOutlet UILabel *likeLabel;

@property (nonatomic, weak) IBOutlet UIView *commentLabelView;
@property (nonatomic, weak) IBOutlet WPHotspotLabel *commentLabel;

@property (strong, nonatomic) IBOutlet UIButton *zanClickButton;
@property (strong, nonatomic) IBOutlet UIButton *commentClickButton;

@property (strong, nonatomic) IBOutlet UIButton *moreButton;


-(void)setAppearance;
@end
