//
//  PlaceRecommendTableViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/8/4.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "PlaceRecommendTableViewCell.h"
#import "UIImageView+ChangeAppearance.h"
#import "macro.h"
#import "Feeds.h"
#import "UIImageView+WebCache.h"

@implementation PlaceRecommendTableViewCell

- (void)awakeFromNib {
    [self initView];
    // Initialization code
}

-(void)initView
{
    [self.avatarImageView setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    [self.avatarImageView setRoundConerWithRadius:self.avatarImageView.frame.size.width/2];
    [self.feedsImageView setBackgroundColor:THEME_COLOR_LIGHT_GREY_MORE_PARENT];
    [self.feedsImageView setRoundConerWithRadius:1.0f];
    
    [self.contentTextView setFont:WZ_FONT_COMMON_SIZE];
    [self.contentTextView setTextColor:THEME_COLOR_DARK_GREY];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureWithFeeds:(Feeds *)feeds parentController:(UIViewController *)parentController;
{
    self.parentController = parentController;
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:feeds.feedsUser.avatarImageURLString]];
    [self.feedsImageView sd_setImageWithURL:[NSURL URLWithString:feeds.feedsPhoto.imageUrlString]];
    
    [self.contentTextView reset];
    
    NSString *content = [NSString stringWithFormat:@"%@  %@",feeds.content,feeds.time];
   
    NSMutableAttributedString *attributeContent = [[NSMutableAttributedString alloc]initWithString:content];
     NSRange wholeRange = NSMakeRange(0, [attributeContent length]);
     NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 4;
    [attributeContent setAttributes:@{NSForegroundColorAttributeName:THEME_COLOR_LIGHT_GREY,NSFontAttributeName:WZ_FONT_COMMON_SIZE,NSParagraphStyleAttributeName:paragraphStyle} range:wholeRange];
    NSRange timeRange = [content rangeOfString:feeds.time];
    [attributeContent setAttributes:@{NSForegroundColorAttributeName:THEME_COLOR_LIGHT_GREY,NSFontAttributeName:WZ_FONT_COMMON_SIZE} range:timeRange];
    [self.contentTextView reset];
    self.contentTextView.attributedText = attributeContent;
    if (feeds.feedsPOI.name && ![feeds.feedsPOI.name isEqualToString:@""])
    {
        [self.contentTextView linkPOINameWithPOI:feeds.feedsPOI];
        self.contentTextView.placeRecommendTextViewDelegate = (id<PlaceRecommendTextViewDelegate>)self.parentController;
    }
    
    [self updateContentTextViewFrame];
    //添加手势
    [self configureGesture];
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
