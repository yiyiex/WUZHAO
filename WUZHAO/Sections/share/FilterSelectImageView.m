//
//  FilterSelectImageView.m
//  WUZHAO
//
//  Created by yiyi on 15/7/1.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "FilterSelectImageView.h"
#import "macro.h"

@implementation FilterSelectImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self.layer setMasksToBounds:YES];
        self.layer.borderWidth = 0.0f;
        self.layer.borderColor = [THEME_COLOR_DARK CGColor];
        [self.layer setCornerRadius:2.0f];
    }
    return self;
}

-(void)setSelected:(BOOL)selected
{
    _selected = selected;
    CALayer *layer = self.layer;
    layer.borderWidth = _selected? 1.5f:0.0f;
    
}

@end
