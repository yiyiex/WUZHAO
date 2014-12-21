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
@property (nonatomic, weak) IBOutlet UIImageView *homeCellImageView;
@property (nonatomic, weak) IBOutlet UIImageView *homeCellAvatorImageView;
@property (nonatomic, weak) IBOutlet UILabel *likeLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet WPHotspotLabel *commentLabel;
@property (nonatomic,weak) IBOutlet UIButton *zanButton;

@property (nonatomic,weak) WhatsGoingOn *whatsGoingOnItem;
@end
