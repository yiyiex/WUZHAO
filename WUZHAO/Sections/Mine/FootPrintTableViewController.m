//
//  FootPrintTableViewController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-21.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "FootPrintTableViewController.h"
#import "FootPrintTableViewCell.h"
#import "FootPrint.h"
#import "macro.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+ChangeAppearance.h"

#import "SWSnapshotStackView.h"

#import "HomeTableViewController.h"
#import "AddressViewController.h"
#import "PhotosCollectionViewController.h"
#import "UIViewController+HideBottomBar.h"
#import "SVProgressHUD.h"

#import "WhatsGoingOn.h"

#import "POISearchAPI.h"

#define spacing 2
#define photoWidth (WZ_APP_SIZE.width + spacing)/3-spacing

@interface FootPrintTableViewController()


@end

@implementation FootPrintTableViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[FootPrintTableViewCell class] forCellReuseIdentifier:@"footprintCell"];
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView reloadData];
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
-(void)ConfigureCell:(FootPrintTableViewCell *)cell WithPhotoList:(NSArray *)photoList
{
    float basicHeight = 20 + 8*2;
    NSInteger photoNum = photoList.count;
    SWSnapshotStackView *snapshotView = [[SWSnapshotStackView alloc]initWithFrame: CGRectMake( 0, basicHeight +  spacing, photoWidth, photoWidth)];
    if (photoNum ==1)
    {
        snapshotView.displayAsStack = NO;
    }
    else
    {
        snapshotView.displayAsStack = YES;
    }
    WhatsGoingOn *item = photoList[0];
    CGRect frame = CGRectMake( 0, basicHeight +  spacing , photoWidth, photoWidth);
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];
    [imageView sd_setImageWithURL:[NSURL URLWithString:item.imageUrlString] placeholderImage:[UIImage imageNamed:@"placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [snapshotView setImage:image];
        [cell addSubview:snapshotView];
        UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageViewTaped:)];
        [snapshotView addGestureRecognizer:tapgesture];
        [snapshotView setUserInteractionEnabled:YES];
    }];
    //NSInteger showNum = photoNum<=3?photoNum:3*(photoNum/3);
    /*
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

    }*/
    UITapGestureRecognizer *photoNumLabelTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(photoNumLabelClick:)];
    [cell.photoNumLabel addGestureRecognizer:photoNumLabelTap];
    [cell.photoNumLabel setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *addressNameLabelTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addressLabelClick:)];
    [cell.addressNameLabel addGestureRecognizer:addressNameLabelTap];
    [cell.addressNameLabel setUserInteractionEnabled:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float basicHeight = 36;
    float imageHeight = 0;
    
    AddressPhotos *content = [self dataAtIndexPath:indexPath];
    NSInteger imageRowNum =ceilf((float)content.photoList.count/3);
    imageHeight = imageRowNum * (photoWidth+spacing);
    float height = basicHeight + imageHeight;
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float basicHeight = 36;
    float imageHeight = 0;
    
    AddressPhotos *content = [self dataAtIndexPath:indexPath];
    NSInteger imageRowNum =ceilf((float)content.photoList.count/3);
    imageHeight = imageRowNum * (photoWidth+spacing);
    
    float height = basicHeight + imageHeight;
    return height;
}

-(AddressPhotos *)dataAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataSource)
    {
        return [self.dataSource FootPrintTableView:self dataAtIndex:indexPath.row];
    }
    else
    {
        return [self.datasource objectAtIndex:indexPath.row];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (self.dataSource)
    {
        return [self.dataSource numberOfPhotos:(FootPrintTableViewController *)tableView];
    }
    return [self.datasource count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FootPrintTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"footprintCell" forIndexPath:indexPath];
    AddressPhotos *content = [self dataAtIndexPath:indexPath];
    cell.addressNameLabel.text = content.poi.name;
    cell.photoNumLabel.text = [NSString stringWithFormat:@"%ld张",(long)content.photoNum];
    [self ConfigureCell:cell WithPhotoList:content.photoList];
    return cell;
}

#pragma mark - gesture action
-(void)imageViewTaped:(UIGestureRecognizer *)gesture
{
    NSInteger imageViewTag = gesture.view.tag;
    FootPrintTableViewCell *cell = (FootPrintTableViewCell *)gesture.view.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    WhatsGoingOn *item =((AddressPhotos *) [self dataAtIndexPath:indexPath]).photoList[imageViewTag];

    UIStoryboard *whatsNew = [UIStoryboard storyboardWithName:@"WhatsNew" bundle:nil];
    HomeTableViewController *detailPhotoController  = [whatsNew instantiateViewControllerWithIdentifier:@"HomeTableViewController"];
    [detailPhotoController setDataSource:[NSMutableArray arrayWithObject:item]];
    [detailPhotoController setTableStyle:WZ_TABLEVIEWSTYLE_DETAIL];
    [detailPhotoController GetLatestDataList];
    [self pushToViewController:detailPhotoController animated:YES hideBottomBar:YES];
    
}
-(void)addressLabelClick:(UIGestureRecognizer *)gesture
{
    FootPrintTableViewCell *cell = (FootPrintTableViewCell *)gesture.view.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    AddressPhotos *data = (AddressPhotos *)[self dataAtIndexPath:indexPath];
    [self goToPOIPhotoListWithPoi:data.poi];
    
}
-(void)photoNumLabelClick:(UIGestureRecognizer *)gesture
{
    FootPrintTableViewCell *cell = (FootPrintTableViewCell *)gesture.view.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    AddressPhotos *data = (AddressPhotos *)[self dataAtIndexPath:indexPath];
    [self goToPOIPhotoListWithPoi:data.poi];
    
}
-(void)goToPOIPhotoListWithPoi:(POI *)poi
{
    UIStoryboard *addressStoryboard = [UIStoryboard storyboardWithName:@"Address" bundle:nil];
    AddressViewController *addressViewCon = [addressStoryboard instantiateViewControllerWithIdentifier:@"addressPage"];
    addressViewCon.poiName = poi.name;
    addressViewCon.poiLocation = poi.locationArray;
    [self pushToViewController:addressViewCon animated:YES hideBottomBar:YES];
    NSInteger userId = self.currentUser.UserID;
    [[POISearchAPI sharedInstance]getPOIDetail:poi.poiId userId:userId whenComplete:^(NSDictionary *returnData) {
        if ([returnData objectForKey:@"data"])
        {
            AddressPhotos *address = [returnData objectForKey:@"data"];
            addressViewCon.photoCollectionDatasource = address.photoList;
            [addressViewCon getLatestAddressPhoto];
            
        }
        else if ([returnData objectForKey:@"error"])
        {
            [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
        }
    }];
}
@end
