//
//  AddressPhotosCollectionViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/8/5.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "AddressPhotosCollectionViewController.h"
#import "PhotoCollectionViewCell.h"
#import "AddressPhotoCollectionHeaderView.h"
#import "macro.h"
#import "QDYHTTPClient.h"
#import "POISearchAPI.h"
#import "SVProgressHUD.h"

@interface AddressPhotosCollectionViewController ()

@end

@implementation AddressPhotosCollectionViewController

static NSString * const reuseIdentifier = @"photoCollectionViewCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupRefreshControl];
    [self.collectionView registerNib:[UINib nibWithNibName:@"PhotosCollectionCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(POI *)poi
{
    if(!_poi)
    {
        _poi = [[POI alloc]init];
    }
    return _poi;
}
-(NSMutableArray *)recommendPhotos
{
    if (!_recommendPhotos)
    {
        _recommendPhotos = [[NSMutableArray alloc]init];
    }
    return _recommendPhotos;
}
-(NSMutableArray *)addressPhotos
{
    if (!_addressPhotos)
    {
        _addressPhotos = [[NSMutableArray alloc]init];
    }
    return _addressPhotos;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - control the model
-(void)getLatestData
{
    if (!self.shouldRefreshData)
    {
        return;
    }
    if (self.poi.poiId <=0)
    {
        [self endRefreshing];
        return;
    }
    self.shouldRefreshData = NO;
    if (self.userId >0)
    {
        [[POISearchAPI sharedInstance]getPOIDetail:self.poi.poiId userId:self.userId whenComplete:^(NSDictionary *returnData) {
            self.shouldRefreshData = YES;
            if ([returnData objectForKey:@"data"])
            {
                AddressPhotos *address = [returnData objectForKey:@"data"];
                self.addressPhotos = address.photoList;
                [self loadData];
                
            }
            else if ([returnData objectForKey:@"error"])
            {
                [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:@"请求失败"];
            }
            [self endRefreshing];
        }];
    }
    else
    {
        [[QDYHTTPClient sharedInstance]GetPOIInfoWithPoiId:self.poi.poiId recommendFirstPostId:self.recommendFirstPostId whenComplete:^(NSDictionary *reuslt) {
            self.shouldRefreshData = YES;
            if ([reuslt objectForKey:@"data"])
            {
                NSDictionary *data = [reuslt objectForKey:@"data"];
                self.recommendPhotos = [data objectForKey:@"recommendPoiInfo"];
                self.addressPhotos = [data objectForKey:@"allPosts"];
                [self loadData];
            }
            else if ([reuslt objectForKey:@"error"])
            {
                [SVProgressHUD showErrorWithStatus:[reuslt objectForKey:@"error"]];
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:@"请求失败"];
            }
            [self endRefreshing];
        }];
    }
}

#pragma mark <UICollectionViewDataSource>
-(WhatsGoingOn *)dataAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return self.recommendPhotos[indexPath.row];
    }
    else if (indexPath.section == 1)
    {
        return self.addressPhotos[indexPath.row];
    }
    return nil;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
   if (section == 0)
   {
       return self.recommendPhotos.count;
   }
   else if (section == 1)
   {
       return self.addressPhotos.count;
   }
   return 0;
    
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell *cell =(PhotoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[PhotoCollectionViewCell alloc]init];
    }
    [cell configureWithContent:[self dataAtIndexPath:indexPath]];
    return cell;
}



-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0f;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0f;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    AddressPhotoCollectionHeaderView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headView" forIndexPath:indexPath];
    if (indexPath.section == 0)
    {
        view.headLabel.text = @"精选";
    }
    else if (indexPath.section == 1)
    {
        view.headLabel.text= @"最新";
    }
    return view;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        if (self.recommendPhotos.count >0)
        {
            return CGSizeMake(collectionView.frame.size.width, 30);
        }
        else
        {
            return CGSizeMake(collectionView.frame.size.width, 0);
        }
    }
    else if(section == 1)
    {
        return CGSizeMake(collectionView.frame.size.width, 30);
    }
    else
    {
        return CGSizeMake(collectionView.frame.size.width, 0);
    }
    
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((WZ_APP_FRAME.size.width-2)/3, (WZ_APP_FRAME.size.width-2)/3);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WhatsGoingOn *item = [self dataAtIndexPath:indexPath];
    if (item)
    {
        [self gotoPhotoDetailPageWithItem:item];
    }
}

#pragma mark - transition
-(void)gotoPhotoDetailPageWithItem:(WhatsGoingOn *)item
{
    
    UIStoryboard *whatsNew = [UIStoryboard storyboardWithName:@"WhatsNew" bundle:nil];
    HomeTableViewController *detailPhotoController  = [whatsNew instantiateViewControllerWithIdentifier:@"HomeTableViewController"];
    [detailPhotoController setDatasource:[NSMutableArray arrayWithObject:item]];
    [detailPhotoController setTableStyle:WZ_TABLEVIEWSTYLE_DETAIL];
    [self pushToViewController:detailPhotoController animated:YES hideBottomBar:YES];
    //[detailPhotoController GetLatestDataList];
}

@end
