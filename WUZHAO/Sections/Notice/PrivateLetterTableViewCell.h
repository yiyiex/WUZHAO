//
//  PrivateLetterTableViewCell.h
//  WUZHAO
//
//  Created by yiyi on 15/7/25.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrivateLetter.h"
#import "BadgeLabel.h"

@interface PrivateLetterTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *userAvatorView;
@property (nonatomic, strong) IBOutlet UILabel *userName;
@property (nonatomic, strong) IBOutlet UILabel *time;
@property (nonatomic, strong) IBOutlet UILabel *lastMessage;
@property (nonatomic, strong) BadgeLabel *badge;


-(void)configureData:(Conversation *)conversation;

@end
