//  展示一个用户的列表
//  UserListTableViewController.m
//  WUZHAO
//
//  Created by yiyi on 15-1-5.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "macro.h"
#import "UserListTableViewController.h"

#import "UserListTableViewCell.h"

#import "QDYHTTPClient.h"


#import "UIImageView+WebCache.h"
#import "UIImageView+ChangeAppearance.h"

#import "MineViewController.h"

#import "SVProgressHUD.h"


#import "User.h"

#define REUSEIDENTIFIER @"userListCell"
#define CELL_HEADERHEIGHT 44.0

@interface UserListTableViewController ()


@end

@implementation UserListTableViewController
@synthesize userListStyle = _userListStyle;

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.userListStyle = UserListStyle3;
    self.tableView.estimatedRowHeight = 150.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self configCellWithStyle];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - basic method

-(void)configCellWithStyle
{
    if ([self.userListStyle isEqualToString:UserListStyle1])
    {
        self.tableView.rowHeight = CELL_HEADERHEIGHT + 2.0;
    }
    else if ([self.userListStyle isEqualToString:UserListStyle2])
    {
        self.tableView.rowHeight = CELL_HEADERHEIGHT + 2.0;
        
    }
    else if ([self.userListStyle isEqualToString:UserListStyle3])
    {
        self.tableView.rowHeight = CELL_HEADERHEIGHT + 10.0 + WZ_DEVICE_SIZE.width/3 ;
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserListTableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:self.userListStyle forIndexPath:indexPath];
    if (!cell)
    {
        cell = [[UserListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.userListStyle];
    }

    [cell configWithUser:self.datasource[indexPath.row] style:self.userListStyle];
    UITapGestureRecognizer *avatarClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarClick:)];
    [cell.avatorImageView addGestureRecognizer:avatarClick];
    [cell.avatorImageView setUserInteractionEnabled:YES];
    // Configure the cell...
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *personalStoryboard= [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
    MineViewController *personalViewCon = [personalStoryboard instantiateViewControllerWithIdentifier:@"personalPage"];
    [personalViewCon setUserInfo:[self.datasource objectAtIndex:indexPath.row]];
    [personalViewCon.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:personalViewCon animated:YES];
    
}


#pragma mark - gesture and action
-(void)avatarClick:(UITapGestureRecognizer *)gesture
{
    
    NSIndexPath *indexpath = [self.tableView indexPathForCell:(UserListTableViewCell *)[gesture.view superview]];
    UIStoryboard *personalStoryboard= [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
    MineViewController *personalViewCon = [personalStoryboard instantiateViewControllerWithIdentifier:@"personalPage"];
    [personalViewCon setUserInfo:[self.datasource objectAtIndex:indexpath.row]];
    [personalViewCon.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:personalViewCon animated:YES];
     
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
