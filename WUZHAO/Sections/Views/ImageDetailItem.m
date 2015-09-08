//
//  ImageDetailItem.m
//  WUZHAO
//
//  Created by yiyi on 15/8/28.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//
#import "macro.h"
#import "ImageDetailItem.h"

@implementation ImageDetailItem

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

-(void)commonInit
{
    self.zoomView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width , self.frame.size.height)];
    _zoomView.maximumZoomScale = 3.0f;
    _zoomView.minimumZoomScale = 1.0f;
    _zoomView.showsHorizontalScrollIndicator = NO;
    _zoomView.showsVerticalScrollIndicator = NO;
    _zoomView.contentSize = CGSizeMake(WZ_DEVICE_SIZE.width, WZ_DEVICE_SIZE.width);
    [self addSubview:_zoomView];
    
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [_zoomView addSubview:_imageView];
    
}

@end
