//
//  AddressMarkCollectionViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/7/22.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//
#import "macro.h"
#import "AddressMarkCollectionViewCell.h"

#define cellWidth (WZ_APP_SIZE.width - 72)/3
@implementation AddressMarkCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initViews];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initViews];
    }
    return self;
}
-(void)initViews
{
    CGRect rect =  CGRectMake(0, 0, cellWidth, cellWidth);
    self.placeHolderImageView = [[UIImageView alloc]initWithFrame:rect];
    CGRect rect2 =  CGRectMake(-2, -2, cellWidth+4, cellWidth+4);
    self.shotStackView = [[SWSnapshotStackView alloc]initWithFrame:rect2];
    [self addSubview:self.placeHolderImageView];
    [self addSubview:self.shotStackView];
}


@end
