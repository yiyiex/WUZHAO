//
//  PlaceNoticeTableViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/8/4.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "PlaceNoticeTableViewController.h"
#import "PlaceRecommendTableViewCell.h"

@interface PlaceNoticeTableViewController ()

@end

@implementation PlaceNoticeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupRefreshControl];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getLatestData
{
    //TO DO
    //getlatest data
    [self loadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.datasource.count;
}

//TO DO
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlaceRecommendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"placeRecommend" forIndexPath:indexPath];
    [cell configureWithFeeds:self.datasource[indexPath.row]];
    //TO DO
    //add gesture
    return cell;
}

#pragma mark - pagerViewController Item delegate
-(NSString *)titleForPagerViewController:(PagerViewController *)pagerViewController
{
    return @"系统";
}

@end
