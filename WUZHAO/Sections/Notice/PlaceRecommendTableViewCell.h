//
//  PlaceRecommendTableViewCell.h
//  WUZHAO
//
//  Created by yiyi on 15/8/4.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feeds.h"

@interface PlaceRecommendTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UITextView *contentTextView;
//@property (nonatomic, strong) IBOutlet UILabel *contentLabel;
@property (nonatomic, strong) IBOutlet UIImageView *feedsImageView;

-(void)configureWithFeeds:(Feeds *)feed;

@end
