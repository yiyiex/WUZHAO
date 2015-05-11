//
//  FeedsZanAndCommentTableViewCell.h
//  WUZHAO
//
//  Created by yiyi on 15/4/14.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feeds.h"
@interface FeedsZanAndCommentTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UILabel *contentLabel;
@property (nonatomic, strong) IBOutlet UIImageView *feedsImageView;

@property (nonatomic, weak) UIViewController *parentController;


-(void)setAppearance;
-(void)configureZanWithFeeds:(Feeds *)feeds parentController:(UIViewController *)parentController;
-(void)configureCommentWithFeeds:(Feeds *)feeds parentController:(UIViewController *)parentController;
;
@end
