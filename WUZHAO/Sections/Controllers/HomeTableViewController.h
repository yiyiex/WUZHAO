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

@class CBStoreHouseRefreshControl;

@interface HomeTableViewController : UITableViewController

@property (nonatomic,strong) CBStoreHouseRefreshControl *QIUDAOYURefreshControl;


- (void) configureCell:(PhotoTableViewCell *)cell forContent:(WhatsGoingOn *)content atIndexPath:(NSIndexPath *)indexPath;
@end
