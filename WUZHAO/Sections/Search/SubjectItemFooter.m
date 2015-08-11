//
//  SubjectItemFooter.m
//  WUZHAO
//
//  Created by yiyi on 15/8/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "SubjectItemFooter.h"
#import "macro.h"

@implementation SubjectItemFooter

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
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
    self.summaryLabel = [[UILabel alloc]init];
    [self.summaryLabel setTextColor:THEME_COLOR_DARK_GREY];
    [self.summaryLabel setFont:WZ_FONT_COMMON_SIZE];
    [self addSubview:self.summaryLabel];
    
}
-(void)configureFooterWithSubject:(Subject *)subject
{
    self.summaryLabel.text = subject.summary;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGSize newSize = [self.summaryLabel sizeThatFits:CGSizeMake(WZ_APP_SIZE.width -16, FLT_MAX)];
    [self.summaryLabel setFrame:CGRectMake(8, 8, newSize.width, newSize.height)];
}


@end
