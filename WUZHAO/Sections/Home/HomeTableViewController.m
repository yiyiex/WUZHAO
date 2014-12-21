//
//  HomeTableViewController.m
//  Dtest3
//
//  Created by yiyi on 14-10-22.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "HomeTableViewController.h"
#import "HomeTableCell.h"

#import "WhatsGoingOn.h"
@interface HomeTableViewController ()
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation HomeTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
    }
    NSLog(@"-----------device version---------------%f",[[UIDevice currentDevice].systemVersion floatValue]);

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    self.dataSource = [[WhatsGoingOn newDataSource] mutableCopy];
    [self.tableView reloadData ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    //NSLog(@"the number of the wors in the section:**********%lu",[self.dataSource count]);
    return [self.dataSource count];
    
}


- (HomeTableCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"HomeTableCell";
    HomeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    //NSLog(@"get the cell in queue");
    if (cell == nil)
    {
        cell = [[HomeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    }
    //UILabel *descriptionLabel = (UILabel *)[cell viewWithTag:101];
    //cell.descriptionLabel = descriptionLabel;
    //cell.descriptionLabel.text = [NSString stringWithFormat:@"Image #%ld",(long)indexPath.row];
    cell.whatsGoinOnItem = self.dataSource[indexPath.row];
    //cell.setAvatorImage;
   // cell.descriptionLabel.text = [NSString stringWithFormat:@"Image #%ld",(long)indexPath.row];



    // Configure the cell...
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
