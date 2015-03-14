//
//  UIButton+ChangeAppearance.m
//  WUZHAO
//
//  Created by yiyi on 15/3/2.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "UIButton+ChangeAppearance.h"
#import "macro.h"

@implementation UIButton (ChangeAppearance)

-(void)setBigButtonAppearance
{
    [self.layer setCornerRadius:4.0f];
    self.layer.masksToBounds = YES;
    //self.layer.borderWidth = 0.8;
    //self.layer.borderColor = [THEME_COLOR CGColor];
}

-(void)setNormalButtonAppearance
{
    [self.layer setCornerRadius:2.0f];
    self.layer.masksToBounds = YES;
    [self.titleLabel setFont:WZ_FONT_SMALL_SIZE];
}

-(void)setSmallButtonAppearance
{
    [self.layer setCornerRadius:1.0f];
    self.layer.masksToBounds = YES;

}

-(void)setWhiteBackGroundAppearance
{

    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [THEME_COLOR_DARK_GREY CGColor];
    self.backgroundColor = THEME_COLOR_WHITE;
    [self setTitleColor:THEME_COLOR_DARK_GREY forState:UIControlStateNormal];
}

-(void)setDarkGreyBackGroundAppearance
{

    self.backgroundColor = THEME_COLOR_DARK_GREY;
    [self setTitleColor:THEME_COLOR_WHITE forState:UIControlStateNormal];
}

-(void)setThemeFrameAppearence
{
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [THEME_COLOR_DARK CGColor];
    self.backgroundColor = THEME_COLOR_WHITE;
    [self setTitleColor:THEME_COLOR_DARK forState:UIControlStateNormal];
}

-(void)setThemeBackGroundAppearance
{
    self.backgroundColor = THEME_COLOR_DARK;
    [self setTitleColor:THEME_COLOR_WHITE forState:UIControlStateNormal];
}
-(void)DisableAppearance
{
    self.backgroundColor = THEME_COLOR_LIGHT_GREY;
    [self setEnabled:NO];
    
}

-(void)EnableAppearance
{
    self.backgroundColor = THEME_COLOR_DARK_GREY;
    [self setEnabled:YES];
}


@end
