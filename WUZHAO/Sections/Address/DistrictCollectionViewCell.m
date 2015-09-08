//
//  DistrictCollectionViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/7/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "DistrictCollectionViewCell.h"
#import "macro.h"

@implementation DistrictCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        CGRect labelBackRect = CGRectMake(0, frame.size.height - 28, frame.size.width, 28);
        UIView *labelBackGroundView = [[UIView alloc]initWithFrame:labelBackRect];
        [labelBackGroundView setBackgroundColor:THEME_COLOR_DARK_GREY_PARENT];
        
        CGRect rect = CGRectMake(8, frame.size.height - 24, frame.size.width - 16, 20);
        self.name = [[UILabel alloc]initWithFrame:rect];
        self.name.textColor = THEME_COLOR_WHITE;
        self.name.font = WZ_FONT_HIRAGINO_SMALL_SIZE;
    
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:labelBackGroundView];
        [self.contentView addSubview:self.name];
        [self.contentView setBackgroundColor:THEME_COLOR_LIGHT_GREY];
        
        [self.layer setCornerRadius:4.0f];
        self.layer.masksToBounds = YES;
       
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
}
@end
