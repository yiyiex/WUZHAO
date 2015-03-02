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

-(void)setNormalButtonAppearance
{
    [self.layer setCornerRadius:4.0f];
    self.layer.masksToBounds = YES;
    //self.layer.borderWidth = 0.8;
    //self.layer.borderColor = [THEME_COLOR CGColor];
}

-(void)setWitheBackGroundAppearance
{
    [self.layer setCornerRadius:4.0f];
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [THEME_COLOR_DARK_GREY CGColor];
    self.backgroundColor = THEME_COLOR_WHITE;
    [self setTitleColor:THEME_COLOR_DARK_GREY forState:UIControlStateNormal];
}

-(void)setDarkGreyBackGroundAppearance
{
    [self.layer setCornerRadius:4.0f];
    self.layer.masksToBounds = YES;
    self.backgroundColor = THEME_COLOR_DARK_GREY;
    [self setTitleColor:THEME_COLOR_WHITE forState:UIControlStateNormal];
}


-(void)setThemeBackGroundAppearance
{
    [self.layer setCornerRadius:4.0f];
    self.layer.masksToBounds = YES;
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
