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
#import "JTImageLabel.h"
#import "UIRoundedImageView.h"

@interface PhotoDetailViewController : UIViewController <UIScrollViewDelegate>

//展示照片内容的控件
@property (nonatomic, strong) IBOutlet UIImageView * detailPhotoView;
@property (nonatomic, strong) IBOutlet UILabel *likeLabel;
@property (nonatomic, strong) IBOutlet UILabel *addressLabel;
//展示评论内容的控件
@property (strong, nonatomic) IBOutlet WPHotspotLabel *commentContentLabel;

//展示用户信息的控件
@property (nonatomic, weak) IBOutlet UIRoundedImageView *myImage;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

//数据源
@property (nonatomic, strong) WhatsGoingOn *whatsGoingOnItem;
@property (nonatomic, strong) NSArray *commentList;


//添加新的评论的控件
@property (strong, nonatomic) IBOutlet UIView *commentView; //评论输入控件的外部父view
@property (strong, nonatomic) IBOutlet UITextField *commentTextField;
@property (strong, nonatomic) IBOutlet UIButton *sendCommentButton;


- (void)configureView:(WhatsGoingOn *)whatsGoinOnItem;

//- (void)goToTheAddress:(User *)addressUser;
@end
