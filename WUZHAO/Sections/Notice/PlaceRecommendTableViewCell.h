//
//  PlaceRecommendTableViewCell.h
//  WUZHAO
//
//  Created by yiyi on 15/8/4.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feeds.h"
#import "PlaceRecommendTextView.h"

@interface PlaceRecommendTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet PlaceRecommendTextView *contentTextView;
//@property (nonatomic, strong) IBOutlet UILabel *contentLabel;
@property (nonatomic, strong) IBOutlet UIImageView *feedsImageView;

@property (nonatomic, weak) UIViewController *parentController;

-(void)configureWithFeeds:(Feeds *)feeds parentController:(UIViewController *)parentController;

@end
