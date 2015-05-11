//
//  FeedsFollowTableViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/4/14.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "FeedsFollowTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "UIButton+ChangeAppearance.h"
#import "UIImageView+ChangeAppearance.h"
#import "macro.h"

@implementation FeedsFollowTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setAppearance
{
    [self.avatarImageView setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    [self.avatarImageView setRoundConerWithRadius:self.avatarImageView.frame.size.width/2];
    
}
-(void)configureGesture
{
    if ([self.parentController respondsToSelector:@selector(avatarClick:)])
    {
        UITapGestureRecognizer *avatarClick = [[UITapGestureRecognizer alloc]initWithTarget:self.parentController action:@selector(avatarClick:)];
        [self.avatarImageView addGestureRecognizer:avatarClick];
        [self.avatarImageView setUserInteractionEnabled:YES];
    }
    /*
    if ([self.parentController respondsToSelector:@selector(followButtonClick:)])
    {
        UITapGestureRecognizer *feedsPhotoClick = [[UITapGestureRecognizer alloc]initWithTarget:self.parentController action:@selector(followButtonClick:)];
        [self.followButton addGestureRecognizer:feedsPhotoClick];
    }*/
    /*
    if ([self.parentController respondsToSelector:@selector(feedsUserClick:)])
    {
        UITapGestureRecognizer *feedsUserClick = [[UITapGestureRecognizer alloc]initWithTarget:self.parentController action:@selector(feedsUserClick:)];
        [self.contentLabel addGestureRecognizer:feedsUserClick];
        [self.contentLabel setUserInteractionEnabled:YES];
    }*/
}
-(void)configureFollowWithFeeds:(Feeds *)feeds parentController:(UIViewController *)parentController
{
    self.parentController = parentController;
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:feeds.feedsUser.avatarImageURLString]];
    
    NSString *content =  [NSString stringWithFormat:@"%@ 关注了你 %@",feeds.feedsUser.UserName,feeds.time];
    NSMutableAttributedString *attributeContent = [[NSMutableAttributedString alloc]initWithString:content];
    NSRange userNameRange = [content rangeOfString:feeds.feedsUser.UserName];
    NSRange timeRange = [content rangeOfString:feeds.time];
    NSRange staticStringRange = [content rangeOfString:@" 关注了你"];
    [attributeContent setAttributes:@{NSForegroundColorAttributeName:THEME_COLOR_DARK,NSFontAttributeName:WZ_FONT_COMMON_BOLD_SIZE} range:userNameRange];
    [attributeContent setAttributes:@{NSForegroundColorAttributeName:THEME_COLOR_LIGHT_GREY,NSFontAttributeName:WZ_FONT_COMMON_SIZE} range:timeRange];
    [attributeContent setAttributes:@{NSForegroundColorAttributeName:THEME_COLOR_LIGHT_GREY,NSFontAttributeName:WZ_FONT_COMMON_BOLD_SIZE} range:staticStringRange];
    self.contentLabel.attributedText = attributeContent;
    
   // [self.followButton setNormalButtonAppearance];
    /*
    if (feeds.feedsUser.isFollowed)
    {
        [self.followButton setTitle:@"＋" forState:UIControlStateNormal];
        [self.followButton setThemeBackGroundAppearance];
    }
    else
    {
        [self.followButton setTitle:@"－" forState:UIControlStateNormal];
        [self.followButton setThemeFrameAppearence];
    }*/
    
    //添加手势
    [self configureGesture];
    
    [self setAppearance];
    
}

@end
