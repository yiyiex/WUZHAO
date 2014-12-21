//
//  MinePhotoCollectionViewCell.m
//  Dtest3
//
//  Created by yiyi on 14-11-6.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "MinePhotoCollectionViewCell.h"

@implementation MinePhotoCollectionViewCell
@synthesize cellImageView;
@synthesize cellWhatsGoingOnItem;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    return self;
}
- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSubviews];
    //[self.cellImageView setFrame:CGRectMake(0,0,100,100)];
    //self.cellImageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addSubview:self.cellImageView];
    }
    return self;
}
@end
