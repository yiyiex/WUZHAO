//  展示一系列照片的collection
//  PhotosCollectionViewController.m
//  WUZHAO
//
//  Created by yiyi on 15-1-5.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "PhotosCollectionViewController.h"
#import "PhotoCollectionViewCell.h"
#import "HomeTableViewController.h"

#import "PhotoScrollViewController.h"
#import "PhotoDetailViewsController.h"


#import "UIViewController+Basic.h"

#import "UIImageView+WebCache.h"
#import "UILabel+ChangeAppearance.h"
#import "PhotoCommon.h"
#import "macro.h"
#import "QDYHTTPClient.h"


@interface PhotosCollectionViewController ()
@property (nonatomic,strong) UIView *infoView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation PhotosCollectionViewController

static NSString * const reuseIdentifier = @"photoCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerNib:[UINib nibWithNibName:@"PhotosCollectionCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    [self setupRefreshControl];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   // [self.collectionView sizeToFit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadData
{
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
    if (self.datasource.count == 0)
    {
        if (![self.infoView superview])
        {
            self.infoView = [[UIView alloc]initWithFrame:self.view.frame];
            UILabel *infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, WZ_APP_SIZE.width-20, 30)];
            infoLabel.text = @"还没有照片哦";
            infoLabel.textAlignment = NSTextAlignmentCenter;
            [infoLabel setReadOnlyLabelAppearance];
            [self.infoView addSubview:infoLabel];
            
            [self.collectionView addSubview:self.infoView];
        }
    }
    else
    {
        if (self.infoView)
        {
            [self.infoView removeFromSuperview];
        }
    }
    if ([self.refreshControl isRefreshing])
    {
        [self.refreshControl endRefreshing];
    }
}
#pragma mark <UICollectionViewDataSource>
-(WhatsGoingOn *)dataAtIndexPath:(NSIndexPath *)indexPath
{
    WhatsGoingOn *item;
    if ([self.dataSource respondsToSelector:@selector(objectAtIndex:)])
    {
        item = [self.datasource objectAtIndex:indexPath.row];
    }
    //WhatsGoingOn * item = [self.datasource objectAtIndex:indexPath.row];
    else
    {
        item = [self.datasource objectAtIndex:indexPath.row];
    }
    return item;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([self.dataSource respondsToSelector:@selector(numberOfPhotos:)])
    {
        return [self.dataSource numberOfPhotos:self];
    }
    return [self.datasource count];
    
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell *cell =(PhotoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[PhotoCollectionViewCell alloc]init];
    }
    
    [cell configureWithContent:self.datasource[indexPath.row]];
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

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((WZ_APP_FRAME.size.width-2)/3, (WZ_APP_FRAME.size.width-2)/3);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //[self performSegueWithIdentifier:@"showDetail" sender:self];
    if (self.detailStyle == DETAIL_STYLE_SINGLEPAGE)
    {
        WhatsGoingOn *item = [self dataAtIndexPath:indexPath];
    
        UIStoryboard *whatsNew = [UIStoryboard storyboardWithName:@"WhatsNew" bundle:nil];
        HomeTableViewController *detailPhotoController  = [whatsNew instantiateViewControllerWithIdentifier:@"HomeTableViewController"];
        [detailPhotoController setDatasource:[NSMutableArray arrayWithObject:item]];
        [detailPhotoController setTableStyle:WZ_TABLEVIEWSTYLE_DETAIL];
        [self pushToViewController:detailPhotoController animated:YES hideBottomBar:YES];
        //[detailPhotoController GetLatestDataList];
    }
    else
    {
        WhatsGoingOn *item = [self dataAtIndexPath:indexPath];
        
        UIStoryboard *whatsNew = [UIStoryboard storyboardWithName:@"WhatsNew" bundle:nil];
        HomeTableViewController *detailPhotoController  = [whatsNew instantiateViewControllerWithIdentifier:@"HomeTableViewController"];
        
        [detailPhotoController setDatasource:[NSMutableArray arrayWithObject:item]];
        [detailPhotoController setTableStyle:WZ_TABLEVIEWSTYLE_DETAIL];
        [self pushToViewController:detailPhotoController animated:YES hideBottomBar:YES];
       // [detailPhotoController GetLatestDataList];
        
    }

    
}

#pragma mark - photoDetailViewsControllerDelegate
-(WhatsGoingOn *)photoDetailViewsController:(PhotoDetailViewsController *)detailViews dataAtIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:index];
    return [self dataAtIndexPath:indexPath];
}

#pragma mark - gesture and action
-(void)refreshByPullingTable:(id)sender
{
    if (self.shouldRefreshData)
    {
        if ([self.dataSource respondsToSelector:@selector(updatePhotoCollectionDatasource:)])
        {
            [self.dataSource updatePhotoCollectionDatasource:self];
        }
        else if (self.getLatestDataBlock)
        {
            self.getLatestDataBlock();
        }
        else
        {
            [self getLatestData];
        }
    }
    else
    {
        [self endRefreshing];
    }
    
}

@end
