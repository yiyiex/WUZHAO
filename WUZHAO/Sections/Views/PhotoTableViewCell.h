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



@interface PhotoTableViewCell : UITableViewCell


@property (nonatomic, strong) IBOutlet UIImageView *homeCellAvatorImageView;
@property (nonatomic, weak) IBOutlet UILabel *postTimeLabel;

@property (nonatomic, weak) IBOutlet UIImageView *homeCellImageView;

@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UIImageView *descIcon;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (nonatomic,weak) IBOutlet UIImageView *addIcon;

@property (nonatomic, weak) IBOutlet UILabel *likeLabel;
@property (nonatomic, weak) IBOutlet WPHotspotLabel *commentLabel;


@property (strong, nonatomic) IBOutlet UIView *zanView;
@property (strong, nonatomic) IBOutlet UIView *commentView;
@property (strong, nonatomic) IBOutlet UILabel *zanClickLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentClickLabel;


@end
