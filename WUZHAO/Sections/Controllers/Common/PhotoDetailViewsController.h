//
//  ViewContainerController.h
//  WUZHAO
//
//  Created by yiyi on 15/5/21.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "HomeTableViewController.h"

@protocol PhotoDetailViewsControllerDataSource;

@interface PhotoDetailViewsController : UIViewController

@property (nonatomic,weak) id<PhotoDetailViewsControllerDataSource> dataSource;
@property (nonatomic) NSInteger currentPhotoIndex;

-(instancetype)initWithDataSource:(id<PhotoDetailViewsControllerDataSource> )dataSource;

@end


@protocol PhotoDetailViewsControllerDataSource <NSObject>

-(NSInteger)numberOfViewsInPhotoDetailViewsController:(PhotoDetailViewsController *)detailViews;

-(WhatsGoingOn *)photoDetailViewsController:(PhotoDetailViewsController *)detailViews dataAtIndex:(NSInteger)index;

@end