//
//  MyMessageTableViewCell.h
//  WUZHAO
//
//  Created by yiyi on 15/7/26.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrivateLetter.h"

@interface MyMessageTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *avatarView;
@property (nonatomic, strong) IBOutlet UIView *messageView;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UIImageView *failedInfoIcon;


-(void)configureCellWithMessage:(Message*)message;
@end
