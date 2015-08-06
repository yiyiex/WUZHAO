//
//  FootPrintCollectionViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/7/21.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "FootPrintCollectionViewController.h"
#import "FootPrintCollectionViewCell.h"
#import "FootPrint.h"
#import "macro.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+ChangeAppearance.h"

#import "SWSnapshotStackView.h"

#import "HomeTableViewController.h"
#import "AddressMarkCollectionView.h"
#import "AddressMarkCollectionViewCell.h"
#import "AddressViewController.h"
#import "PhotosCollectionViewController.h"
#import "UIViewController+Basic.h"
#import "SVProgressHUD.h"

#import "WhatsGoingOn.h"

#import "POISearchAPI.h"

@interface FootPrintCollectionViewController ()

@property (nonatomic,strong) UICollectionViewFlowLayout *layout;

@end

@implementation FootPrintCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register cell classes
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    self.collectionView.collectionViewLayout = self.layout;
    [self.collectionView registerClass:[FootPrintCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UICollectionViewFlowLayout *)layout
{
    if (!_layout)
    {
        _layout = [[UICollectionViewFlowLayout alloc]init];
        _layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _layout.itemSize = CGSizeMake((WZ_APP_SIZE.width -24)/2,(WZ_APP_SIZE.width -24)/2 + 24);
        _layout.minimumInteritemSpacing = 4;
        _layout.minimumLineSpacing = 8;
        _layout.sectionInset = UIEdgeInsetsMake(8, 8, 0, 8);
    }
    return _layout;

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
    [self.collectionView reloadData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)ConfigureCell:(FootPrintCollectionViewCell *)cell withAddressPhotos:(AddressPhotos *)addressPhotos
{
    cell.addressNameLabel.text = addressPhotos.poi.name;
    [cell setPhotoNumber:addressPhotos.photoNum];
    WhatsGoingOn *item = addressPhotos.photoList[0] ;
    [cell.placeHolderImageView setHidden:NO];
    [cell.shotStackView setHidden:YES];
    [cell.placeHolderImageView sd_setImageWithURL:[NSURL URLWithString:item.imageUrlString] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [cell.shotStackView setImage:image];
        [cell.placeHolderImageView setHidden:YES];
        [cell.shotStackView setHidden:NO];
        UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageViewTaped:)];
        [cell.shotStackView addGestureRecognizer:tapgesture];
        [cell.shotStackView setUserInteractionEnabled:YES];
    }];
    UITapGestureRecognizer *photoNumLabelTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(photoNumLabelClick:)];
    [cell.photoNumLabel addGestureRecognizer:photoNumLabelTap];
    [cell.photoNumLabel setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *addressNameLabelTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addressLabelClick:)];
    [cell.addressNameLabel addGestureRecognizer:addressNameLabelTap];
    [cell.addressNameLabel setUserInteractionEnabled:YES];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.datasource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FootPrintCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    AddressPhotos *content = [self dataAtIndexPath:indexPath];
    [self ConfigureCell:cell withAddressPhotos:content];
    return cell;
}


#pragma mark <UICollectionViewDelegate>

-(AddressPhotos *)dataAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.datasource objectAtIndex:indexPath.item];
}
#pragma mark - gesture and action
-(void)imageViewTaped:(UIGestureRecognizer *)gesture
{
    FootPrintCollectionViewCell *cell = (FootPrintCollectionViewCell *)gesture.view.superview;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    AddressPhotos *data = (AddressPhotos *)[self dataAtIndexPath:indexPath];
    [self goToPOIPhotoListWithPoi:data.poi];
    
}
-(void)addressLabelClick:(UIGestureRecognizer *)gesture
{
    FootPrintCollectionViewCell *cell = (FootPrintCollectionViewCell *)gesture.view.superview;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    AddressPhotos *data = (AddressPhotos *)[self dataAtIndexPath:indexPath];
    [self goToPOIPhotoListWithPoi:data.poi];
    
}
-(void)photoNumLabelClick:(UIGestureRecognizer *)gesture
{
    FootPrintCollectionViewCell *cell = (FootPrintCollectionViewCell *)gesture.view.superview;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    AddressPhotos *data = (AddressPhotos *)[self dataAtIndexPath:indexPath];
    [self goToPOIPhotoListWithPoi:data.poi];
    
}
-(void)goToPOIPhotoListWithPoi:(POI *)poi
{
    UIStoryboard *addressStoryboard = [UIStoryboard storyboardWithName:@"Address" bundle:nil];
    AddressViewController *addressViewCon = [addressStoryboard instantiateViewControllerWithIdentifier:@"addressPage"];
    addressViewCon.poiId = poi.poiId;
    addressViewCon.poiName = poi.name;
    addressViewCon.poiLocation = poi.locationArray;
    addressViewCon.userId = self.currentUser.UserID;
    [addressViewCon getLatestData];
    [self pushToViewController:addressViewCon animated:YES hideBottomBar:YES];
    
   
}
-(void)gotoPOIPageWithItem:(WhatsGoingOn *)item
{
    UIStoryboard *whatsNew = [UIStoryboard storyboardWithName:@"WhatsNew" bundle:nil];
    HomeTableViewController *detailPhotoController  = [whatsNew instantiateViewControllerWithIdentifier:@"HomeTableViewController"];
    [detailPhotoController setDatasource:[NSMutableArray arrayWithObject:item]];
    [detailPhotoController setTableStyle:WZ_TABLEVIEWSTYLE_DETAIL];
    [self pushToViewController:detailPhotoController animated:YES hideBottomBar:YES];
}


@end
