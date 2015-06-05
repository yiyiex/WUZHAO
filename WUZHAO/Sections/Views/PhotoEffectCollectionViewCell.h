//
//  PhotoEffectCollectionViewCell.h
//  WUZHAO
//
//  Created by yiyi on 15/6/2.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoEffectCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong) UILabel *effectNameLabel;
@property(nonatomic, strong) UIImageView *effectIconImageView;


+(void)setCellWidth:(float)width;
+(void)setLabelheight :(float)labelHeight;

@end
