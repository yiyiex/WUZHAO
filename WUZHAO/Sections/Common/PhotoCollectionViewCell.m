//
//  PhotoCollectionViewCell.m
//  WUZHAO
//
//  Created by yiyi on 14-12-17.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "PhotoCollectionViewCell.h"
#import "macro.h"

@implementation PhotoCollectionViewCell

-(void) hideImageCountLabel
{
    [self.imageCountLabel setHidden:YES];
}

-(void) showImageCountLabel:(NSInteger )count;
{
    [self.imageCountLabel setHidden:NO];
    [self.imageCountLabel setText:[NSString stringWithFormat:@"%ld",(long)count]];
}
-(void) setAppearance
{
    [self.imageCountLabel.layer setBackgroundColor:[THEME_COLOR_DARKER_GREY_BIT_PARENT CGColor]];
    self.imageCountLabel.layer.cornerRadius = 1.0f;
    [self.imageCountLabel setFont:WZ_FONT_SMALL_SIZE];
    [self.imageCountLabel setTextColor:THEME_COLOR_LIGHTER_GREY];
    [self.imageCountLabel setTextAlignment:NSTextAlignmentCenter];
    
}

@end
