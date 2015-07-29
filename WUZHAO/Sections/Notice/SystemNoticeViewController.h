//
//  NoticeViewController.h
//  WUZHAO
//
//  Created by yiyi on 15-1-14.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SystemNoticeViewController : UITableViewController
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic) BOOL shouldRefreshData;

-(void)getLatestData;
-(void)loadData;
@end
