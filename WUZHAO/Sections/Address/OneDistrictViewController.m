//
//  OneDistrictViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/8/31.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "OneDistrictViewController.h"
#import "POIItemCollectionViewCell.h"
#import "PhotosCollectionViewController.h"
#import "CommonContainerViewController.h"
#import "QDYHTTPClient.h"
#import "SVProgressHUD.h"

#import "macro.h"
#import "POI.h"

@interface OneDistrictViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate,CommonContainerViewControllerDelegate>
@property (nonatomic, strong) IBOutlet UICollectionView *POIItemsCollectionView;
@property (nonatomic, strong) POIItemCollectionViewCell *prototypeCell;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *POIItemsCollectionViewHeight;
@property (nonatomic, strong) CommonContainerViewController *commonContainerViewController;
@property (nonatomic, strong) PhotosCollectionViewController *photosCollectionViewController;
@property (nonatomic, strong) NSArray *POIItemsList;
@property (nonatomic, strong) NSMutableArray *photosList;

@end

@implementation OneDistrictViewController
@synthesize POIItemsList = _POIItemsList;
@synthesize photosList = _photosList;
- (void)viewDidLoad {
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    self.shouldRefreshData = YES;
    [super viewDidLoad];
    [self setupRightBarRefreshAiv];
    [self setTitle:self.district.districtName];
    [self initPOIItemsCollectionView];
    [self getLatestData];

    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setPOIItemsList:(NSArray *)POIItemsList
{
    _POIItemsList = POIItemsList;
    /*
    [self.POIItemsCollectionView reloadData];
    [self.POIItemsCollectionView setNeedsLayout];
    [self.POIItemsCollectionView layoutIfNeeded];
    [self.POIItemsCollectionViewHeight setConstant:self.POIItemsCollectionView.contentSize.height];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];*/

}
-(POIItemCollectionViewCell *)prototypeCell
{
    if (!_prototypeCell)
    {
        UINib *POIItemCell = [UINib nibWithNibName:@"POIItemCollectionViewCell" bundle:nil];
        NSArray *nibItem = [POIItemCell instantiateWithOwner:self options:nil];
        _prototypeCell = [nibItem lastObject];
        
    }
    return _prototypeCell;
}

-(void)setPhotosList:(NSMutableArray *)photosList
{
    _photosList = photosList;
    if (self.photosCollectionViewController)
    {
        self.photosCollectionViewController.datasource = _photosList;
        [self.photosCollectionViewController loadData];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedContainer"])
    {
        self.commonContainerViewController = segue.destinationViewController;
        self.commonContainerViewController.delegate = self;
        self.commonContainerViewController.ChildrenName = @[@"Photos"];
        self.commonContainerViewController.isInteractive = NO;
    }
}

-(void)initPOIItemsCollectionView
{
    [self.POIItemsCollectionView registerNib:[UINib nibWithNibName:@"POIItemCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"POIItem"];
    self.POIItemsCollectionView.dataSource = self;
    self.POIItemsCollectionView.delegate = self;
}

#pragma mark - collectionview delegate and datasource
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    POI *poi = self.POIItemsList[indexPath.item];
    NSString *POIName = poi.name;
    [self.prototypeCell setPOIName:POIName];
    CGSize size =  CGSizeMake(MAX(self.prototypeCell.POINameLabel.frame.size.width, 64), MAX(self.prototypeCell.POINameLabel.frame.size.height, 24));
    return size;*/
    return CGSizeMake(collectionView.frame.size.width, 0);
   // return CGSizeMake((collectionView.frame.size.width-32)/3, 22);
}


-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 8.0f;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 4.0f;
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section

{
    return UIEdgeInsetsMake(12, 8, 8, 12);
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.POIItemsList.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    POIItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"POIItem" forIndexPath:indexPath];
    if (!cell)
    {
        cell = [[POIItemCollectionViewCell alloc]init];
    }
    POI *poi = self.POIItemsList[indexPath.item];
    
    [cell setPOIName:poi.name];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    POI *poi = self.POIItemsList[indexPath.item];
    [self goToPOIPhotoListWithPoi:poi];
}
#pragma mark - commoncontainerView delegate
-(void)beginLoadChildController:(UIViewController *)childController
{
    if ([childController isKindOfClass:[PhotosCollectionViewController class]])
    {
        self.photosCollectionViewController = (PhotosCollectionViewController *)childController;
        self.photosCollectionViewController.datasource = self.photosList;
        [self.photosCollectionViewController.collectionView setBackgroundColor:[UIColor whiteColor]];
        [self.photosCollectionViewController loadData];
    }
    
}
-(void)finishLoadChildController:(UIViewController *)childController
{
    
    
}

#pragma mark - scrollview delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

#pragma mark - control the model
-(void)getLatestData
{
    if (!self.shouldRefreshData)
    {
        return;
    }
    self.shouldRefreshData = NO;
    [self starRightBartAiv];
    [[QDYHTTPClient sharedInstance]GetDistrictInfoWithDistrictName:self.district.districtName type:self.district.type whenComplete:^(NSDictionary *result) {
        self.shouldRefreshData = YES;
        if ([result objectForKey:@"data"])
        {
            self.district = [result objectForKey:@"data"];
            self.POIItemsList = self.district.POIs;
            self.photosList = self.district.photosList;
            
        }
        else if ([result objectForKey:@"error"])
        {
            [SVProgressHUD showErrorWithStatus:[result objectForKey:@"error"]];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"请求失败"];
        }
        [self stopRightBarAiv];
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
