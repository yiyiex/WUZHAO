//
//  UIRoundedImageView.m
//  WUZHAO
//
//  Created by yiyi on 14-12-23.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "UIRoundedImageView.h"
#define RADIUS  8.0

@implementation RoundImageView


-(void)willMoveToWindow:(UIWindow *)newWindow
{
    CALayer *roundedLayer = [self layer];
    [roundedLayer setMasksToBounds:YES];
    roundedLayer.cornerRadius = self.bounds.size.width/2;
    roundedLayer.borderColor = [[UIColor grayColor] CGColor];

}


-(void)setRoundCornerWithRadius:(float)radius
{
    CALayer *roundedLayer = [self layer];
    [roundedLayer setMasksToBounds:YES];
    roundedLayer.cornerRadius = radius;
   // roundedLayer.borderColor = [[UIColor grayColor] CGColor];
}
@end
