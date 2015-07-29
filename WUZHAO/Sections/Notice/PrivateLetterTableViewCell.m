//
//  PrivateLetterTableViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/7/25.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "PrivateLetterTableViewCell.h"
#import "UIImageView+ChangeAppearance.h"
#import "UIImageView+WebCache.h"
#import "UILabel+ChangeAppearance.h"
#import "macro.h"

@implementation PrivateLetterTableViewCell

- (void)awakeFromNib {
    [self initView];
    // Initialization code
}

-(void)initView
{
    [self.userAvatorView setRoundConerWithRadius:self.userAvatorView.frame.size.width/2];
    [self.userAvatorView setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    [self.userName setDarkGreyLabelAppearance];
    [self.userName setFont:WZ_FONT_COMMON_SIZE];
    [self.time setReadOnlyLabelAppearance];
    [self.time setTextAlignment:NSTextAlignmentRight];
    [self.lastMessage setFont:WZ_FONT_COMMON_SIZE];
    [self.lastMessage setTextColor:THEME_COLOR_LIGHT_GREY];
    
    //[self.lastMessage setReadOnlyLabelAppearance];
    
    self.badge = [[BadgeLabel alloc]initWithFrame:CGRectMake(self.userAvatorView.frame.origin.x+ self.userAvatorView.frame.size.width - 14, self.userAvatorView.frame.origin.y -4, 20, 20)];
    [self.badge setColor:rgba_WZ(242, 63, 54, 1)];
    
    [self.contentView addSubview:self.badge];
    //[self.badge setHidden:YES];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureData:(Conversation *)conversation
{
    [self.userAvatorView sd_setImageWithURL:[NSURL URLWithString:conversation.other.avatarImageURLString]];
    self.userName.text = conversation.other.UserName;
    self.time.text = conversation.latestMsg.createTime;
    self.lastMessage.text = conversation.latestMsg.content;
    if (conversation.newMessageCount >0)
    {
        [self.badge setNum:conversation.newMessageCount];
        [self.badge setHidden:NO];
    }
    else
    {
        [self.badge setHidden:YES];
    }
    
}

@end
