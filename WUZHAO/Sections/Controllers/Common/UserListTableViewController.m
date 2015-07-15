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
#import "UIViewController+HideBottomBar.h"
#import "HomeTableViewController.h"

#import "MineViewController.h"

#import "SVProgressHUD.h"


#import "User.h"

#define REUSEIDENTIFIER @"userListCell"
#define CELL_HEADERHEIGHT 64.0

@interface UserListTableViewController ()
@property (nonatomic, strong) UserListTableViewCell *prototypeCell;

@end

@implementation UserListTableViewController
@synthesize userListStyle = _userListStyle;

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.userListStyle = UserListStyle3;
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarItem;
    
    //refresh control
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refreshByPullingTable:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UserListTableViewCell *)prototypeCell
{
    if (!_prototypeCell) {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"commentTableCell"];
    }
    return _prototypeCell;
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

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height ;
    if ([self.userListStyle isEqualToString:UserListStyle1] || [self.userListStyle isEqualToString:UserListStyle2])
    {
        height = CELL_HEADERHEIGHT;
    }
    
    else if ([self.userListStyle isEqualToString:UserListStyle3])
    {
        height =  CELL_HEADERHEIGHT + (WZ_DEVICE_SIZE.width-2)/3*2+1;
    }
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height ;
    if ([self.userListStyle isEqualToString:UserListStyle1] || [self.userListStyle isEqualToString:UserListStyle2])
    {
        height = CELL_HEADERHEIGHT;
    }
    
    else if ([self.userListStyle isEqualToString:UserListStyle3])
    {
        height =  CELL_HEADERHEIGHT -4 + (WZ_DEVICE_SIZE.width-2)/3*2+1;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserListTableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:self.userListStyle forIndexPath:indexPath];
    if (!cell)
    {
        cell = [[UserListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.userListStyle];
    }
    if ([self.userListStyle  isEqual: UserListStyle3])
    {
        [cell.photoImageViews enumerateObjectsUsingBlock:^(UIImageView *imageView, NSUInteger idx, BOOL *stop) {
            UITapGestureRecognizer *imageClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(photoClick:)];
            [imageView addGestureRecognizer:imageClick];
            [imageView setUserInteractionEnabled:NO];
        }];
    }
    [cell configWithUser:self.datasource[indexPath.row] style:self.userListStyle];
    
    //gesture
    UITapGestureRecognizer *avatarClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarClick:)];
    [cell.avatorImageView addGestureRecognizer:avatarClick];
    [cell.avatorImageView setUserInteractionEnabled:YES];

    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self gotoPersonalPageWithUserInfo:self.datasource[indexPath.row]];
}


#pragma mark - gesture and action
-(void)avatarClick:(UITapGestureRecognizer *)gesture
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UserListTableViewCell *)[[gesture.view superview]superview]];
    [self gotoPersonalPageWithUserInfo:[self.datasource[indexPath.row]mutableCopy]];
     
}
-(void)photoClick:(UITapGestureRecognizer *)gesture
{
    UIImageView *imageView = (UIImageView *)gesture.view;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UserListTableViewCell *)[[gesture.view superview]superview]];
    User *user = [self.datasource [indexPath.row]mutableCopy];
    [self gotoPhotoDetailPageWithPhotoInfo:user.photoList[imageView.tag]];
    
}

-(void)loadData
{
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    if ([self.refreshControl isRefreshing])
    {
        [self.refreshControl endRefreshing];
    }
        
}

-(void)refreshByPullingTable:(id)sender
{
     if ([self.dataSource respondsToSelector:@selector(updateUserListDatasource:)])
     {
         [self.dataSource updateUserListDatasource:self];
     }
    else
    {
        if ([self.refreshControl isRefreshing])
        {
            [self.refreshControl endRefreshing];
        }
    }
}

-(void)gotoPersonalPageWithUserInfo:(User *)user
{
    user.photoList = nil;
    UIStoryboard *personalStoryboard= [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
    MineViewController *personalViewCon = [personalStoryboard instantiateViewControllerWithIdentifier:@"personalPage"];
    [personalViewCon setUserInfo:user];
    [self pushToViewController:personalViewCon animated:YES hideBottomBar:YES];
}

-(void)gotoPhotoDetailPageWithPhotoInfo:(WhatsGoingOn *)item
{
    UIStoryboard *whatsNew = [UIStoryboard storyboardWithName:@"WhatsNew" bundle:nil];
    HomeTableViewController *detailPhotoController  = [whatsNew instantiateViewControllerWithIdentifier:@"HomeTableViewController"];
    [detailPhotoController setDataSource:[NSMutableArray arrayWithObject:item]];
    [detailPhotoController setTableStyle:WZ_TABLEVIEWSTYLE_DETAIL];
    [detailPhotoController GetLatestDataList];
    [self pushToViewController:detailPhotoController animated:YES hideBottomBar:YES];
}


@end
