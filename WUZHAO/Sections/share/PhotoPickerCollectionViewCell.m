//
//  PhotoPickerCollectionViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/7/1.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//
#import "PhotoPickerCollectionViewCell.h"
#import "macro.h"
#import "UIImageView+ChangeAppearance.h"
#import "PhotoCommon.h"


@implementation PhotoPickerCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.imageView.layer.borderColor = THEME_COLOR_DARK.CGColor;
        [self.contentView addSubview:self.imageView];
        
        self.selectedIcon = [[UIImageView alloc]initWithFrame:CGRectMake(self.bounds.size.width - 25, 5, 20, 20)];
        CALayer *layer = self.selectedIcon.layer;
        [layer setMasksToBounds:YES];
        [layer setBorderWidth:1.0f];
        layer.borderColor = [THEME_COLOR_WHITE CGColor];
        layer.cornerRadius = self.selectedIcon.frame.size.width/2;
        layer.backgroundColor = [THEME_COLOR_DARK_GREY_PARENT CGColor];
        [self.contentView addSubview:self.selectedIcon];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.imageView.layer.borderWidth = selected ? 2 : 0;
    //self.selectedIcon.layer.borderWidth = selected ? 0 : 1;
    
    self.selectedIcon.layer.backgroundColor = selected?[THEME_COLOR_DARK CGColor]:[THEME_COLOR_DARK_GREY_PARENT CGColor];
    self.selectedIcon.image = selected? [UIImage imageNamed:@"check_small"]:nil;
    
}
@end
