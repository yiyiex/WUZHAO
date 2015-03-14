//
//  UIView+ChangeAppearance.m
//  WUZHAO
//
//  Created by yiyi on 15/3/8.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "UIView+ChangeAppearance.h"
#import "macro.h"

@implementation UIView (ChangeAppearance)


-(void)setEnableButtonAppearance
{
    self.backgroundColor = THEME_COLOR_LIGHT_GREY_PARENT;
    
}

-(void)setDisableButtonAppearance
{

    
}


-(void)setRoundCornerAppearance
{
    [self setRoundCornerWithRadius:2.0];
}

-(void)setRoundCornerWithRadius:(float)radius
{
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}
@end
