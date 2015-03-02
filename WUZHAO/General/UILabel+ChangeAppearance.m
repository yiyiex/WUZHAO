//
//  UILabel+ChangeAppearance.m
//  WUZHAO
//
//  Created by yiyi on 15/3/2.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "UILabel+ChangeAppearance.h"
#import "macro.h"

@implementation UILabel (ChangeAppearance)

-(void)setReadOnlyLabelAppearance
{
    [self setTextColor:[UIColor darkGrayColor]];
    [self setFont:WZ_FONT__READONLY];
    //[appearance ]
    
}

-(void)setBlodBlackLabelAppearance
{
    [self setTextColor:[UIColor blackColor]];
    [self setFont:WZ_FONT_LARGE_SIZE];
    //[appearance ]
}

-(void)setBlackLabelAppearance
{
    [self setTextColor:[UIColor blackColor]];
    [self setFont:WZ_FONT_LARGE_SIZE];
    //[appearance ]
}

-(void)setLightReadOnlyLabelAppearance
{
    [self setTextColor:[UIColor lightGrayColor]];
    [self setFont:WZ_FONT__READONLY];
    //[appearance ]
}
-(void)setThemeLabelAppearance
{
    [self setTextColor:THEME_COLOR];
    [self setFont:WZ_FONT_COMMON_SIZE];
}

-(void)setWPHotLabelAppearance
{
    [self setFont:WZ_FONT__READONLY];
}
@end
