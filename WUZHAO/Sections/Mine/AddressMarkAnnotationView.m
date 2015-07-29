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
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [self.snapshotStackView setImage:image];
       // [self.imageView setHidden:YES];
       // [self.snapshotStackView setHidden:NO];
    }];
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
        self.snapshotStackView.displayAsStack = YES;
        
    }
    else
    {
        [self.imageNumLabel setHidden:YES];
        self.snapshotStackView.displayAsStack = NO;
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

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.bounds = CGRectMake(0.f, 0.f, kWidth, kHeight);
        self.backgroundColor = [UIColor clearColor];
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kHoriMargin, kVertMargin, kPortraitWidth, kPortraitHeight)];
        self.snapshotStackView = [[SWSnapshotStackView alloc]initWithFrame:CGRectMake(0, 0, kWidth+20, kHeight+20)];
        [self addSubview:self.snapshotStackView];
        
        self.imageNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(kWidth , 0, kLabelWidth, kLabelHeight)];
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
