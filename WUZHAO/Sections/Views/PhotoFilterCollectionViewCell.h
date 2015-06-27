//
//  PhotoFilterCollectionViewCell.h
//  WUZHAO
//
//  Created by yiyi on 15/5/30.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilteredImageView.h"
#import "macro.h"




@interface PhotoFilterCollectionViewCell : UICollectionViewCell


@property (nonatomic, strong) UILabel *filterNameLabel;
@property (nonatomic, strong) FilteredImageView *filteredImageView;


+(void)setCellWidth:(float)width;
+(void)setLabelheight :(float)labelHeight;
@end
