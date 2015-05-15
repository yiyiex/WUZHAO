//
//  HomeTableViewController.h
//  WUZHAO
//
//  Created by yiyi on 14-12-15.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoTableViewCell.h"

@class WhatsGoingOn;
@class User;

typedef NS_ENUM(NSInteger, WZ_TABLEVIEWSTYLE) {
    WZ_TABLEVIEWSTYLEHOME = 0,
    WZ_TABLEVIEWSTYLEDETAIL
};

@interface HomeTableViewController : UITableViewController
@property (nonatomic ,strong) User *currentUser;
@property (nonatomic ,strong) NSMutableArray *dataSource;
@property (nonatomic) NSInteger tableStyle;
- (void)configureCell:(PhotoTableViewCell *)cell forContent:(WhatsGoingOn *)content atIndexPath:(NSIndexPath *)indexPath;

- (void)GetLatestDataList;
@end
