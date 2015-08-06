//
//  BlankTableViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/8/5.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "BlankTableViewCell.h"
#import "macro.h"
#import "UILabel+ChangeAppearance.h"

@implementation BlankTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self initView];
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initView
{
    [self.blankMessageLabel setTextColor:THEME_COLOR_LIGHT_GREY];
    [self.blankMessageLabel setFont:WZ_FONT_LARGE_READONLY];
    [self.blankMessageLabel setTextAlignment:NSTextAlignmentCenter];
    
}

-(void)setBlankMessageText:(NSString *)text
{
    self.blankMessageLabel.text = text;
    
}

@end
