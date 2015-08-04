//
//  AddressSuggestDistrictTableViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/7/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "AddressSuggestDistrictTableViewCell.h"
#import "District.h"
#import "UIImageView+WebCache.h"
#import "macro.h"

@implementation AddressSuggestDistrictTableViewCell

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
    CGRect rect =  CGRectMake(8,9 , WZ_APP_SIZE.width - 16,199);
    self.maskView = [[UIView alloc]initWithFrame:rect];
    [self.maskView.layer setBackgroundColor:[THEME_COLOR_DARK_GREY_BIT_PARENT CGColor]];
    self.maskView.layer.cornerRadius = 3.0f;
    self.maskView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.maskView];
    
    [self.districtImageView.layer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [self.districtImageView.layer setCornerRadius:3.0f];
    self.districtImageView.layer.masksToBounds = YES;
    self.districtImageView.contentMode  = UIViewContentModeScaleAspectFill;
    
    [self.districtInfoLabel setTextColor:[UIColor whiteColor]];
    [self.districtInfoLabel setFont:WZ_FONT_HIRAGINO_SMALL_SIZE];
    [self.districtInfoLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.districtNameLabel setTextColor:[UIColor whiteColor]];
    [self.districtNameLabel setFont:WZ_FONT_HIRAGINO_LARGE_SIZE];
    [self.districtNameLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.contentView bringSubviewToFront:self.districtInfoLabel];
    [self.contentView bringSubviewToFront:self.districtNameLabel];
    [self.contentView sendSubviewToBack:self.districtImageView];
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
}

-(void)configureWithData:(SuggestAddress *)data
{
    District *district = data.districtInfo;
    
    [self.districtImageView sd_setImageWithURL:[NSURL URLWithString:district.defaultImageUrl]];
    self.districtNameLabel.text = district.districtName;
    self.districtInfoLabel.text = [NSString stringWithFormat:@"「 %@ 」",district.districtInfo];
    if (!district.districtInfo || [district.districtInfo isEqualToString:@""])
    {
        [self.districtInfoLabel setHidden:YES];
        [self.districtNameLabelVerticalSpacingToSuperView setConstant:74];
    }
    else
    {
        [self.districtInfoLabel setHidden:NO];
        [self.districtNameLabelVerticalSpacingToSuperView setConstant:64];
    }
}

@end
