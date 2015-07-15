//
//  UIButton+ChangeAppearance.h
//  WUZHAO
//
//  Created by yiyi on 15/3/2.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (ChangeAppearance)
-(void)setNormalButtonAppearance;
-(void)setNormalButtonWithBoldFontAppearance;
-(void)setBigButtonAppearance;
-(void)setSmallButtonAppearance;


-(void)setWhiteBackGroundAppearance;
-(void)setDarkGreyBackGroundAppearance;
-(void)setDarkGreyParentBackGroundAppearance;
-(void)setGreyBackGroundAppearance;

-(void)setThemeFrameAppearence;
-(void)setThemeBackGroundAppearance;

-(void)setWhiteFrameTransparentAppearence;
-(void)setThemeBackGroundWhiteFrameAppearance;


@end
