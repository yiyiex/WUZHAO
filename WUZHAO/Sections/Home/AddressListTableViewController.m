//
//  AddressListTableViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/7/21.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "AddressListTableViewController.h"
#import "HomeAddressListTableViewCell.h"

#import "HomeTableViewController.h"
#import "AddressViewController.h"
#import "PhotosCollectionViewController.h"
#import "AddresslistTableHeaderView.h"
#import "AddressDistrictTableViewCell.h"
#import "OneDistrictViewController.h"
#import "DistrictViewController.h"

#import "macro.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+ChangeAppearance.h"
#import "UIViewController+Basic.h"
#import "SVProgressHUD.h"
#import "POISearchAPI.h"
#import "QDYHTTPClient.h"
#import "CLLocationUtility.h"

#define spacing 2
#define photoWidth (WZ_APP_SIZE.width + spacing)/3-spacing

@interface AddressListTableViewController ()<AddressDistrictTableViewCellDelegate>
@property (nonatomic, strong) CLLocationUtility *locationUtility;
@property (nonatomic, strong) NSArray *countryDisctrcts;
@property (nonatomic, strong) NSArray *cityDistricts;
@end

@implementation AddressListTableViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setupRefreshControl];
    [self.tableView registerNib:[UINib nibWithNibName:@"HomeAddressListCell" bundle:nil] forCellReuseIdentifier:@"AddressListCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"AddressDistrictTableViewCell" bundle:nil] forCellReuseIdentifier:@"DistrictCell"];
    [self.tableView registerClass:[AddresslistTableHeaderView class] forHeaderFooterViewReuseIdentifier:@"sectionHeader"];
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;    
    //[self getLatestDataAnimated];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clearUserInfo) name:@"deleteUserInfo" object:nil];
}
-(NSArray *)cityDistricts
{
    if (!_cityDistricts)
    {
        _cityDistricts = [[NSArray alloc]init];
    }
    return _cityDistricts;
}
-(NSArray *)countryDisctrcts
{
    if (!_countryDisctrcts)
    {
        _countryDisctrcts = [[NSArray alloc]init];
    }
    return _countryDisctrcts;
}

-(void)viewWillAppear:(BOOL)animated
{
    if (self.datasource.count == 0 || !self.datasource)
    {
        [self getLatestDataAnimated];
    }
}

-(void)loadData
{
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self endRefreshing];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark =======tableview delegate
-(void)ConfigureCell:(HomeAddressListTableViewCell *)cell WithPhotoList:(NSArray *)photoList
{
    float basicHeight = 8+ 24 + 10 + 10;
    NSInteger photoNum = photoList.count;
    //NSInteger showNum = photoNum<=3?photoNum:3*(photoNum/3);
    for (NSInteger i = 0;i<photoNum;i++)
    {
        WhatsGoingOn *item = photoList[i];
        CGRect frame = CGRectMake(i%3*(photoWidth+spacing), basicHeight +  spacing + i/3*(photoWidth + spacing), photoWidth, photoWidth);
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];
        imageView.tag = i;
        [imageView sd_setImageWithURL:[NSURL URLWithString:item.imageUrlString] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageViewTaped:)];
        [imageView addGestureRecognizer:tapgesture];
        [imageView setUserInteractionEnabled:YES];
        [cell addSubview:imageView];
    }
    
    UITapGestureRecognizer *addressNameLabelTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addressLabelClick:)];
    [cell.addressNameLabel addGestureRecognizer:addressNameLabelTap];
    [cell.addressNameLabel setUserInteractionEnabled:YES];
    
    [cell.enterButton addTarget:self action:@selector(addressEnterButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(CGFloat)caculateHeightForRowAtIndexPath:(NSIndexPath *)indexpath
{
    if (indexpath.section==2)
    {
        CGFloat basicHeight = 8+ 24 + 10 + 10;
        CGFloat imageHeight = 0;
        
        AddressPhotos *content = [self.datasource objectAtIndex:indexpath.row];
        NSInteger imageRowNum =ceilf((float)content.photoList.count/3);
        imageHeight = imageRowNum * (photoWidth+spacing);
        CGFloat height = basicHeight + imageHeight;
        return height;
    }
    else if(indexpath.section == 0)
    {
        return self.countryDisctrcts.count/3*((WZ_APP_SIZE.width-32)/3*9/16+8);
    }
    else if (indexpath.section == 1)
    {
        return self.cityDistricts.count/3*((WZ_APP_SIZE.width-32)/3*9/16+8);
    }
    else return 0;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self caculateHeightForRowAtIndexPath:indexPath];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //return 0;
    
    if (section == 0 && self.countryDisctrcts.count == 0)
    {
        return 0;
    }
    else if (section == 1 && self.cityDistricts.count == 0)
    {
        return 0;
    }
    else if (section == 2 )
    {
        return 0;
    }
    return 32;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self caculateHeightForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 2)
    {
        return [self.datasource count];
    }
    else if (section == 0)
    {
        if (self.countryDisctrcts.count == 0)
        {
            return 0;
        }
        return 1;
    }
    else if (section == 1)
    {
        if (self.cityDistricts.count == 0)
        {
            return 0;
        }
        return 1;
    }
    return 0;
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    AddresslistTableHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"sectionHeader"];
    if (section == 0)
    {
        [headerView.headerLabel setText:@"热门国家"];
    }
    else if (section == 1)
    {
        [headerView.headerLabel setText:@"热门城市"];
    }
    else
    {
        
    }
    return headerView;
    
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2)
    {
        HomeAddressListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddressListCell" forIndexPath:indexPath];
        AddressPhotos *content = [self.datasource objectAtIndex:indexPath.row];
        [cell.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[UIImageView class]])
            {
                [obj removeFromSuperview];
            }
        }];
        cell.addressNameLabel.text = content.poi.name;
        cell.addressDescriptionLabel.text = content.addressDescription;

        [self ConfigureCell:cell WithPhotoList:content.photoList];
        return cell;
    }
    else
    {
        AddressDistrictTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DistrictCell" forIndexPath:indexPath];
        if (!cell)
        {
            cell = [[AddressDistrictTableViewCell alloc]init];
        }
        if (indexPath.section == 0)
        {
            cell.DistrictList = self.countryDisctrcts;
        }
        else if (indexPath.section == 1)
        {
            cell.DistrictList = self.cityDistricts;
        }
        [cell.collectionView reloadData];
        cell.delegate = self;
        
        return cell;
    }
}
#pragma mark - control the model

-(void)getLatestData
{
    if (self.shouldRefreshData == NO)
    {
        return;
    }
    self.shouldRefreshData = NO;
    if (!self.locationUtility)
    {
        self.locationUtility = [[CLLocationUtility alloc]init];
    }
    [self.locationUtility getCurrentLocationWithComplete:^(NSDictionary *result) {
        self.shouldRefreshData = YES;
        NSString *location = @"";
        if ([[result objectForKey:@"success"]isEqualToString:@"NO"])
        {
            NSLog(@"定位失败");
        }
        else
        {
            CLLocation  *searchLocation = [result objectForKey:@"location"];
            location = [NSString stringWithFormat:@"%f,%f",searchLocation.coordinate.latitude,searchLocation.coordinate.longitude];
        }
        [[QDYHTTPClient sharedInstance]GetHomeAddressWithLocation:location whenComplete:^(NSDictionary *returnData) {
            if ([returnData objectForKey:@"data"])
            {
                NSDictionary *data = [returnData objectForKey:@"data"];
                self.countryDisctrcts = [data objectForKey:@"hotCountries"];
                self.cityDistricts = [data objectForKey:@"hotCities"];
                self.datasource = [data objectForKey:@"hotPOIs"];
                [self loadData];
            }
            else if ([returnData objectForKey:@"error"])
            {
                [SVProgressHUD showErrorWithStatus:@"获取数据失败"];
            }
            [self endRefreshing];
            
        }];
       
    }];
    

}

#pragma mark - gesture action
-(void)imageViewTaped:(UIGestureRecognizer *)gesture
{
    NSInteger imageViewTag = gesture.view.tag;
    HomeAddressListTableViewCell *cell = (HomeAddressListTableViewCell *)gesture.view.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    WhatsGoingOn *item =((AddressPhotos *) [self.datasource objectAtIndex:indexPath.row]).photoList[imageViewTag];
    
    UIStoryboard *whatsNew = [UIStoryboard storyboardWithName:@"WhatsNew" bundle:nil];
    HomeTableViewController *detailPhotoController  = [whatsNew instantiateViewControllerWithIdentifier:@"HomeTableViewController"];
    [detailPhotoController setDatasource:[NSMutableArray arrayWithObject:item]];
    [detailPhotoController setTableStyle:WZ_TABLEVIEWSTYLE_DETAIL];
    [detailPhotoController getLatestData];
    [self pushToViewController:detailPhotoController animated:YES hideBottomBar:YES];
    
}
-(void)addressLabelClick:(UIGestureRecognizer *)gesture
{
    HomeAddressListTableViewCell *cell = (HomeAddressListTableViewCell *)gesture.view.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    AddressPhotos *data = (AddressPhotos *)[self.datasource objectAtIndex:indexPath.row];
    [self goToPOIPhotoListWithPoi:data.poi];
    
}
-(void)photoNumLabelClick:(UIGestureRecognizer *)gesture
{
    HomeAddressListTableViewCell *cell = (HomeAddressListTableViewCell *)gesture.view.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    AddressPhotos *data = (AddressPhotos *)[self.datasource objectAtIndex:indexPath.row];
    [self goToPOIPhotoListWithPoi:data.poi];
    
}
-(void)addressEnterButtonClick:(UIButton *)sender
{
    HomeAddressListTableViewCell *cell = (HomeAddressListTableViewCell *)sender.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
      AddressPhotos *data = (AddressPhotos *)[self.datasource objectAtIndex:indexPath.row];
    [self goToPOIPhotoListWithPoi:data.poi];
}



#pragma mark - notification
-(void)clearUserInfo
{
    self.datasource = [[NSMutableArray alloc]initWithArray:@[]];
    [self.tableView reloadData];
}

#pragma mark - pagerViewControllerItem delegate
-(NSString *)titleForPagerViewController:(PagerViewController *)pagerViewController
{
    return @"地点";
}

#pragma mark - addressDistrictTableViewCell delegate
-(void)gotoDistrictPageWithDisctrict:(District *)district
{
    DistrictViewController *districtViewController = [[DistrictViewController alloc]init];
    districtViewController.data = district;
    [self pushToViewController:districtViewController animated:YES hideBottomBar:YES];

}


@end
