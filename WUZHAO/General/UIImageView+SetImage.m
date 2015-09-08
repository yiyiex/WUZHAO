//
//  UIImageView+SetImage.m
//  WUZHAO
//
//  Created by yiyi on 15/8/25.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "UIImageView+SetImage.h"
#import "ProgressIndicatorView.h"
#import "UIImageView+WebCache.h"

@implementation UIImageView (SetImage)

-(void)setImageWithImageUrlString:(NSString *)imageUrlString showProgress:(BOOL)showProgress
{
    [self setImageWithImageUrlString:imageUrlString placeholderImage:nil showProgress:showProgress complete:nil];
}

-(void)setImageWithImageUrlString:(NSString *)imageUrlString placeholderImage:(UIImage *)placeholderImage showProgress:(BOOL)showProgress complete:(SDWebImageCompletionBlock )completeBlock
{
    if (showProgress)
    {
        ProgressIndicatorView *indicator = [[ProgressIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
        [indicator setBackgroundColor:[UIColor clearColor]];
        indicator.delegate = self;
        indicator.progressBarColor = [UIColor whiteColor];
        indicator.progressBarShadowOpacity = .1f;
        indicator.progressBarArcWidth = 4.0f;
        indicator.wrapperColor = [UIColor colorWithRed: 240.0 / 255.0 green:240.0 / 255.0 blue: 240.0 / 255.0 alpha: .5];
        indicator.duration = 0.5f;
        [indicator setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
        [self addSubview:indicator];
        [indicator run:0.0f];
        [self sd_setImageWithURL:[NSURL URLWithString:imageUrlString] placeholderImage:placeholderImage options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            if (receivedSize == expectedSize)
            {
                
                //[indicator run:100.0f];
                [indicator removeFromSuperview];
            }
            else
            {
                float progress = (float)receivedSize/(float)expectedSize;
                if (indicator.currentProgress >receivedSize/expectedSize)
                {
                    [indicator pause];
                }
                else if (indicator.currentProgress <= progress)
                {
                    [indicator run:progress];
                }
            }
            
        } completed:completeBlock];
        
    }
    else
    {
        
        [self sd_setImageWithURL:[NSURL URLWithString:imageUrlString] placeholderImage:placeholderImage completed:completeBlock];
    }
}



@end
