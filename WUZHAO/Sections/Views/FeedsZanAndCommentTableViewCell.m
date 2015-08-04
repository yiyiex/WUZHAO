//
//  FeedsZanAndCommentTableViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/4/14.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "FeedsZanAndCommentTableViewCell.h"
#import "UIImageView+WebCache.h"

#import "UIImageView+ChangeAppearance.h"
#import "macro.h"

@implementation FeedsZanAndCommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self setAppearance];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setAppearance
{
    [self.avatarImageView setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    [self.avatarImageView setRoundConerWithRadius:self.avatarImageView.frame.size.width/2];
    [self.feedsImageView setBackgroundColor:THEME_COLOR_LIGHT_GREY_MORE_PARENT];
    [self.feedsImageView setRoundConerWithRadius:1.0f];
}
-(void)configureGesture
{
    if ([self.parentController respondsToSelector:@selector(avatarClick:)])
    {
        UITapGestureRecognizer *avatarClick = [[UITapGestureRecognizer alloc]initWithTarget:self.parentController action:@selector(avatarClick:)];
        [self.avatarImageView addGestureRecognizer:avatarClick];
        [self.avatarImageView setUserInteractionEnabled:YES];
    }
    if ([self.parentController respondsToSelector:@selector(feedsPhotoClick:)])
    {
        UITapGestureRecognizer *feedsPhotoClick = [[UITapGestureRecognizer alloc]initWithTarget:self.parentController action:@selector(feedsPhotoClick:)];
        [self.feedsImageView addGestureRecognizer:feedsPhotoClick];
        [self.feedsImageView setUserInteractionEnabled:YES];
    }
    /*
    if ([self.parentController respondsToSelector:@selector(feedsUserClick:)])
    {
        UITapGestureRecognizer *feedsUserClick = [[UITapGestureRecognizer alloc]initWithTarget:self.parentController action:@selector(feedsUserClick:)];
        [self.contentLabel addGestureRecognizer:feedsUserClick];
        [self.contentLabel setUserInteractionEnabled:YES];
    }
     */
}
-(void)configureReplyCommentWithFeeds:(Feeds *)feeds parentController:(UIViewController *)parentController
{
    self.parentController = parentController;
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:feeds.feedsUser.avatarImageURLString]];
    [self.feedsImageView sd_setImageWithURL:[NSURL URLWithString:feeds.feedsPhoto.imageUrlString]];
    
    NSString *content =  [NSString stringWithFormat:@"%@ 回复了你的评论：%@  %@",feeds.feedsUser.UserName,feeds.content,feeds.time];
    NSMutableAttributedString *attributeContent = [[NSMutableAttributedString alloc]initWithString:content];
    NSRange userNameRange = [content rangeOfString:feeds.feedsUser.UserName];
    NSRange commentRange = [content rangeOfString:feeds.content];
    NSRange timeRange = [content rangeOfString:feeds.time];
    NSRange staticStringRange = [content rangeOfString:@" 回复了你的评论："];
    [attributeContent setAttributes:@{NSForegroundColorAttributeName:THEME_COLOR_DARK,NSFontAttributeName:WZ_FONT_COMMON_BOLD_SIZE} range:userNameRange];
    [attributeContent setAttributes:@{NSForegroundColorAttributeName:THEME_COLOR_DARKER_GREY,NSFontAttributeName:WZ_FONT_COMMON_SIZE}  range:commentRange];
    [attributeContent setAttributes:@{NSForegroundColorAttributeName:THEME_COLOR_LIGHT_GREY,NSFontAttributeName:WZ_FONT_COMMON_SIZE}  range:timeRange];
    [attributeContent setAttributes:@{NSForegroundColorAttributeName:THEME_COLOR_LIGHT_GREY,NSFontAttributeName:WZ_FONT_COMMON_BOLD_SIZE} range:staticStringRange];
    //self.contentLabel.attributedText = attributeContent;
    self.contentTextView.attributedText = attributeContent;
    [self.contentTextView linkUserNameWithUserList:@[feeds.feedsUser]];
     self.contentTextView.delegate = (id<NoticeContentTextViewDelegate>)self.parentController;
    [self updateContentTextViewFrame];
    //添加手势
    [self configureGesture];
}
-(void)configureCommentWithFeeds:(Feeds *)feeds parentController:(UIViewController *)parentController
{
    self.parentController = parentController;
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:feeds.feedsUser.avatarImageURLString]];
    [self.feedsImageView sd_setImageWithURL:[NSURL URLWithString:feeds.feedsPhoto.imageUrlString]];
    
    NSString *content =  [NSString stringWithFormat:@"%@ 评论了你的照片：%@  %@",feeds.feedsUser.UserName,feeds.content,feeds.time];
    NSMutableAttributedString *attributeContent = [[NSMutableAttributedString alloc]initWithString:content];
    NSRange userNameRange = [content rangeOfString:feeds.feedsUser.UserName];
    NSRange commentRange = [content rangeOfString:feeds.content];
    NSRange timeRange = [content rangeOfString:feeds.time];
    NSRange staticStringRange = [content rangeOfString:@" 评论了你的照片："];
    [attributeContent setAttributes:@{NSForegroundColorAttributeName:THEME_COLOR_DARK,NSFontAttributeName:WZ_FONT_COMMON_BOLD_SIZE} range:userNameRange];
    [attributeContent setAttributes:@{NSForegroundColorAttributeName:THEME_COLOR_DARKER_GREY,NSFontAttributeName:WZ_FONT_COMMON_SIZE}  range:commentRange];
    [attributeContent setAttributes:@{NSForegroundColorAttributeName:THEME_COLOR_LIGHT_GREY,NSFontAttributeName:WZ_FONT_COMMON_SIZE}  range:timeRange];
    [attributeContent setAttributes:@{NSForegroundColorAttributeName:THEME_COLOR_LIGHT_GREY,NSFontAttributeName:WZ_FONT_COMMON_BOLD_SIZE} range:staticStringRange];
    //self.contentLabel.attributedText = attributeContent;
    self.contentTextView.attributedText = attributeContent;
    [self.contentTextView linkUserNameWithUserList:@[feeds.feedsUser]];
    
     self.contentTextView.delegate = (id<NoticeContentTextViewDelegate>)self.parentController;
    [self updateContentTextViewFrame];
    //添加手势
    [self configureGesture];
}
-(void)configureZanWithFeeds:(Feeds *)feeds parentController:(UIViewController *)parentController
{
    self.parentController = parentController;
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:feeds.feedsUser.avatarImageURLString]];
    [self.feedsImageView sd_setImageWithURL:[NSURL URLWithString:feeds.feedsPhoto.imageUrlString]];
    
    NSString *content =  [NSString stringWithFormat:@"%@ 赞了你的照片  %@",feeds.feedsUser.UserName,feeds.time];
    NSMutableAttributedString *attributeContent = [[NSMutableAttributedString alloc]initWithString:content];
    NSRange userNameRange = [content rangeOfString:feeds.feedsUser.UserName];
    NSRange timeRange = [content rangeOfString:feeds.time];
    NSRange staticStringRange = [content rangeOfString:@" 赞了你的照片"];
    [attributeContent setAttributes:@{NSForegroundColorAttributeName:THEME_COLOR_DARK,NSFontAttributeName:WZ_FONT_COMMON_BOLD_SIZE} range:userNameRange];
    [attributeContent setAttributes:@{NSForegroundColorAttributeName:THEME_COLOR_LIGHT_GREY,NSFontAttributeName:WZ_FONT_COMMON_SIZE} range:timeRange];
    [attributeContent setAttributes:@{NSForegroundColorAttributeName:THEME_COLOR_LIGHT_GREY,NSFontAttributeName:WZ_FONT_COMMON_BOLD_SIZE} range:staticStringRange];
   // self.contentLabel.attributedText = attributeContent;
    self.contentTextView.attributedText = attributeContent;
    [self.contentTextView linkUserNameWithUserList:@[feeds.feedsUser]];
     self.contentTextView.delegate = (id<NoticeContentTextViewDelegate>)self.parentController;
    [self updateContentTextViewFrame];
    //添加手势
    [self configureGesture];
}

-(void)updateContentTextViewFrame
{
    CGRect frame = self.contentTextView.frame;
    CGSize maxSize = CGSizeMake( WZ_APP_SIZE.width -116.0f, FLT_MAX);
    CGSize newSize = [self.contentTextView sizeThatFits:maxSize];
    frame.size = newSize;
    self.contentTextView.frame = frame;
}

@end
