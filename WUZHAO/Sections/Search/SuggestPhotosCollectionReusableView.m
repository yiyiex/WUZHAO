//
//  SuggestPhotosCollectionReusableView.m
//  WUZHAO
//
//  Created by yiyi on 15/8/30.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "SuggestPhotosCollectionReusableView.h"
#import "macro.h"
@implementation SuggestPhotosCollectionReusableView
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
    
    [self.refreshButton setTitle:@"" forState:UIControlStateNormal];
    
    [self.refreshButton setHidden:YES];
}
@end
