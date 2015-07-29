//
//  AddressListTableViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/7/21.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "macro.h"

#import "AddressPhotos.h"
#import "User.h"
#import "POI.h"

@protocol AddressListTableViewDataSource ;

@interface AddressListTableViewController : UITableViewController
@property (nonatomic, strong) User *currentUser;
@property (nonatomic,strong) NSArray *datasource;
@property (nonatomic, weak) id<AddressListTableViewDataSource> dataSource;
-(void)loadData;

@end

@protocol AddressListTableViewDataSource <NSObject>

@required
-(NSInteger)numberOfPhotos:(AddressListTableViewController *)tableView;
-(AddressPhotos *)AddressListTableView:(AddressListTableViewController *)tableView dataAtIndex:(NSInteger)index;
@end
