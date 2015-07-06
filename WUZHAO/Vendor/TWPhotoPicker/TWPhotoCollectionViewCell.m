//
//  TWPhotoCollectionViewCell.m
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import "TWPhotoCollectionViewCell.h"
#import "macro.h"
#import "UIImageView+ChangeAppearance.h"
#import "PhotoCommon.h"


@implementation TWPhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //self.imageView.layer.borderColor = [UIColor blueColor].CGColor;
        self.imageView.layer.borderColor = THEME_COLOR_DARK.CGColor;
        [self.contentView addSubview:self.imageView];
        
        self.selectedIcon = [[UIImageView alloc]initWithFrame:CGRectMake(self.bounds.size.width - 25, 5, 20, 20)];
        CALayer *layer = self.selectedIcon.layer;
        [layer setMasksToBounds:YES];
        [layer setBorderWidth:1.5f];
        layer.borderColor = [THEME_COLOR_WHITE CGColor];
        layer.cornerRadius = self.selectedIcon.frame.size.width/2;
        [self.selectedIcon setBackgroundColor:rgba_WZ(255, 255, 255, 0)];
        //[self.imageView addSubview:self.selectedIcon];
        [self.contentView addSubview:self.selectedIcon];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.imageView.layer.borderWidth = selected ? 2 : 0;
    self.selectedIcon.layer.borderWidth = selected ? 2 : 2;
    self.selectedIcon.layer.backgroundColor = selected?[THEME_COLOR_DARK CGColor]:[THEME_COLOR_DARK_GREY_PARENT CGColor];
    
}

@end
