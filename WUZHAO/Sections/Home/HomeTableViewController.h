//
//  HomeTableViewController.h
//  WUZHAO
//
//  Created by yiyi on 14-12-15.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoTableViewCell.h"
#import "PagerViewController.h"

#import "BasicTableViewController.h"

@class WhatsGoingOn;
@class User;

typedef NS_ENUM(NSInteger, WZ_TABLEVIEWSTYLE) {
    WZ_TABLEVIEWSTYLE_HOME = 0,
    WZ_TABLEVIEWSTYLE_DETAIL = 1,
    WZ_TABLEVIEWSTYLE_LIST = 2,
    WZ_TABLEVIEWSTYLE_SUGGEST = 3
};

@protocol PhotoListViewsDataSource;

@interface HomeTableViewController :BasicTableViewController  <PagerViewControllerItem>
@property (nonatomic ,strong) User *currentUser;

@property (nonatomic ,strong) NSMutableArray *recommandDatasource;

@property (nonatomic) NSInteger tableStyle;

@property (nonatomic,strong) NSIndexPath *listStyleStartIndex;
@property (nonatomic) id<PhotoListViewsDataSource> listViewDataSource;



- (void)configureCell:(PhotoTableViewCell *)cell forContent:(WhatsGoingOn *)content atIndexPath:(NSIndexPath *)indexPath;

@end

@protocol PhotoListViewsDataSource <NSObject>
@required
-(NSInteger)numberOfPhotos:(HomeTableViewController *)listView;

@optional
-(WhatsGoingOn *)ListView:(HomeTableViewController *)listView dataAtIndex:(NSInteger)index;

-(NSArray *)photoDetailViewsController:(HomeTableViewController *)detailViews loadMoreData:(NSInteger)page;

@end
