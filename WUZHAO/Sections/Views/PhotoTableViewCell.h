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
@property (nonatomic, weak) IBOutlet UIImageView *descIcon;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (nonatomic,weak) IBOutlet UIImageView *addIcon;

@property (nonatomic, weak) IBOutlet UIView *likeLabelView;
@property (nonatomic, weak) IBOutlet UILabel *likeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *likeIcon;

@property (nonatomic, weak) IBOutlet UIView *commentLabelView;
@property (nonatomic, weak) IBOutlet UIImageView *commentIcon;
@property (nonatomic, weak) IBOutlet WPHotspotLabel *commentLabel;


@property (strong, nonatomic) IBOutlet UIView *zanView;
@property (weak, nonatomic  ) IBOutlet UIImageView *zanButtonIcon;
@property (strong, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic  ) IBOutlet UIImageView *commentButtonIcon;

@property (strong, nonatomic) IBOutlet UIButton *zanClickButton;
@property (strong, nonatomic) IBOutlet UIButton *commentClickButton;


-(void)setAppearance;
/*
//top View
@property (strong,nonatomic) UIView *viewTop;
@property (strong,nonatomic) UIImageView *avatorImageView;
@property (strong,nonatomic) UILabel *userNameLabel;
@property (strong,nonatomic) UILabel *userDescriptionLabel;
@property (strong,nonatomic) UILabel *postTimeLabel;

//center View
@property (strong,nonatomic) UIView *viewCenter;
@property (strong,nonatomic) UIImageView *postImageView;

//bottom View
@property (strong,nonatomic) UIView *viewBottom;
//location view
@property (strong,nonatomic) UIView *locationView;
@property (strong,nonatomic) UIImageView *locationIcon;
@property (strong,nonatomic) UILabel *locationLabel;
//description view
@property (strong,nonatomic) UIView *postDescriptionView;
@property (strong,nonatomic) UIImageView *postDescriptionIcon;
@property (strong,nonatomic) UILabel *postDescriptionLabel;
//comment view
@property (strong,nonatomic) UIView *commentView;
@property (strong,nonatomic) UIImageView *commentIcon;
@property (strong,nonatomic) WPHotspotLabel *commentLabel;

*/





@end
