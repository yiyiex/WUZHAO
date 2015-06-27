//
//  FeedsFollowTableViewCell.h
//  WUZHAO
//
//  Created by yiyi on 15/4/14.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feeds.h"
#import "NoticeContentTextView.h"

@interface FeedsFollowTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UILabel *contentLabel;
@property (nonatomic, strong) IBOutlet NoticeContentTextView *contentTextView;

//@property (nonatomic, strong) IBOutlet UIButton *followButton;

@property (nonatomic, weak) UIViewController *parentController;

-(void)setAppearance;
-(void)configureFollowWithFeeds:(Feeds *)feeds parentController:(UIViewController *)parentController;
@end
