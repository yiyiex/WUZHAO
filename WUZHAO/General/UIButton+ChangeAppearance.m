//
//  UIButton+ChangeAppearance.m
//  WUZHAO
//
//  Created by yiyi on 15/3/2.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "UIButton+ChangeAppearance.h"
#import "UIImage+Color.h"
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
-(void)setNormalButtonWithBoldFontAppearance
{
    [self.layer setCornerRadius:2.0f];
    self.layer.masksToBounds = YES;
    [self.titleLabel setFont:WZ_FONT_SMALLER_BOLD_SIZE];
}

-(void)setSmallButtonAppearance
{
    [self.layer setCornerRadius:1.0f];
    self.layer.masksToBounds = YES;
    [self.titleLabel setFont:WZ_FONT_SMALL_SIZE];

}

-(void)setWhiteBackGroundAppearance
{

    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [THEME_COLOR_DARK_GREY CGColor];
    [self setBackgroundImage:[UIImage imageWithColor:THEME_COLOR_WHITE] forState:UIControlStateNormal];
    [self setTitleColor:THEME_COLOR_DARK_GREY forState:UIControlStateNormal];
}

-(void)setGreyBackGroundAppearance
{
    [self clearFrame];
   [self setBackgroundImage:[UIImage imageWithColor:THEME_COLOR_LIGHT_GREY_MORE_PARENT] forState:UIControlStateNormal];
    [self setTitleColor:THEME_COLOR_LIGHT_GREY forState:UIControlStateNormal];
    [self setTitleColor:THEME_COLOR_LIGHT_GREY forState:UIControlStateHighlighted];
}
-(void)setDarkGreyParentBackGroundAppearance
{
    [self clearFrame];
    [self setBackgroundImage:[UIImage imageWithColor:THEME_COLOR_DARK_GREY_PARENT] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:THEME_COLOR_DARK_GREY_PARENT] forState:UIControlStateHighlighted];
    [self setBackgroundImage:[UIImage imageWithColor:THEME_COLOR_DARK_GREY_PARENT] forState:UIControlStateDisabled];
    [self setTitleColor:THEME_COLOR_WHITE forState:UIControlStateNormal];
    [self setTitleColor:THEME_COLOR_WHITE forState:UIControlStateHighlighted];
    
}
-(void)setDarkGreyBackGroundAppearance
{

    [self clearFrame];
    [self setBackgroundImage:[UIImage imageWithColor:THEME_COLOR_DARK_GREY] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:THEME_COLOR_DARK_GREY] forState:UIControlStateHighlighted];
    [self setBackgroundImage:[UIImage imageWithColor:THEME_COLOR_DARK_GREY] forState:UIControlStateDisabled];
    [self setTitleColor:THEME_COLOR_WHITE forState:UIControlStateNormal];
    [self setTitleColor:THEME_COLOR_WHITE forState:UIControlStateHighlighted];
    
}


-(void)setThemeFrameAppearence
{
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [THEME_COLOR_DARK CGColor];
      [self setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [self setTitleColor:THEME_COLOR_DARK forState:UIControlStateNormal];
    [self setTitleColor:THEME_COLOR_DARKER forState:UIControlStateHighlighted];
}

-(void)setThemeBackGroundAppearance
{
    [self clearFrame];
    [self setBackgroundColor:THEME_COLOR_DARK];
    
   // [self setBackgroundImage:[UIImage imageWithColor:THEME_COLOR_DARK] forState:UIControlStateNormal];
   // [self setBackgroundImage:[UIImage imageWithColor:THEME_COLOR_DARKER] forState:UIControlStateHighlighted];
    [self setBackgroundImage:[UIImage imageWithColor:THEME_COLOR_LIGHT_GREY] forState:UIControlStateDisabled];
    
    [self setTitleColor:THEME_COLOR_WHITE forState:UIControlStateNormal];
    [self setTitleColor:THEME_COLOR_WHITE forState:UIControlStateHighlighted];
}

-(void)clearFrame
{
    self.layer.borderWidth = 0;
    self.layer.borderColor = [[UIColor clearColor]CGColor];
    
}



@end
