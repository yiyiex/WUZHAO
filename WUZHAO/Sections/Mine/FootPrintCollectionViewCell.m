//
//  FootPrintCollectionViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/7/21.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "UILabel+ChangeAppearance.h"
#import "FootPrintCollectionViewCell.h"

#define cellWidth (WZ_APP_SIZE.width -24)/2
#define cellHeight (cellWidth + 24)
#define numLabelHeight 20

@implementation FootPrintCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initViews];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initViews];
    }
    return self;
}


-(void)initViews
{
    CGRect rect =  CGRectMake(0, 0, cellWidth, cellWidth);
    self.placeHolderImageView = [[UIImageView alloc]initWithFrame:rect];
    self.shotStackView = [[SWSnapshotStackView alloc]initWithFrame:rect];
    [self addSubview:self.placeHolderImageView];
    [self addSubview:self.shotStackView];

    CGRect locationIconRect = CGRectMake(4, cellHeight - 17, 10, 10);
    UIImageView *locationIcon = [[UIImageView alloc]initWithFrame:locationIconRect];
    [locationIcon setImage:[UIImage imageNamed:@"map-maker-22"]];
    [self addSubview:locationIcon];
    
    CGRect nameLabelRect = CGRectMake(18, cellHeight - 24, cellWidth-20, 24);
    self.addressNameLabel = [[UILabel alloc]initWithFrame:nameLabelRect];
    [self addSubview:self.addressNameLabel];
    [self.addressNameLabel setFont:WZ_FONT_COMMON_SIZE];
    [self.addressNameLabel setTextAlignment:NSTextAlignmentLeft];
    [self.addressNameLabel setThemeLabelAppearance];
    
    CGRect numLabelRect = CGRectMake(cellWidth-numLabelHeight,0, numLabelHeight, numLabelHeight);
    self.photoNumLabel = [[UILabel alloc]initWithFrame:numLabelRect];
    [self.photoNumLabel setBackgroundColor:THEME_COLOR_DARK];
    [self.photoNumLabel setTextColor:THEME_COLOR_WHITE];
    [self.photoNumLabel setFont:WZ_FONT_SMALL_SIZE];
    [self.photoNumLabel setTextAlignment:NSTextAlignmentCenter];
    [self.photoNumLabel.layer setCornerRadius:numLabelHeight/2];
    self.photoNumLabel.layer.masksToBounds = YES;
    [self.shotStackView addSubview:self.photoNumLabel];
}
-(void)setPhotoNumber:(NSInteger )num
{
    if (num ==1)
    {
        self.shotStackView.displayAsStack = NO;
    }
    else
    {
        self.shotStackView.displayAsStack = YES;
    }
    if (num >1)
    {
        self.photoNumLabel.text = [NSString stringWithFormat:@"%ld",(long)num];
        [self.photoNumLabel setHidden:NO];
        [self.photoNumLabel sizeToFit];
        CGRect frame = self.photoNumLabel.frame;
        frame.size.width = MAX(frame.size.width, numLabelHeight);
        frame.size.height = numLabelHeight;
        [self.photoNumLabel setFrame:frame];
    }
    else
    {
        [self.photoNumLabel setHidden:YES];
    }
}
@end
