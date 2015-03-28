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

-(void)setBoldReadOnlyLabelAppearance
{
    [self setTextColor:THEME_COLOR_LIGHT_GREY];
    [self setFont:WZ_FONT_READONLY_BOLD];
    //[appearance ]
    
}

-(void)setReadOnlyLabelAppearance
{
    [self setTextColor:THEME_COLOR_LIGHT_GREY];
    [self setFont:WZ_FONT_READONLY];
    //[appearance ]
    
}

-(void)setBoldSmallReadOnlyLabelAppearance
{
    [self setTextColor:THEME_COLOR_LIGHT_GREY];
    [self setFont:WZ_FONT_SMALL_READONLY_BOLD];
    //[appearance ]
    
}

-(void)setSmallReadOnlyLabelAppearance
{
    [self setTextColor:THEME_COLOR_LIGHT_GREY];
    [self setFont:WZ_FONT_SMALL_READONLY];
    //[appearance ]
    
}

-(void)setBlodBlackLabelAppearance
{
    [self setTextColor:THEME_COLOR_BLACK];
    [self setFont:WZ_FONT_COMMON_BOLD_SIZE];
    //[appearance ]
}

-(void)setBlackLabelAppearance
{
    [self setTextColor:THEME_COLOR_BLACK];
    [self setFont:WZ_FONT_COMMON_BOLD_SIZE];
    //[appearance ]
}

-(void)setBlodDarkGreyLabelAppearance
{
    [self setTextColor:THEME_COLOR_DARK_GREY];
    [self setFont:WZ_FONT_COMMON_BOLD_SIZE];
    //[appearance ]
}

-(void)setDarkGreyLabelAppearance
{
    [self setTextColor:THEME_COLOR_DARK_GREY];
    [self setFont:WZ_FONT_COMMON_SIZE];
    //[appearance ]
}

-(void)setThemeLabelAppearance
{
    [self setTextColor:THEME_COLOR];
    [self setFont:WZ_FONT_COMMON_SIZE];
}

-(void)setWPHotLabelAppearance
{
    // [self setTintColor:THEME_COLOR_LIGHT_GREY];
    [self setFont:WZ_FONT_READONLY];
}
@end
