//
//  AddressTableViewCell.m
//  WUZHAO
//
//  Created by yiyi on 4/25/15.
//  Copyright (c) 2015 yiyi. All rights reserved.
//

#import "AddressTableViewCell.h"
#import "macro.h"
#import "UILabel+ChangeAppearance.h"

@implementation AddressTableViewCell

-(void)awakeFromNib
{
    [self initViews];
}

-(void)initViews
{

    [self.addressLabel setTextColor:[UIColor blackColor]];
    [self.detailAddressLabel setReadOnlyLabelAppearance];
    [self.addressLabel setFont:WZ_FONT_LARGE_SIZE];
    [self.detailAddressLabel setFont:WZ_FONT_SMALL_READONLY];
}


@end
