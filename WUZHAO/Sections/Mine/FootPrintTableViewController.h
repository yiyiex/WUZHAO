//
//  FootPrintTableViewController.h
//  WUZHAO
//
//  Created by yiyi on 14-12-21.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressPhotos.h"
#import "User.h"
@protocol FootPrintViewControllerDataSource ;
@interface FootPrintTableViewController : UITableViewController
@property (nonatomic, strong) User *currentUser;
@property (nonatomic,strong) NSArray *datasource;
@property (nonatomic, weak) id<FootPrintViewControllerDataSource> dataSource;
-(void)loadData;

@end

@protocol FootPrintViewControllerDataSource <NSObject>

@required
-(NSInteger)numberOfPhotos:(FootPrintTableViewController *)tableView;
-(AddressPhotos *)FootPrintTableView:(FootPrintTableViewController *)tableView dataAtIndex:(NSInteger)index;
@optional
-(NSArray *)FootPrintTableView:(FootPrintTableViewController *)tableView moreData:(NSInteger)page;
@end