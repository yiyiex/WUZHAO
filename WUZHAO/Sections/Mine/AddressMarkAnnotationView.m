//
//  AddressMarkAnnotationView.m
//  WUZHAO
//
//  Created by yiyi on 15/7/7.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#define kWidth 46
#define kHeight 46
#define kHoriMargin 3
#define kVertMargin 3
#define kPortraitWidth 40
#define kPortraitHeight 40
#define kLabelWidth 20
#define kLabelHeight 20

#import "UIImageView+WebCache.h"

#import "macro.h"

#import "AddressMarkAnnotationView.h"

@implementation AddressMarkAnnotationView


-(void)setImageWithImageUrl:(NSString*)url
{
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:url]];
}
-(void)setPhotoNumber:(NSInteger )num
{
    if (num >1)
    {
        self.imageNumLabel.text = [NSString stringWithFormat:@"%ld",(long)num];
        [self.imageNumLabel setHidden:NO];
        [self.imageNumLabel sizeToFit];
        CGRect frame = self.imageNumLabel.frame;
        frame.size.width = MAX(frame.size.width, kLabelWidth);
        frame.size.height = kLabelHeight;
        [self.imageNumLabel setFrame:frame];
    }
    else
    {
        [self.imageNumLabel setHidden:YES];
    }
    
   // [self.imageNumLabel sizeToFit];
}
-(void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}
-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selected == selected)
    {
        return;
    }
    if (selected)
    {
        
    }
    else
    {
        
    }
}

#pragma mark - Life Cycle

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.bounds = CGRectMake(0.f, 0.f, kWidth, kHeight);
        
        self.backgroundColor = [UIColor whiteColor];
       // [self.layer setBorderWidth:0.5f];
       // [self.layer setBorderColor:[THEME_COLOR_LIGHT_GREY CGColor]];
        [self.layer setShadowColor:[THEME_COLOR_DARK_GREY CGColor]];
        [self.layer setShadowOpacity:0.5];
        [self.layer setShadowOffset:CGSizeMake(0, 2.0f)];
        
        /* Create portrait image view and add to view hierarchy. */
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kHoriMargin, kVertMargin, kPortraitWidth, kPortraitHeight)];
        [self addSubview:self.imageView];
        
        self.imageNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(kWidth - kLabelHeight/2 - kHoriMargin/2 , -kLabelHeight/2+kHoriMargin/2, kLabelWidth, kLabelHeight)];
        [self.imageNumLabel setBackgroundColor:THEME_COLOR_DARK];
        [self.imageNumLabel setTextColor:THEME_COLOR_WHITE];
        [self.imageNumLabel setFont:WZ_FONT_SMALL_SIZE];
        [self.imageNumLabel setTextAlignment:NSTextAlignmentCenter];
        [self.imageNumLabel.layer setCornerRadius:kLabelHeight/2];
        self.imageNumLabel.layer.masksToBounds = YES;
        [self addSubview:self.imageNumLabel];
        
    }
    return self;
}
@end
