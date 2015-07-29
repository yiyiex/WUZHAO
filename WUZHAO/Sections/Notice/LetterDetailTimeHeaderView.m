//
//  LetterDetailTimeHeaderView.m
//  WUZHAO
//
//  Created by yiyi on 15/7/26.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "LetterDetailTimeHeaderView.h"
#import "macro.h"

@implementation LetterDetailTimeHeaderView

 -(id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithReuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self initView];
    }
    return self;
}

-(void)initView
{
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    self.timeLabel = [[UILabel alloc]init];
    [self.timeLabel setTextColor:THEME_COLOR_LIGHT_GREY];
    [self.timeLabel setFont:WZ_FONT_SMALL_SIZE];
    [self.timeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.timeLabel setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    [self.timeLabel.layer setCornerRadius:8.0f];
    self.timeLabel.layer.masksToBounds = YES;
    [self addSubview:self.timeLabel];
}

-(void)setTime:(NSString *)time
{
    self.timeLabel.text = time;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self.timeLabel sizeToFit];
    CGRect frame = self.timeLabel.frame;
    [self.timeLabel setFrame:CGRectMake((WZ_APP_SIZE.width - frame.size.width+16)/2, 0, frame.size.width+16, 20)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
