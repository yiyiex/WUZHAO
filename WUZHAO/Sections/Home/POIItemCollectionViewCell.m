//
//  POIItemCollectionViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/8/31.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "POIItemCollectionViewCell.h"
#import "macro.h"

@implementation POIItemCollectionViewCell


-(void)awakeFromNib
{
    if (self)
    {
        [self initView];
    }
}

-(void)initView
{
    [self.POINameLabel.layer setBorderWidth:1.0f];
    [self.POINameLabel.layer setBorderColor:[THEME_COLOR CGColor]];
    [self.POINameLabel.layer setCornerRadius:10.0f];
    [self.POINameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.POINameLabel setTextColor:THEME_COLOR_DARK];
    [self.POINameLabel setFont:WZ_FONT_HIRAGINO_SIZE_13];
}

-(void)setPOIName:(NSString *)POIName
{
    [self.POINameLabel setText:POIName];
    /*
    CGRect frame = self.POINameLabel.frame;
    CGSize size = [self.POINameLabel sizeThatFits:CGSizeMake(WZ_APP_SIZE.width, 20)];
    frame.size = CGSizeMake(size.width + 28, size.height);
    [self.POINameLabel setFrame:frame];*/
    
}

@end
