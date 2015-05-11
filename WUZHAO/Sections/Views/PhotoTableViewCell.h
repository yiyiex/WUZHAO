//
//  PhotoTableViewCell.h
//  WUZHAO
//
//  Created by yiyi on 14-12-15.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DynamicResizingTableViewCell.h"
#import "LinkTextView.h"
#import "WhatsGoingOn.h"



@interface PhotoTableViewCell :DynamicResizingTableViewCell
@property (nonatomic, strong) WhatsGoingOn *content;

@property (nonatomic, weak) UIViewController *parentViewController;

@property (nonatomic, weak) IBOutlet UIImageView *homeCellAvatorImageView;
@property (nonatomic, weak) IBOutlet UILabel *postUserName;
@property (nonatomic, weak) IBOutlet UILabel *postUserSelfDescription;
@property (nonatomic, weak) IBOutlet UILabel *postTimeLabel;

@property (nonatomic, weak) IBOutlet UIImageView *homeCellImageView;

@property (nonatomic, weak) IBOutlet UIView *descriptionLabelView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *userNameLabelTopAlignment;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *descriptionViewVerticalSpaceToAddressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionViewHeightConstraint;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
//@property (nonatomic, weak) IBOutlet LinkTextView *descriptionLabel;

@property (nonatomic, weak) IBOutlet UIView *addressLabelView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressViewVerticalSpaceToImageView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *addressIcon;

@property (nonatomic, weak) IBOutlet UIView *likeLabelView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *likeLabelHeightConstraint;
@property (nonatomic, weak) IBOutlet UILabel *likeLabel;

@property (nonatomic, weak) IBOutlet UIView *commentLabelView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentViewHeightConstraint;
//@property (nonatomic, weak) IBOutlet WPHotspotLabel *commentLabel;

@property (weak, nonatomic) IBOutlet UIButton *zanClickButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zanClikeButtonVerticalSpaceToCommentViewConstraint;
@property (weak, nonatomic) IBOutlet UIButton *commentClickButton;

@property (weak, nonatomic) IBOutlet UIButton *moreButton;


-(void)setAppearance;
-(void)configureCellWithData:(WhatsGoingOn *)content parentController:(UIViewController *)parentController;
-(void)configureLikeViewWithData:(WhatsGoingOn *)content parentController:(UIViewController *)parentController;
-(void)configureComment;

@end
