//
//  PhotoTableViewCell.h
//  WUZHAO
//
//  Created by yiyi on 14-12-15.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LinkTextView.h"
#import "WhatsGoingOn.h"

#import "CommentTextView.h"



@interface PhotoTableViewCell :UITableViewCell
@property (nonatomic, strong) WhatsGoingOn *content;

@property (nonatomic, weak) UIViewController *parentViewController;

//headview
@property (nonatomic, weak) IBOutlet UIView *headView;
@property (nonatomic, weak) IBOutlet UIImageView *homeCellAvatorImageView;

@property (nonatomic, weak) IBOutlet UILabel *postUserName;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *userNameLabelTopAlignment;

@property (nonatomic, weak) IBOutlet UILabel *postUserSelfDescription;

@property (nonatomic, weak) IBOutlet UILabel *postTimeLabel;
@property (nonatomic, weak) IBOutlet UIButton *followButton;

//photo
@property (nonatomic, weak) IBOutlet UIImageView *homeCellImageView;

//photos
@property (nonatomic, weak) IBOutlet UIView *imagesContainerView;
@property (nonatomic, weak) IBOutlet UICollectionView *imagesCollectionView;
@property (nonatomic, weak) IBOutlet UIScrollView *imagesScrollView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imagesContainerViewHeightConstrant;

//address
@property (nonatomic, weak) IBOutlet UIView *addressLabelView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *addressIcon;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *addressViewHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *addressViewVerticalSpaceToUpView;

//description
@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *descriptionViewVerticalSpaceToUpView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionViewHeightConstraint;

//zanview
@property (nonatomic, weak) IBOutlet UIView *likeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *likeLabelHeightConstraint;
@property (nonatomic, weak) IBOutlet UILabel *likeLabel;

//commentview
@property (nonatomic, weak) IBOutlet CommentTextView *commentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentViewVerticalSpaceToUpView;

@property (weak, nonatomic) IBOutlet UIButton *zanClickButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zanClikeButtonVerticalSpaceToCommentViewConstraint;
@property (weak, nonatomic) IBOutlet UIButton *commentClickButton;

@property (weak, nonatomic) IBOutlet UIButton *moreButton;

-(void)configureCellWithData:(WhatsGoingOn *)content parentController:(UIViewController *)parentController;
-(void)configureLikeViewWithData:(WhatsGoingOn *)content parentController:(UIViewController *)parentController;
-(void)configureComment;

@end
