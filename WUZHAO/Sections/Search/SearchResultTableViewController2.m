//
//  SearchResultTableViewController2.m
//  WUZHAO
//
//  Created by yiyi on 15/4/12.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//
#import "SearchResultViewController.h"
#import "SearchResultTableViewController2.h"
#import "UserListTableViewCell.h"
#import "MineViewController.h"
#import "QDYHTTPClient.h"
#import "SVProgressHUD.h"
#import "macro.h"

@interface SearchResultTableViewController2 ()<UISearchBarDelegate>
@property (nonatomic, strong) NSMutableArray *searchUserListData;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic) NSInteger searchStatus;
@end

@implementation SearchResultTableViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavigationItem];
    self.searchStatus = SEARCHSTATUSNOTBEGIN;
    [self.tableView registerNib:[UINib nibWithNibName:@"UserListTableViewCell" bundle:nil] forCellReuseIdentifier:@"UserListTableViewCellWithFollowButton"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"defaultCell"];
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)initNavigationItem
{
    self.navigationItem.titleView = self.searchBar;
    
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarItem;
    
    //self.navigationItem.hidesBackButton = YES;
    //self.tabBarController.navigationItem.hidesBackButton = YES;
}
-(UISearchBar *)searchBar
{
    if (!_searchBar)
    {
        _searchBar = [[UISearchBar alloc]init];
        [_searchBar setBarStyle:UIBarStyleDefault];
        [_searchBar setPlaceholder:@"搜索用户"];
        [_searchBar becomeFirstResponder];
       // [_searchBar setTintColor:THEME_COLOR_LIGHT_GREY_PARENT];
        // [_searchBar setShowsCancelButton:YES];
        _searchBar.delegate = self;
    }
    return _searchBar;
}
#pragma mark - searchbar Delegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{

    if ([searchBar.text isEqualToString:@""])
    {
        self.searchStatus = SEARCHSTATUSNOTBEGIN;
        [self.searchUserListData removeAllObjects];
        [self.tableView reloadData];
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchStatus = SEARCHSTATUSNOTBEGIN;
    [self.searchUserListData removeAllObjects];
    [self.tableView reloadData];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([searchBar.text isEqualToString: @""])
        return;
    self.searchStatus = SEARCHSTATUSING;
    [self.searchUserListData removeAllObjects];
    [self.tableView reloadData];
    NSString *searchString = searchBar.text;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[QDYHTTPClient sharedInstance]searchWithType:@"user" keyword:searchString whenComplete:^(NSDictionary *returnData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([returnData objectForKey:@"data"])
                {
                    self.searchUserListData = [[returnData objectForKey:@"data"]mutableCopy];
                    self.searchStatus = SEARCHSTATUSEND;
                    [self.tableView reloadData];
                }
                else if ([returnData objectForKey:@"error"])
                {
                    self.searchStatus = SEARCHSTATUSERROR;
                    [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
                }
            });

        }];
    });

    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.searchUserListData.count>0?self.searchUserListData.count:1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    if (self.searchUserListData.count == 0 && indexPath.row ==0)
    {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell" forIndexPath:indexPath];
        if (!cell)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"defaultCell"];
        }
        if (self.searchStatus == SEARCHSTATUSNOTBEGIN)
        {
            cell.textLabel.text = @"搜索用户...";
        }
        else if (self.searchStatus == SEARCHSTATUSING)
        {
            cell.textLabel.text = @"正在搜索...";
        }
        else if (self.searchStatus == SEARCHSTATUSEND)
        {
            cell.textLabel.text = @"无用户搜索结果";
        }
        else if (self.searchStatus == SEARCHSTATUSERROR)
        {
            cell.textLabel.text = @"搜索失败";
        }
        return cell;
    }
    else
    {
        UserListTableViewCell *cell =(UserListTableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"UserListTableViewCellWithFollowButton"];
        User *userData = [self.searchUserListData objectAtIndex:indexPath.row];
        [cell configWithUser:userData style:UserListStyle2];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *personalStoryboard= [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
    MineViewController *personalViewCon = [personalStoryboard instantiateViewControllerWithIdentifier:@"personalPage"];
    [personalViewCon setUserInfo:[self.searchUserListData objectAtIndex:indexPath.row]];
    [personalViewCon.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:personalViewCon animated:YES];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
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
