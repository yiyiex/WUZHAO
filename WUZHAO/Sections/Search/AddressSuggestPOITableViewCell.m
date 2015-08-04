//
//  AddressSuggestPOITableViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/7/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "AddressSuggestPOITableViewCell.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+ChangeAppearance.h"
#import "POI.h"
#import "macro.h"

@implementation AddressSuggestPOITableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    [self initViews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)initViews
{
    CGRect rect =  CGRectMake(8,8 , WZ_APP_SIZE.width - 16,199);
    self.maskView = [[UIView alloc]initWithFrame:rect];
    [self.maskView.layer setBackgroundColor:[THEME_COLOR_DARK_GREY_MORE_PARENT CGColor]];
    self.maskView.layer.cornerRadius = 3.0f;
    self.maskView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.maskView];
    
    [self.poiInfoImageView setBackgroundColor:THEME_COLOR];
    self.poiInfoImageView.layer.cornerRadius = 2.0f;
    
    [self.poiImageView.layer setCornerRadius:3.0f];
    self.poiImageView.layer.masksToBounds = YES;
    self.poiImageView.contentMode  = UIViewContentModeScaleAspectFill;
    [self.poiInfoLabel setTextColor:[UIColor whiteColor]];
    [self.poiInfoLabel setFont:WZ_FONT_COMMON_SIZE];
    [self.poiNameLabel setTextColor:[UIColor whiteColor]];
    [self.poiNameLabel setFont:WZ_FONT_HIRAGINO_MID_SIZE];
    [self.poiUserAvatarImageView setRoundAppearanceWithBorder:THEME_COLOR_LIGHT_GREY borderWidth:1.0f];
    [self.poiUserNameLabel setTextColor:[UIColor whiteColor]];
    [self.poiUserNameLabel setFont:WZ_FONT_SMALL_SIZE];
    
    [self.contentView bringSubviewToFront:self.poiInfoLabel];
    [self.contentView bringSubviewToFront:self.poiNameLabel];
    [self.contentView bringSubviewToFront:self.poiUserNameLabel];
    [self.contentView bringSubviewToFront:self.poiUserAvatarImageView];
    [self.contentView bringSubviewToFront:self.poiInfoImageView];
    [self.contentView sendSubviewToBack:self.poiImageView];
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    

}

-(void)configureWithData:(SuggestAddress *)data
{
    POI *poi = data.poiInfo;
    [self.poiImageView sd_setImageWithURL:[NSURL URLWithString:poi.defaultImageUrl]];
    self.poiNameLabel.text = poi.name;
    self.poiInfoLabel.text = poi.poiInfo;
    [self.poiUserAvatarImageView sd_setImageWithURL:[NSURL URLWithString:data.poiUser.avatarImageURLString]];
    self.poiUserNameLabel.text = [NSString stringWithFormat:@" By %@",data.poiUser.UserName];
    
    if ([poi.poiInfo isEqualToString:@""])
    {
        [self.poiInfoLabel setHidden:YES];
        [self.poiInfoImageView setHidden:YES];
    }
    else
    {
        [self.poiInfoLabel setHidden:NO];
        [self.poiInfoImageView setHidden:NO];
    }
    
    if ( !data.poiUser || [data.poiUser.UserName isEqualToString:@""])
    {
        [self.poiUserAvatarImageView setHidden:YES];
        [self.poiUserNameLabel setHidden:YES];
    }
    else
    {
        [self.poiUserAvatarImageView setHidden:NO];
        [self.poiUserNameLabel setHidden:NO];
    }
    
}

@end
