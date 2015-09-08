//
//  POIItemCollectionViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/8/30.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "DistrictItemCollectionViewCell.h"
#import "macro.h"


@implementation DistrictItemCollectionViewCell

-(void)awakeFromNib
{
    if (self)
    {
        [self initView];
    }
}

-(void)initView
{
    [self.districtImage.layer setCornerRadius:3.0f];
    [self.districtImage.layer setMasksToBounds:YES];
    [self.maskView.layer setBackgroundColor:[THEME_COLOR_DARK_GREY_PARENT CGColor]];
    [self.maskView.layer setCornerRadius:3.0f];
    
    [self.DistrictNameLabel setFont:WZ_FONT_HIRAGINO_SIZE_16];
    [self.DistrictNameLabel setTextColor:THEME_COLOR_WHITE];
    
    
}
@end
