//
//  MyMessageTableViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/7/26.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "MyMessageTableViewCell.h"
#import "UIImageView+ChangeAppearance.h"
#import "UIImageView+WebCache.h"
#import "UILabel+ChangeAppearance.h"
#import "macro.h"

@implementation MyMessageTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self initView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initView
{
    //self.backgroundColor = [UIColor redColor];
    self.backgroundColor = [UIColor clearColor];
    [self.avatarView setRoundAppearanceWithBorder:THEME_COLOR_LIGHT_GREY borderWidth:1.0f];
    [self.messageView setBackgroundColor:rgba_WZ(132, 196, 114, 1)];
    [self.messageView.layer setCornerRadius:4.0f];
    self.messageView.layer.masksToBounds = YES;
    [self.messageLabel setBackgroundColor:[UIColor clearColor]];
    [self.messageLabel setFont:WZ_FONT_COMMON_SIZE];
    [self.messageLabel setTextColor:THEME_COLOR_DARK_GREY];
    [self.messageLabel setTextAlignment:NSTextAlignmentRight];
    [self.failedInfoIcon setHidden:YES];
}

-(void)configureCellWithMessage:(Message*)message
{
    self.messageLabel.text = message.content;
    CGRect frame = self.messageLabel.frame;
    CGSize maxSize = CGSizeMake( WZ_APP_SIZE.width -118.0f, FLT_MAX);
    CGSize newSize = [self.messageLabel sizeThatFits:maxSize];
    frame.size.height = newSize.height;
    self.messageLabel.frame = frame;
    CGRect messageViewFrame = self.messageView.frame;
    messageViewFrame.size.height = frame.size.height + 16;
    [self.messageView setFrame:messageViewFrame];
    if (message.isFailed)
    {
        [self.failedInfoIcon setHidden:NO];
    }
    else
    {
        [self.failedInfoIcon setHidden:YES];
    }
}



@end
