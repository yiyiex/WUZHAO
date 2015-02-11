//
//  FootPrintTableViewController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-21.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "FootPrintTableViewController.h"
#import "FootPrint.h"

@interface FootPrintTableViewController()


@end

@implementation FootPrintTableViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self loadData];
}

- (NSArray *)datasource
{
    if (!_datasource)
    {
        _datasource = [[NSArray alloc]init];
    }
    return _datasource;
}

-(void)loadData
{
    [self.tableView reloadData];
}

#pragma mark =======tableview delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.datasource count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"footprintCell" forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:[[self.datasource objectAtIndex:indexPath.row] topImageUrl]];
    cell.textLabel.text = [[self.datasource objectAtIndex:indexPath.row] addressInfo];
    
    return cell;
}

@end
