//
//  UserListTableViewController.h
//  WUZHAO
//
//  Created by yiyi on 15-1-5.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PagerViewController.h"
#import "BasicTableViewController.h"
@protocol UserListViewControllerDataSource;

@interface UserListTableViewController : BasicTableViewController <PagerViewControllerItem>
@property (nonatomic,strong) NSString *userListStyle;
@property (nonatomic, weak ) id<UserListViewControllerDataSource>dataSource;

-(void)loadData;
@end

@protocol UserListViewControllerDataSource <NSObject>

@required

-(void)updateUserListDatasource:(UserListTableViewController *)userList;

@optional
@end
