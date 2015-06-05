//
//  PhotoFilterCollectionViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/5/30.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "PhotoFilterCollectionViewCell.h"
#import "macro.h"


@implementation PhotoFilterCollectionViewCell

static float cellWidth;
static float labelHeight;
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addSubviews];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self addSubviews];
    }
    return self;
}




-(FilteredImageView *)filteredImageView
{
    if (_filteredImageView == nil)
    {
        _filteredImageView = [[FilteredImageView alloc]initWithFrame:CGRectMake(0, 0,cellWidth, cellWidth)];
        _filteredImageView.layer.borderColor = self.tintColor.CGColor;
        _filteredImageView.layer.cornerRadius = 3.0f;
        [_filteredImageView.layer setMasksToBounds:YES];
    }
    return _filteredImageView;
}

-(UILabel *)filterNameLabel
{
    if (_filterNameLabel == nil)
    {
        _filterNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, cellWidth + 10, cellWidth, labelHeight)];
        _filterNameLabel.textAlignment = NSTextAlignmentCenter;
        _filterNameLabel.highlightedTextColor = [UIColor whiteColor];
        _filterNameLabel.textColor = [UIColor whiteColor];
        _filterNameLabel.font = [UIFont systemFontOfSize:12];
    }
    return _filterNameLabel;
}

-(void)addSubviews
{
    [self addSubview:self.filteredImageView];
    if (labelHeight >0)
    {
        [self addSubview:self.filterNameLabel];
    }
}

-(void)setSelected:(BOOL)selected
{
    self.filteredImageView.layer.borderWidth = selected? 2 : 0;
    self.filteredImageView.layer.borderColor = [THEME_COLOR_DARK CGColor];
}

+(void)setCellWidth:(float)width
{
    cellWidth = width;
}
+(void)setLabelheight :(float)height
{
    labelHeight = height;
}

@end
