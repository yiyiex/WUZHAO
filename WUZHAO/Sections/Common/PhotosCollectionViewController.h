//
//  PhotosCollectionViewController.h
//  WUZHAO
//
//  Created by yiyi on 15-1-5.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoCollectionViewCell.h"
#import "BasicCollectionViewController.h"

typedef NS_ENUM(NSUInteger, DETAIL_STYLE)
{
    DETAIL_STYLE_SINGLEPAGE = 0,
    DETAIL_STYLE_LIST = 1
};

@class WhatsGoingOn;

@protocol PhotoCollectionViewControllerDataSource;

@interface PhotosCollectionViewController : BasicCollectionViewController

@property (nonatomic, weak) id<PhotoCollectionViewControllerDataSource>dataSource;

@property (nonatomic,strong) NSMutableArray *datasource;
@property (nonatomic) DETAIL_STYLE detailStyle;

-(void)loadData;

-(void)configureCell:(PhotoCollectionViewCell *)cell forContent:(WhatsGoingOn *)content atIndexPath:(NSIndexPath *)indexPath;
@end

@protocol PhotoCollectionViewControllerDataSource <NSObject>

@required
-(void)updatePhotoCollectionDatasource:(PhotosCollectionViewController *)collectionView;
-(NSInteger)numberOfPhotos:(PhotosCollectionViewController *)collectionViews;
-(WhatsGoingOn *)PhotosCollectionViewController:(PhotosCollectionViewController *)collectionView dataAtIndex:(NSInteger)index;
@optional
-(NSArray *)PhotosCollectionViewController:(PhotosCollectionViewController *)collectionView moreData:(NSInteger)page;
@end