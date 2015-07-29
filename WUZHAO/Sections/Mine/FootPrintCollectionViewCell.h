//
//  FootPrintCollectionViewCell.h
//  WUZHAO
//
//  Created by yiyi on 15/7/21.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWSnapshotStackView.h"
#import "macro.h"

@interface FootPrintCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *placeHolderImageView;
@property (nonatomic, strong) SWSnapshotStackView *shotStackView;
@property (nonatomic, strong) UILabel *addressNameLabel;
@property (nonatomic, strong) UILabel *photoNumLabel;

-(void)setPhotoNumber:(NSInteger )num;

@end
