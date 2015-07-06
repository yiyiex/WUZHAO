//
//  ImageCropScrollView.h
//  WUZHAO
//
//  Created by yiyi on 15/7/1.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface ImageCropScrollView : UIScrollView

@property (nonatomic, strong) UIImage *unfilteredImage;

- (void)displayImage:(UIImage *)image;

- (UIImage *)capture;

-(void)setImageViewInCenter;

-(void)adaptImageView;


@end