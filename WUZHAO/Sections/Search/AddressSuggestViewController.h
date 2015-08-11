//
//  AddressSuggestViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/7/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuggestAddress.h"
#import "PagerViewController.h"
#import "BasicViewController.h"

@protocol AddressSuggestViewControllerDataSource;
@interface AddressSuggestViewController :BasicViewController  <PagerViewControllerItem>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datasource;
@property (nonatomic, weak) id<AddressSuggestViewControllerDataSource> dataSource;

-(void)loadData;

@end

@protocol AddressSuggestViewControllerDataSource <NSObject>

@required

-(void)updateAddressDatasource:(AddressSuggestViewController *)addressList;

@optional
@end
