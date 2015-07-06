//
//  PhotoFilterViewCollectionViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/5/30.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilteredImageView.h"


@interface PhotoFilterViewCollectionViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>



@property (nonatomic, weak) IBOutlet FilteredImageView *filteredImageView;
@property (nonatomic, strong) NSMutableArray *filteredImageViews;

@property (nonatomic, strong) NSMutableArray *imagesAndInfo;
@property (nonatomic, strong) NSMutableArray *filteredImages;

@property (nonatomic, copy) void(^filterBlock)(NSMutableArray *imagesAndInfo);


@end
