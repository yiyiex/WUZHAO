//
//  BadgeLabel.m
//  WUZHAO
//
//  Created by yiyi on 15/7/25.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "BadgeLabel.h"
#import "macro.h"
#define kLabelWidth 20

@implementation BadgeLabel
-(instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initView];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, kLabelWidth, kLabelWidth)];
    if (self)
    {
        [self initView];
    }
    return self;
}


-(void)initView
{
    [self setBackgroundColor:THEME_COLOR_DARK];
    [self setTextColor:THEME_COLOR_WHITE];
    [self setFont:WZ_FONT_SMALL_SIZE];
    [self setTextAlignment:NSTextAlignmentCenter];
    [self.layer setCornerRadius:kLabelWidth/2];
    self.layer.masksToBounds = YES;
}

-(void)setNum:(NSInteger )num
{
        self.text = [NSString stringWithFormat:@"%ld",(long)num];
        [self setHidden:NO];
        [self sizeToFit];
        CGRect frame = self.frame;
        frame.size.width = MAX(frame.size.width, 20);
        frame.size.height = kLabelWidth;
        [self setFrame:frame];
}

-(void)setColor:(UIColor *)color
{
    [self setBackgroundColor:color];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
