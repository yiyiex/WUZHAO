//  展示一张照片的详情，包括作者，照片内容和简要评论
//  PhotoDetailViewController.h
//  WUZHAO
//
//  Created by yiyi on 14-12-17.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WhatsGoingOn.h"

#import "WPHotspotLabel.h"
#import "UIRoundedImageView.h"

@interface PhotoDetailViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
//展示照片内容的控件

@property (nonatomic, weak) IBOutlet UIImageView * detailPhotoView;
@property (nonatomic, weak) IBOutlet UILabel *likeLabel;

@property (nonatomic, weak) IBOutlet UILabel *addressLabel;

@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

//展示评论内容的控件
@property (nonatomic, weak) IBOutlet UIImageView *commentIcon;
@property (strong, nonatomic) IBOutlet WPHotspotLabel *commentContentLabel;

//展示用户信息的控件
@property (nonatomic, weak) IBOutlet UIImageView *userAvatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *userDescriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *postTimeLabel;


@property (nonatomic, weak) IBOutlet UIButton *zanButton;
@property (nonatomic, weak) IBOutlet UIButton *commentButton;
@property (nonatomic, weak) IBOutlet UIButton *moreButton;


//数据源
@property (nonatomic, strong) WhatsGoingOn *whatsGoingOnItem;
@property (nonatomic,strong) NSIndexPath *cellIndexInCollection;

- (void)configureView:(WhatsGoingOn *)whatsGoinOnItem;

//- (void)goToTheAddress:(User *)addressUser;
@end
