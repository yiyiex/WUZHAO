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
@property (nonatomic,strong) NSArray *footprintData;

@end

@implementation FootPrintTableViewController


-(NSArray *)footprintData
{
    if (!_footprintData)
    {
        _footprintData = [[FootPrint newData]mutableCopy];
        
    }
    return _footprintData;
}



#pragma mark =======tableview delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.footprintData count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"footprintCell" forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:[[self.footprintData objectAtIndex:indexPath.row] topImageUrl]];
    cell.textLabel.text = [[self.footprintData objectAtIndex:indexPath.row] addressInfo];
    
    return cell;
}

@end
