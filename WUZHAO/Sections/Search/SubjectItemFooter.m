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
-(NSDictionary *)summaryTextAttributes
{
    if (!_summaryTextAttributes)
    {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineSpacing = 6;
        _summaryTextAttributes = @{NSForegroundColorAttributeName:THEME_COLOR_FONT_GREY,NSFontAttributeName:WZ_FONT_COMMON_SIZE,NSParagraphStyleAttributeName:paragraphStyle};
    }
    return _summaryTextAttributes;
}

-(void)initView
{
   [self.contentView setBackgroundColor:[UIColor whiteColor]];
    self.summaryLabel = [[UITextView alloc]init];
    [self.summaryLabel setScrollEnabled:NO];
    [self.summaryLabel setEditable:NO];
    [self addSubview:self.summaryLabel];
    
}
-(void)configureFooterWithSubject:(Subject *)subject
{
    NSAttributedString *summaryText = [[NSAttributedString alloc]initWithString:subject.summary attributes:self.summaryTextAttributes];
    [self.summaryLabel setAttributedText:summaryText];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGSize newSize = [self.summaryLabel sizeThatFits:CGSizeMake(WZ_APP_SIZE.width -8, FLT_MAX)];
    [self.summaryLabel setFrame:CGRectMake(4, 8, newSize.width, newSize.height)];
}


@end
