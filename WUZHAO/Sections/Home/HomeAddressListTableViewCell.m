//
//  HomeAddressListTableViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/8/1.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "HomeAddressListTableViewCell.h"
#import "macro.h"

#import "UILabel+ChangeAppearance.h"
#import "UIImageView+ChangeAppearance.h"
#import "UIImageView+WebCache.h"

@implementation HomeAddressListTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self initView];
}

-(void)initView
{
    [self.addressNameLabel setThemeLabelAppearance];
    [self.addressDescriptionLabel setSmallReadOnlyLabelAppearance];
    
    //to do
    [self.enterButton setTintColor:THEME_COLOR_DARK];
    [self.enterButton setImage:[UIImage imageNamed:@"go_right"] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
