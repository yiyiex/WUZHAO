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
    
    [self.contentTextView setEditable:NO];
    [self.contentTextView setFont:WZ_FONT_COMMON_SIZE];
    [self.contentTextView setTextColor:THEME_COLOR_DARK_GREY];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
