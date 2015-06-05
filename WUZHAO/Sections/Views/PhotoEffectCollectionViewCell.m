//
//  PhotoEffectCollectionViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/6/2.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "PhotoEffectCollectionViewCell.h"
#import "PhotoFilterCollectionViewCell.h"
#import "macro.h"

@implementation PhotoEffectCollectionViewCell

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

-(UIImageView *)effectIconImageView
{
    if (!_effectIconImageView)
    {
        _effectIconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,cellWidth, cellWidth)];
        _effectIconImageView.image = [UIImage imageNamed:@"constract"];
        _effectIconImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        _effectIconImageView.layer.cornerRadius = 3.0f;
        [_effectIconImageView.layer setMasksToBounds:YES];
    }
    
    return _effectIconImageView;
}

-(UILabel *)effectNameLabel
{
    if(!_effectNameLabel)
    {
        _effectNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, cellWidth+10, cellWidth, labelHeight)];
        [_effectNameLabel setBackgroundColor:[UIColor clearColor]];
        [_effectNameLabel setTextColor:[UIColor whiteColor]];
        [_effectNameLabel setTextAlignment:NSTextAlignmentCenter];
        [_effectNameLabel setFont:[UIFont systemFontOfSize:12]];
        
  
    }
    return _effectNameLabel;
}

-(void)addSubviews
{
    [self addSubview:self.effectIconImageView];
    if (labelHeight >0)
    {
        [self addSubview:self.effectNameLabel];
    }
    
}

+(void)setCellWidth:(float)width
{
    cellWidth = width;
}
+(void)setLabelheight :(float)height
{
    labelHeight = height;
}
/*
-(void)setSelected:(BOOL)selected
{
    _effectIconImageView.layer.borderWidth = selected?2:0;
    _effectIconImageView.layer.borderColor = [THEME_COLOR_DARK CGColor] ;
}*/
@end
