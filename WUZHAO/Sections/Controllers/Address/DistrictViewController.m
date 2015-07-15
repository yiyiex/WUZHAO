//
//  DistrictViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/7/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "DistrictViewController.h"
#import "DistrictCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "PhotoCommon.h"

#import "AddressViewController.h"
#import "UIViewController+HideBottomBar.h"
#import "UIView+ChangeAppearance.h"
#import "macro.h"

@interface DistrictViewController ()
@property (nonatomic, strong) UIImageView *defaultImageView;
@property (nonatomic, strong) UIImage *defaultImage;

@end

@implementation DistrictViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    // Do any additional setup after loading the view.
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (!self.collectionView.blurCoverView)
    {
        if (![self.data.defaultImageUrl isEqualToString:@""])
        {
            UIImageView *imageView = [[UIImageView alloc]init];
            [imageView sd_setImageWithURL:[NSURL URLWithString:self.data.defaultImageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [self.collectionView addBlurCoverWithImage:image];
                [self.defaultImageView removeFromSuperview];
                UILabel *districtNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, CHBlurCoverViewHeight - 50, WZ_APP_SIZE.width - 16, 40)];
                [districtNameLabel setText:self.data.districtName];
                [districtNameLabel setTextColor:[UIColor whiteColor]];
                [districtNameLabel setFont: WZ_FONT_HIRAGINO_MID_SIZE];
                [districtNameLabel setTextAlignment:NSTextAlignmentLeft];
                [self.collectionView addSubview:districtNameLabel];
            }];
        }
        else
        {
            [self.collectionView addBlurCoverWithImage:self.defaultImage];
            UILabel *districtNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, CHBlurCoverViewHeight - 50, WZ_APP_SIZE.width - 16, 40)];
            [districtNameLabel setText:self.data.districtName];
            [districtNameLabel setTextColor:[UIColor whiteColor]];
            [districtNameLabel setFont: WZ_FONT_HIRAGINO_MID_SIZE];
            [districtNameLabel setTextAlignment:NSTextAlignmentLeft];
            [self.collectionView addSubview:districtNameLabel];
            
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)dealloc
{
    [self.collectionView removeBlurCoverView];
}

-(void)initView
{
    [self.view addSubview:self.collectionView];
    
    //back button
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(8, 24, 35, 35)];
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(6, 8, 19, 19)];
    [view addSubview:backButton];
    [view setBackgroundColor:THEME_COLOR_DARK_GREY_PARENT];
    UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backButtonClick:)];
    [view addGestureRecognizer:tapgesture];
    [view setUserInteractionEnabled:YES];
    [view setRoundAppearance];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:view];
    
    //backitem
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarItem;
    
    //default Image
    UIView *statusBarBackGroundView = [[UIView alloc]initWithFrame:CGRectMake(0, -20, WZ_APP_SIZE.width, 20)];
    statusBarBackGroundView.backgroundColor = THEME_COLOR_DARK;
    [self.view addSubview:statusBarBackGroundView];
    [self.view sendSubviewToBack:statusBarBackGroundView];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    _defaultImage = [PhotoCommon createImageWithColor:THEME_COLOR_DARK size:CGSizeMake(WZ_APP_SIZE.width, CHBlurCoverViewHeight)];
    self.defaultImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, WZ_APP_SIZE.width, CHBlurCoverViewHeight)];
    [self.defaultImageView setImage:_defaultImage];
    [self.collectionView addSubview:self.defaultImageView];
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        CGFloat colum = 2.0, spacing = 8.0;
        CGFloat value = floorf((CGRectGetWidth(self.view.bounds) - (colum + 1) * spacing) / colum);
        
        UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize                     = CGSizeMake(value, value);
        layout.sectionInset                 = UIEdgeInsetsMake(8, 8, 0, 8);
        layout.minimumInteritemSpacing      = spacing;
        layout.minimumLineSpacing           = spacing;
        layout.headerReferenceSize = CGSizeMake(CGRectGetWidth(self.view.bounds), CHBlurCoverViewHeight);
        
        CGRect rect = self.view.frame;
        _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.allowsMultipleSelection = NO;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.alwaysBounceVertical = YES;
        [_collectionView registerClass:[DistrictCollectionViewCell class] forCellWithReuseIdentifier:@"DistrictCell"];
        
    }
    return _collectionView;
}
#pragma mark - collection delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.data.POIs.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DistrictCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DistrictCell" forIndexPath:indexPath];
    POI *poi = self.data.POIs[indexPath.item];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:poi.defaultImageUrl]];
    cell.name.text = poi.name;
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    POI *poi = self.data.POIs[indexPath.item];
    [self goToPOIPageWithPOIInfo:poi];
}
-(void)loadData
{
    if (self.data)
    {
        [self.collectionView reloadData];
        //[self.collectionView.blurCoverView setImageWithUrl:self.data.defaultImageUrl];
    }
}

#pragma mark - method
-(void)goToPOIPageWithPOIInfo:(POI *)poi
{
    UIStoryboard *addressStoryboard = [UIStoryboard storyboardWithName:@"Address" bundle:nil];
    AddressViewController *addressViewCon = [addressStoryboard instantiateViewControllerWithIdentifier:@"addressPage"];
    //[self hidesBottomBarWhenPushed];
    addressViewCon.poiId = poi.poiId;
    addressViewCon.poiName = poi.name;
    [self pushToViewController:addressViewCon animated:YES hideBottomBar:YES];
}

-(void)backButtonClick:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
