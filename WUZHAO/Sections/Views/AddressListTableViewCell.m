//
//  AddressListTableViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/7/21.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//
#import "AddressListTableViewCell.h"
#import "macro.h"
#import "UILabel+ChangeAppearance.h"

#define spacing 8
#define photoNumWidth 50
#define labelHeight 20

@implementation AddressListTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self initView];
}

-(instancetype)init
{
    self = [super init];
    [self initView];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(UILabel *)addressNameLabel
{
    if (!_addressNameLabel)
    {
        _addressNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(spacing, spacing, WZ_APP_SIZE.width - spacing*2 - photoNumWidth , labelHeight)];
        [self addSubview:_addressNameLabel];
    }
    return _addressNameLabel;
}
-(UILabel *)photoNumLabel
{
    if (!_photoNumLabel)
    {
        _photoNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width - spacing - photoNumWidth, spacing, photoNumWidth, labelHeight)];
        [self addSubview:_photoNumLabel];
    }
    return _photoNumLabel;
}

-(void)initView
{
    [self.addressNameLabel setFont:WZ_FONT_COMMON_SIZE];
    [self.addressNameLabel setThemeLabelAppearance];
    
    [self.photoNumLabel setTextAlignment:NSTextAlignmentRight];
    [self.photoNumLabel setFont:WZ_FONT_READONLY];
    [self.photoNumLabel setReadOnlyLabelAppearance];
    
}



@end
