//
//  subjectItemHeaderOrFooter.m
//  WUZHAO
//
//  Created by yiyi on 15/8/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "subjectItemHeader.h"
#import "macro.h"
#import "PhotoCommon.h"

@implementation subjectItemHeader

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
-(NSDictionary *)subjectDescriptionAttributes
{
    if (!_subjectDescriptionAttributes)
    {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineSpacing = 6;
        _subjectDescriptionAttributes = @{NSForegroundColorAttributeName:THEME_COLOR_FONT_GREY,NSFontAttributeName:WZ_FONT_COMMON_SIZE,NSParagraphStyleAttributeName:paragraphStyle};
    }
    return _subjectDescriptionAttributes;
}

-(void)initView
{
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    self.title = [[UILabel alloc]init];
    [self.title setTextColor:THEME_COLOR_DARK_GREY];
    [self.title setFont:WZ_FONT_HIRAGINO_MID_SIZE];
    [self.title setTextAlignment:NSTextAlignmentCenter];
    [self.contentView  addSubview:self.title];
    
    self.subtitle = [[UILabel alloc]init];
    [self.subtitle setTextColor:THEME_COLOR_DARK_GREY];
    [self.subtitle setFont:WZ_FONT_HIRAGINO_SMALL_SIZE];
    [self.subtitle setTextAlignment:NSTextAlignmentCenter];
    [self.contentView  addSubview:self.subtitle];
    
    self.subjectDescription = [[UITextView alloc]init];
    [self.subjectDescription setScrollEnabled:NO];
    [self.subjectDescription setEditable:NO];

    [self.contentView addSubview:self.subjectDescription];
    
}
-(void)configureHeaderWithSubject:(Subject *)subject
{
    self.title.text = subject.title;
    self.subtitle.text = subject.subTitle;
    if ([subject.subTitle isEqualToString:@""])
    {
        [self.subtitle setHidden:YES];
    }
    else
    {
        [self.subtitle  setHidden:NO];
    }
    NSAttributedString *subjectDescriptionText = [[NSAttributedString alloc]initWithString:subject.subjectDescription attributes:self.subjectDescriptionAttributes];
    [self.subjectDescription setAttributedText:subjectDescriptionText];
    if ([subject.subjectDescription isEqualToString:@""])
    {
        [self.subjectDescription setHidden:YES];
    }
    else
    {
        [self.subjectDescription setHidden:NO];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize titleSize = [self.title sizeThatFits:CGSizeMake(WZ_APP_SIZE.width - 16, FLT_MAX)];
    [self.title setFrame:CGRectMake(8, 8, WZ_APP_SIZE.width -16, titleSize.height+12)];
    if (!self.subtitle.isHidden)
    {
        CGSize subtitleSize = [self.subtitle sizeThatFits:CGSizeMake(WZ_APP_SIZE.width - 16, FLT_MAX)];
        [self.subtitle setFrame:CGRectMake(8, 8+self.title.frame.size.height, WZ_APP_SIZE.width -16, subtitleSize.height+12)];
    }
    if (!self.subjectDescription.isHidden)
    {
        CGSize subjectDescriptionSize = [self.subjectDescription sizeThatFits:CGSizeMake(WZ_APP_SIZE.width - 8, FLT_MAX)];
        [self.subjectDescription setFrame:CGRectMake(4, 8+self.title.frame.size.height +self.subtitle.frame.size.height , subjectDescriptionSize.width, subjectDescriptionSize.height+12)];
    }
    [PhotoCommon drawALineWithFrame:CGRectMake(0, self.title.frame.size.height +self.subtitle.frame.size.height + self.subjectDescription.frame.size.height+8, WZ_APP_SIZE.width , 0.5) andColor:THEME_COLOR_FONT_GREY inLayer:self.contentView.layer];
}

@end
