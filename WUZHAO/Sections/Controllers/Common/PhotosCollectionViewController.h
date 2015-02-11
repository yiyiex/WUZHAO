//
//  PhotosCollectionViewController.h
//  WUZHAO
//
//  Created by yiyi on 15-1-5.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoCollectionViewCell.h"


@class WhatsGoingOn;

@interface PhotosCollectionViewController : UICollectionViewController

@property (nonatomic,strong) NSMutableArray *datasource;

-(void)loadData;

-(void)configureCell:(PhotoCollectionViewCell *)cell forContent:(WhatsGoingOn *)content atIndexPath:(NSIndexPath *)indexPath;
@end
