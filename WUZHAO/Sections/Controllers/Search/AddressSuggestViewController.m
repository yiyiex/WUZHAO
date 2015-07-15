//
//  AddressSuggestViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/7/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "AddressSuggestViewController.h"

#import "AddressSuggestDistrictTableViewCell.h"
#import "AddressSuggestPOITableViewCell.h"
#import "MineViewController.h"

#import "AddressViewController.h"
#import "DistrictViewController.h"

#import "UIViewController+HideBottomBar.h"


@interface AddressSuggestViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation AddressSuggestViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init view
-(void)initTableView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refreshByPullingTable:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl setHidden:YES];
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

#pragma mark - tableview delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 209;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SuggestAddress *address = (SuggestAddress *)[self.datasource objectAtIndex:indexPath.row];
    if (address.type == SuggestAddressType_POI)
    {
      AddressSuggestPOITableViewCell *cell =(AddressSuggestPOITableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"POICell" forIndexPath:indexPath];
        [cell configureWithData:address];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UITapGestureRecognizer *userAvatarClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userAvatarClick:)];
        [cell.poiUserAvatarImageView addGestureRecognizer:userAvatarClick];
        [cell.poiUserAvatarImageView setUserInteractionEnabled:YES];
        return cell;
    }
    else if (address.type == SuggestAddressType_Distirct)
    {
        AddressSuggestDistrictTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DistrictCell" forIndexPath:indexPath];
        [cell configureWithData:address];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SuggestAddress *address = (SuggestAddress *)[self.datasource objectAtIndex:indexPath.row];
    if (address.type == SuggestAddressType_POI)
    {
        [self gotoPOIPageWithPOIInfo:address.poiInfo];
    }
    else if (address.type == SuggestAddressType_Distirct)
    {
        [self gotoDistrictPageWithDistirctInfo:address.districtInfo];
    }
    
}
#pragma mark - gesture and action
-(void)refreshByPullingTable:(id)sender
{
    if ([self.dataSource respondsToSelector:@selector(updateAddressDatasource:)])
    {
        [self.dataSource updateAddressDatasource:self];
        
    }
}
-(void)userAvatarClick:(UIGestureRecognizer *)gesture
{
    AddressSuggestPOITableViewCell *cell = (AddressSuggestPOITableViewCell *) gesture.view.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    SuggestAddress *address = [self.datasource objectAtIndex:indexPath.row];
    User *user = address.poiUser;
    [self gotoPersonalPageWithUserInfo:user];
}

#pragma mark - method
-(void)gotoPOIPageWithPOIInfo:(POI *)poi
{
    UIStoryboard *addressStoryboard = [UIStoryboard storyboardWithName:@"Address" bundle:nil];
    AddressViewController *addressViewCon = [addressStoryboard instantiateViewControllerWithIdentifier:@"addressPage"];
    //[self hidesBottomBarWhenPushed];
    addressViewCon.poiId = poi.poiId;
    addressViewCon.poiName = poi.name;
    [self pushToViewController:addressViewCon animated:YES hideBottomBar:YES];
    
}
-(void)gotoDistrictPageWithDistirctInfo:(District *)district
{
    DistrictViewController *districtViewController = [[DistrictViewController alloc]init];
    districtViewController.data = district;
    [self pushToViewController:districtViewController animated:YES hideBottomBar:YES];
}
-(void)gotoPersonalPageWithUserInfo:(User *)user
{
    UIStoryboard *personalStoryboard= [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
    MineViewController *personalViewCon = [personalStoryboard instantiateViewControllerWithIdentifier:@"personalPage"];
    [personalViewCon setUserInfo:user];
    [self pushToViewController:personalViewCon animated:YES hideBottomBar:YES];
}


@end
