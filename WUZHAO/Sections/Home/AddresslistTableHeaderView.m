//
//  AddresslistTableHeaderView.m
//  WUZHAO
//
//  Created by yiyi on 15/8/31.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "AddresslistTableHeaderView.h"
#import "macro.h"

@implementation AddresslistTableHeaderView


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
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    self.headerLabel = [[UILabel alloc]init];
    [self.headerLabel setTextColor:THEME_COLOR_LIGHT_GREY];
    [self.headerLabel setFont:WZ_FONT_COMMON_BOLD_SIZE];
    [self.headerLabel setTextAlignment:NSTextAlignmentLeft];
    [self.headerLabel setBackgroundColor:[UIColor clearColor]];
    [self.headerLabel.layer setCornerRadius:8.0f];
    self.headerLabel.layer.masksToBounds = YES;
    
    
    [self addSubview:self.headerLabel];
    //[self addSubview:self.seperateLine];
    
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    [self.headerLabel sizeToFit];
    CGRect frame = self.headerLabel.frame;
    [self.headerLabel setFrame:CGRectMake(8, 9, frame.size.width+16, 28)];
}

@end
