//
//  UIImageView+ChangeAppearance.m
//  WUZHAO
//
//  Created by yiyi on 15/2/28.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "UIImageView+ChangeAppearance.h"

@implementation UIImageView (ChangeAppearance)

-(void)setRoundConerWithRadius:(float)radius
{
    CALayer *layer = self.layer;
    [layer setMasksToBounds:YES];
    [layer setBorderWidth:1.0f];
    layer.borderColor = [[UIColor clearColor]CGColor];
    layer.cornerRadius = radius;
}

@end
