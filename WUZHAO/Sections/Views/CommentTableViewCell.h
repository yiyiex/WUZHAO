//
//  CommentTableViewCell.h
//  WUZHAO
//
//  Created by yiyi on 15-1-8.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIRoundedImageView.h"
#import "UIThemeLabel.h"
#import "UIBlackLabel.h"
#import "UIReadOnlyLabel.h"

@interface CommentTableViewCell : UITableViewCell

@property (strong, nonatomic)  RoundImageView *userAvatorView;
@property (strong, nonatomic)  UIBlackLabel *userName;
@property (strong, nonatomic)  UIReadOnlyLabel *commentContent;
@property (strong, nonatomic)  UIThemeLabel *commentTime;

@end
