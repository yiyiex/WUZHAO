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

@interface AddressListTableViewController ()
@property (nonatomic, strong) CLLocationUtility *locationUtility;
@end

@implementation AddressListTableViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setupRefreshControl];
    [self.tableView registerNib:[UINib nibWithNibName:@"HomeAddressListCell" bundle:nil] forCellReuseIdentifier:@"AddressListCell"];
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self getLatestData];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clearUserInfo) name:@"deleteUserInfo" object:nil];
}

-(void)loadData
{
    
    [self.tableView reloadData];
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
    return 1;
}

-(CGFloat)caculateHeightForRowAtIndexPath:(NSIndexPath *)indexpath
{
    CGFloat basicHeight = 8+ 24 + 10 + 10;
    CGFloat imageHeight = 0;
    
    AddressPhotos *content = [self.datasource objectAtIndex:indexpath.row];
    NSInteger imageRowNum =ceilf((float)content.photoList.count/3);
    imageHeight = imageRowNum * (photoWidth+spacing);
    CGFloat height = basicHeight + imageHeight;
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self caculateHeightForRowAtIndexPath:indexPath];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self caculateHeightForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.datasource count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
#pragma mark - control the model
-(void)getLatestData
{
    if (!self.locationUtility)
    {
        self.locationUtility = [[CLLocationUtility alloc]init];
    }
    
    [self.locationUtility getCurrentLocationWithComplete:^(NSDictionary *result) {
        if ([[result objectForKey:@"success"]isEqualToString:@"NO"])
        {
            NSLog(@"定位失败");
        }
        else
        {
            CLLocation  *searchLocation = [result objectForKey:@"location"];
            NSString *location = [NSString stringWithFormat:@"%f,%f",searchLocation.coordinate.latitude,searchLocation.coordinate.longitude];
            [[QDYHTTPClient sharedInstance]GetHomeAddressWithLocation:location whenComplete:^(NSDictionary *returnData) {
                if ([returnData objectForKey:@"data"])
                {
                    self.datasource = [returnData objectForKey:@"data"];
                    [self loadData];
                }
                else if ([returnData objectForKey:@"error"])
                {
                    [SVProgressHUD showErrorWithStatus:@"获取数据失败"];
                }
                
            }];
            [self loadData];
        }
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
    self.datasource = nil;
    [self.tableView reloadData];
}

#pragma mark - pagerViewControllerItem delegate
-(NSString *)titleForPagerViewController:(PagerViewController *)pagerViewController
{
    return @"地点";
}
@end
