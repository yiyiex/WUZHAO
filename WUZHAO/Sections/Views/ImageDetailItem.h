//
//  ImageDetailItem.h
//  WUZHAO
//
//  Created by yiyi on 15/8/28.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//
#define Margin 8.0f

#import <UIKit/UIKit.h>

@interface ImageDetailItem : UIView

@property (nonatomic) NSInteger pageIndex;

@property (nonatomic, strong) UIScrollView *zoomView;
@property (nonatomic, strong) UIImageView *imageView;

@end
