//
//  HomeSmallImagesCollectionViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/7/16.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#define kSmallImageCellWidth 70
#import "macro.h"
#import "HomeSmallImagesCollectionViewCell.h"

@implementation HomeSmallImagesCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addSubview:self.imageView];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self addSubview:self.imageView];
    }
    return self;
}
-(UIImageView *)imageView
{
    if (_imageView == nil)
    {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,kSmallImageCellWidth, kSmallImageCellWidth)];
        _imageView.layer.borderColor = self.tintColor.CGColor;
        [_imageView.layer setMasksToBounds:YES];
    }
    return _imageView;
}


-(void)setSelected:(BOOL)selected
{
    self.imageView.layer.borderWidth = selected? 2 : 0;
    self.imageView.layer.borderColor = [THEME_COLOR_DARK CGColor];
}
@end
