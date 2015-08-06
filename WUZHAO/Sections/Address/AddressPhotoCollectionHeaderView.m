//
//  AddressPhotoCollectionHeaderView.m
//  WUZHAO
//
//  Created by yiyi on 15/8/5.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "AddressPhotoCollectionHeaderView.h"
#import "macro.h"

@implementation AddressPhotoCollectionHeaderView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initView];
    }
    return self;
}
-(void)awakeFromNib
{
    [self initView];
}

-(void)initView
{
    [self.headLabel setTextColor:THEME_COLOR_LIGHT_GREY];
    [self.headLabel setFont:WZ_FONT_COMMON_BOLD_SIZE];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
