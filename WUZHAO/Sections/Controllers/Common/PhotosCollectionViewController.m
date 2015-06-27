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



#import "UIImageView+WebCache.h"
#import "UIViewController+BackBarItem.h"
#import "UIViewController+HideBottomBar.h"
#import "UILabel+ChangeAppearance.h"
#import "PhotoCommon.h"
#import "macro.h"
#import "QDYHTTPClient.h"


@interface PhotosCollectionViewController ()
@property (nonatomic,strong) UIView *infoView;

@end

@implementation PhotosCollectionViewController

static NSString * const reuseIdentifier = @"photoCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarItem;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"PhotosCollectionCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView.layer setBorderWidth:0.5f];
    [self.collectionView.layer setBorderColor: [THEME_COLOR_LIGHT_GREY_PARENT CGColor]];
   // [self loadData];
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


-(void)configureCell:(PhotoCollectionViewCell *)cell forContent:(WhatsGoingOn *)content atIndexPath:(NSIndexPath *)indexPath
{
    [cell.cellImageView setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    [cell.cellImageView sd_setImageWithURL:[NSURL URLWithString:content.imageUrlString]];
    [cell setBackgroundColor:[UIColor whiteColor]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

-(void)setDatasource:(NSMutableArray *)datasource
{
    _datasource = [datasource mutableCopy];
}

-(void)loadData
{
    [self.collectionView reloadData];
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
            
            [self.view addSubview:self.infoView];
        }
    }
    else
    {
        if (self.infoView)
        {
            [self.infoView removeFromSuperview];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.datasource count];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell *cell =(PhotoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[PhotoCollectionViewCell alloc]init];
    }
   
    //cell.cellWhatsGoingOnItem = [self.myPhotosCollectionDatasource objectAtIndex:indexPath.row];
    WhatsGoingOn * item = [self.datasource objectAtIndex:indexPath.row];
    [self configureCell:cell forContent:item atIndexPath:indexPath];    
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
        WhatsGoingOn *item = [self.datasource objectAtIndex:indexPath.row];
    
        UIStoryboard *whatsNew = [UIStoryboard storyboardWithName:@"WhatsNew" bundle:nil];
        HomeTableViewController *detailPhotoController  = [whatsNew instantiateViewControllerWithIdentifier:@"HomeTableViewController"];
        [detailPhotoController setDataSource:[NSMutableArray arrayWithObject:item]];
        [detailPhotoController setTableStyle:WZ_TABLEVIEWSTYLE_DETAIL];
        [detailPhotoController GetLatestDataList];
        [self pushToViewController:detailPhotoController animated:YES hideBottomBar:YES];
    }
    else
    {
        WhatsGoingOn *item = [self.datasource objectAtIndex:indexPath.row];
        
        UIStoryboard *whatsNew = [UIStoryboard storyboardWithName:@"WhatsNew" bundle:nil];
        HomeTableViewController *detailPhotoController  = [whatsNew instantiateViewControllerWithIdentifier:@"HomeTableViewController"];
        [detailPhotoController setDataSource:[NSMutableArray arrayWithObject:item]];
        [detailPhotoController setTableStyle:WZ_TABLEVIEWSTYLE_DETAIL];
        [detailPhotoController GetLatestDataList];
        [self pushToViewController:detailPhotoController animated:YES hideBottomBar:YES];
        
    }

    
}

#pragma mark - photoDetailViewsControllerDelegate
-(WhatsGoingOn *)photoDetailViewsController:(PhotoDetailViewsController *)detailViews dataAtIndex:(NSInteger)index
{
    if (index <self.datasource.count)
    {
        return self.datasource[index];
    }
    else if ([self.dataSource respondsToSelector:@selector(PhotosCollectionViewController:dataAtIndex:)])
    {
        WhatsGoingOn *item = [self.dataSource PhotosCollectionViewController:self dataAtIndex:index];
        return item;
    }
    return nil;
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
