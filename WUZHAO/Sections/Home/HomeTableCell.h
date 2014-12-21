//
//  HomeTableCell.h
//  Dtest3
//
//  Created by yiyi on 14-10-23.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WhatsGoingOn;
@class WPHotspotLabel;

@interface HomeTableCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *HomeCellImageView;
@property (nonatomic, weak) IBOutlet UIImageView *HomeCellAvatorImageView;
@property (nonatomic, weak) IBOutlet UILabel *likeLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet WPHotspotLabel *commentLabel;

@property (nonatomic,weak) IBOutlet UIButton *ZanButton;

@property (nonatomic, strong) WhatsGoingOn *whatsGoinOnItem;

-(void)setAvatorImage;
@end
