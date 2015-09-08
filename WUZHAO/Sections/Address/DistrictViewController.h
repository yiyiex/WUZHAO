//
//  DistrictViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/7/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicViewController.h"
#import "UIScrollView+BlurCover.h"
#import "District.h"

@interface DistrictViewController : BasicViewController<UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) District *data;

@property (nonatomic, strong) UICollectionView *collectionView;

@end
