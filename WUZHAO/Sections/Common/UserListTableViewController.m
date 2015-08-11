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
#import "UIViewController+Basic.h"
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
    //refresh control
    [self setupRefreshControl];
    if ([self.userListStyle isEqual: UserListStyle3])
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.datasource || self.datasource.count <=0)
    {
        if (self.dataSource || self.getLatestDataBlock)
        {
            [self getLatestDataAnimated];
        }
    }
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

#pragma mark - gesture and action
-(void)avatarClick:(UITapGestureRecognizer *)gesture
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UserListTableViewCell *)[[gesture.view superview]superview]];
    User *user = [self.datasource[indexPath.row]mutableCopy];
    user.photoList = nil;
    [self goToPersonalPageWithUserInfo:user];
     
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
    [self endRefreshing];
        
}

-(void)refreshByPullingTable:(id)sender
{
    if ([self.dataSource respondsToSelector:@selector(updateUserListDatasource:)])
    {
         [self.dataSource updateUserListDatasource:self];
    }
    else if (self.getLatestDataBlock)
    {
        self.getLatestDataBlock();
    }
    else
    {
        [self endRefreshing];
    }
}
-(void)getLatestData
{
    if ([self.dataSource respondsToSelector:@selector(updateUserListDatasource:)])
    {
        [self.dataSource updateUserListDatasource:self];
    }
    else if (self.getLatestDataBlock)
    {
        self.getLatestDataBlock();
    }
    else
    {
        [self endRefreshing];
    }
}

-(void)gotoPhotoDetailPageWithPhotoInfo:(WhatsGoingOn *)item
{
    UIStoryboard *whatsNew = [UIStoryboard storyboardWithName:@"WhatsNew" bundle:nil];
    HomeTableViewController *detailPhotoController  = [whatsNew instantiateViewControllerWithIdentifier:@"HomeTableViewController"];
    [detailPhotoController setDatasource:[NSMutableArray arrayWithObject:item]];
    [detailPhotoController setTableStyle:WZ_TABLEVIEWSTYLE_DETAIL];
    [detailPhotoController getLatestData];
    [self pushToViewController:detailPhotoController animated:YES hideBottomBar:YES];
}

#pragma mark - pageViewControllerItem delegate
-(NSString *)titleForPagerViewController:(PagerViewController *)pagerViewController
{
    return @"用户";
}


@end
