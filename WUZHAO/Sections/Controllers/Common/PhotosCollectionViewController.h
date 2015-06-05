//
//  PhotosCollectionViewController.h
//  WUZHAO
//
//  Created by yiyi on 15-1-5.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoCollectionViewCell.h"

typedef NS_ENUM(NSUInteger, DETAIL_STYLE)
{
    DETAIL_STYLE_SINGLEPAGE = 0,
    DETAIL_STYLE_SCROLLVIEW = 1
};

@class WhatsGoingOn;

@protocol PhotoCollectionViewControllerDataSource;

@interface PhotosCollectionViewController : UICollectionViewController

@property (nonatomic, weak) id<PhotoCollectionViewControllerDataSource>dataSource;

@property (nonatomic,strong) NSMutableArray *datasource;
@property (nonatomic) DETAIL_STYLE detailStyle;

-(void)loadData;

-(void)configureCell:(PhotoCollectionViewCell *)cell forContent:(WhatsGoingOn *)content atIndexPath:(NSIndexPath *)indexPath;
@end

@protocol PhotoCollectionViewControllerDataSource <NSObject>

-(NSInteger)numberOfPhotos:(PhotosCollectionViewController *)collectionViews;

-(WhatsGoingOn *)PhotosCollectionViewController:(PhotosCollectionViewController *)detailViews dataAtIndex:(NSInteger)index;

@end