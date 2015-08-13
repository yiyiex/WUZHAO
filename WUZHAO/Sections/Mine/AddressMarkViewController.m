//
//  AddressMarkViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/7/6.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//
#import "macro.h"
#import "AddressPhotos.h"
#import "AddressMarkViewController.h"
#import "AddressMarkAnnotationView.h"
#import "AddressMarkAnnotationView2.h"
#import "AddressMarkAnnotation.h"
#import "UIView+ChangeAppearance.h"

#import "UIImageView+WebCache.h"
#import "UIImage+Resize.h"
#import "AddressMarkCollectionViewCell.h"
#import "AddressMarkCollectionView.h"

#import "UIViewController+Basic.h"
#import "HomeTableViewController.h"


#import "UMSocialScreenShoter.h"
#import "UMSocialSnsService.h"
#import "UMSocial.h"



#import "ClusterMapView.h"

static CGFloat kDEFAULTCLUSTERSIZE = 0.1;

@interface AddressMarkViewController ()<MKMapViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) ClusterMapView *mapView;
@property (nonatomic, strong) NSMutableArray *annotations;

@property (nonatomic, strong) AddressMarkCollectionView *annotationsPhotosList;
@property (nonatomic, strong) NSArray *annotationsPhotosDatasource;

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIButton *shareButton;

@end

@implementation AddressMarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initMapView];
    [self setNavigation];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
     [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSMutableArray *)annotations
{
    if (!_annotations)
    {
        _annotations = [[NSMutableArray alloc]init];

    }
    return _annotations;
}
-(AddressMarkCollectionView *)annotationsPhotosList
{
    if (!_annotationsPhotosList)
    {
        _annotationsPhotosList = [[AddressMarkCollectionView alloc]initWithFrame:CGRectMake(20, 60, WZ_APP_SIZE.width - 40, WZ_APP_SIZE.height - 120)];
        [_annotationsPhotosList setDatasource:self];
        [_annotationsPhotosList setDelegate:self];
        [self.view addSubview:_annotationsPhotosList];
    }
    return _annotationsPhotosList;
}

-(void)setNavigation
{
    //back button
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(8, 24, 35, 35)];
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(6, 8, 19, 19)];
    [view addSubview:backButton];
    [view setBackgroundColor:THEME_COLOR_DARK_GREY_PARENT];
    UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backButtonClick:)];
    [view addGestureRecognizer:tapgesture];
    [view setUserInteractionEnabled:YES];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:view];
    self.backView = view;
    [view setRoundAppearance];
    [self.view bringSubviewToFront:backButton];
    
    //share button
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width - 44, 26, 35, 35)];
    [shareButton setImage:[UIImage imageNamed:@"share_camera"] forState:UIControlStateNormal];
    //[shareButton setTitle:@"分享" forState:UIControlStateNormal];
    [shareButton setBackgroundColor:THEME_COLOR_DARK_GREY_PARENT];
    [shareButton.titleLabel setTextColor:[UIColor whiteColor]];
    [shareButton.titleLabel setFont:WZ_FONT_LARGE_BOLD_SIZE];
    [shareButton setRoundCornerAppearance];
    [shareButton addTarget:self action:@selector(shareToSNS) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];
    self.shareButton = shareButton;
    if (self.userInfo.UserID == [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"])
    {
        [self.shareButton setHidden:NO];
    }
    else
    {
        [self.shareButton setHidden:YES];
    }
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarItem;
}

-(void)initMapView
{
   // [MAMapServices sharedServices].apiKey = GAODE_SDK_KEY;
   // self.search.delegate = self;
    self.mapView = [[ClusterMapView alloc]initWithFrame:self.view.frame];
    self.mapView.delegate = self;
    //self.mapView.showsScale = NO;
    //self.mapView.showsCompass = NO;
    self.mapView.clusterSize = kDEFAULTCLUSTERSIZE;
    
   // [self.mapView setZoomLevel:1.4];
    
   // self.mapView.logoCenter = CGPointMake(CGRectGetWidth(self.mapView.frame)-28, CGRectGetHeight(self.mapView.frame)-8);
    
    self.mapView.showsUserLocation = NO;
    [self.view addSubview:self.mapView];
}
-(void)addAnnotations
{
    __block AddressMarkAnnotation *centerAnnotation;
    [self.mapView removeAnnotations:self.annotations];
    [self.annotations removeAllObjects];
    [self.locations enumerateObjectsUsingBlock:^(AddressPhotos *obj, NSUInteger idx, BOOL *stop) {
        if (obj.poi.locationArray.count == 2)
        {
            
            AddressMarkAnnotation *annotation = [[AddressMarkAnnotation alloc]init];
            annotation.coordinate = CLLocationCoordinate2DMake([obj.poi.locationArray[0] floatValue], [obj.poi.locationArray[1] floatValue]);
            [self.annotations addObject:annotation];
            annotation.poi = obj.poi;
            annotation.photoList = obj.photoList;
            annotation.photoNum = obj.photoNum;
            if (idx == 0)
            {
                centerAnnotation = annotation;
            }
            else
            {
                if (annotation.photoNum >centerAnnotation.photoNum)
                {
                    centerAnnotation = annotation;
                }
            }
        }
        
    }];
    [self.mapView addAnnotations:self.annotations];
    [self.mapView setCenterCoordinate:centerAnnotation.coordinate animated:YES];
}

#pragma mark - MAMapViewDelegate
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation> )annotation
{        static NSString *annotationReuseIdentifier = @"addressMarkAnnotation";
    
    AddressMarkAnnotationView *annotationView = (AddressMarkAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationReuseIdentifier];
    if (annotationView == nil)
    {
        annotationView = [[AddressMarkAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annotationReuseIdentifier];
    }
    if ([annotation isKindOfClass:[ClusterAnnotation class]])
    {
        ClusterAnnotation *clusterAnnotation = (ClusterAnnotation *)annotation;
        NSArray *annotionsInCluster = [clusterAnnotation annotationsInCluster];
        AddressMarkAnnotation *firtstAnnotation = [annotionsInCluster firstObject];
        NSInteger photoNum = 0;
        for (AddressMarkAnnotation *annotation in annotionsInCluster)
        {
            photoNum += annotation.photoNum;
        }
        [annotationView setPhotoNumber:photoNum];
        WhatsGoingOn *item = firtstAnnotation.photoList[0];
        [annotationView setImageWithImageUrl:item.imageUrlString];
        
    }
    
    else if ([annotation isKindOfClass:[AddressMarkAnnotation class]])
    {
        AddressMarkAnnotation *addressAnnotation = (AddressMarkAnnotation *)annotation;

        WhatsGoingOn *item = addressAnnotation.photoList[0];
        [annotationView setPhotoNumber:addressAnnotation.photoNum];
        [annotationView setImageWithImageUrl:item.imageUrlString];
    
    }
    /*
     AddressMarkAnnotationView2 *annotationView = (AddressMarkAnnotationView2 *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationReuseIdentifier];
     if (annotationView == nil)
     {
         annotationView = [[AddressMarkAnnotationView2 alloc]initWithAnnotation:annotation reuseIdentifier:annotationReuseIdentifier];
     }
     if ([annotation isKindOfClass:[ClusterAnnotation class]])
     {
         ClusterAnnotation *clusterAnnotation = (ClusterAnnotation *)annotation;
         NSArray *annotionsInCluster = [clusterAnnotation annotationsInCluster];
         NSInteger photoNum = 0;
         for (AddressMarkAnnotation *annotation in annotionsInCluster)
         {
         photoNum += annotation.photoNum;
         }
         [annotationView setPhotoNumber:photoNum];
     }
     
     else if ([annotation isKindOfClass:[AddressMarkAnnotation class]])
     {
         AddressMarkAnnotation *addressAnnotation = (AddressMarkAnnotation *)annotation;
         [annotationView setPhotoNumber:addressAnnotation.photoNum];
     
     }*/
    return annotationView;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    id<MKAnnotation> annotation = view.annotation;
    [self loadImagesForSelectAnnotations:annotation];
    [mapView deselectAnnotation:annotation animated:YES];
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self.mapView doClustering];
}

#pragma mark - button action
-(void)backButtonClick:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -random coordinates
- (NSArray *)randomCoordinatesGenerator:(int)numberOfCoordinates
{
    MKCoordinateRegion visibleRegion = self.mapView.region;
    visibleRegion.span.latitudeDelta *= 0.8;
    visibleRegion.span.longitudeDelta *= 0.8;
    
    int max = 9999;
    numberOfCoordinates = MAX(0,numberOfCoordinates);
    NSMutableArray *coordinates = [[NSMutableArray alloc] initWithCapacity:numberOfCoordinates];
    for (int i = 0; i < numberOfCoordinates; i++) {
        
        // start with top left corner
        CLLocationDistance longitude = visibleRegion.center.longitude - visibleRegion.span.longitudeDelta/2.0;
        CLLocationDistance latitude  = visibleRegion.center.latitude + visibleRegion.span.latitudeDelta/2.0;
        
        // Get random coordinates within current map rect
        longitude += ((arc4random()%max)/(CGFloat)max) * visibleRegion.span.longitudeDelta;
        latitude  -= ((arc4random()%max)/(CGFloat)max) * visibleRegion.span.latitudeDelta;
        
        CLLocation *loc = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
        [coordinates addObject:loc];
    }
    return  coordinates;
}

#pragma mark - annotations photos
-(void)loadImagesForSelectAnnotations:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[ClusterAnnotation class]])
    {
        self.annotationsPhotosDatasource = [self POIsInClusterAnnotationsView:annotation];
    }
    else if ([annotation isKindOfClass:[AddressMarkAnnotation class]])
    {
        self.annotationsPhotosDatasource = [self POIsInAddressAnnotationView:annotation];
    }
    [self.annotationsPhotosList resizeWithContentCount:self.annotationsPhotosDatasource.count];
    [self.annotationsPhotosList showView];
}

-(NSArray *)POIsInAddressAnnotationView:(AddressMarkAnnotation *)addressAnnotation
{
    NSMutableArray *POIsList = [[NSMutableArray alloc]init];
    for (WhatsGoingOn *item in addressAnnotation.photoList)
    {
        [POIsList addObject:item];
    }
    return POIsList;
}
-(NSArray *)POIsInClusterAnnotationsView:(ClusterAnnotation *)clusterAnnotation
{
    NSMutableArray *POIsList = [[NSMutableArray alloc]init];
    for (AddressMarkAnnotation *annotation in [clusterAnnotation annotationsInCluster])
    {
        [POIsList addObjectsFromArray:[self POIsInAddressAnnotationView:annotation]];
    }
    return POIsList;
}

#pragma mark - collection view delegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _annotationsPhotosDatasource.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AddressMarkCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    WhatsGoingOn *item = self.annotationsPhotosDatasource[indexPath.item];
    [cell.placeHolderImageView setHidden:NO];
    [cell.shotStackView setHidden:YES];
    [cell.placeHolderImageView sd_setImageWithURL:[NSURL URLWithString:item.imageUrlString] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [cell.shotStackView setImage:image];
        [cell.placeHolderImageView setHidden:YES];
        [cell.shotStackView setHidden:NO];
    }];
    return cell;
    
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WhatsGoingOn *item = self.annotationsPhotosDatasource[indexPath.item];
    [self gotoPOIPageWithItem:item];
}

#pragma mark - action
-(void)gotoPOIPageWithItem:(WhatsGoingOn *)item
{
    UIStoryboard *whatsNew = [UIStoryboard storyboardWithName:@"WhatsNew" bundle:nil];
    HomeTableViewController *detailPhotoController  = [whatsNew instantiateViewControllerWithIdentifier:@"HomeTableViewController"];
    [detailPhotoController setDatasource:[NSMutableArray arrayWithObject:item]];
    [detailPhotoController setTableStyle:WZ_TABLEVIEWSTYLE_DETAIL];
    [self pushToViewController:detailPhotoController animated:YES hideBottomBar:YES];
}

#pragma mark - share to SNS
-(void)shareToSNS
{
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
    
    [UMSocialData defaultData].extConfig.qqData.title = @"来自Place的分享";
    [UMSocialData defaultData].extConfig.qzoneData.title = @"来自Place的分享";
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
   // [UMSocialData defaultData].extConfig.qzoneData.url = shareUrl;
    //[UMSocialData defaultData].extConfig.qqData.url = shareUrl;
    [self.backView setHidden:YES];
    [self.shareButton setHidden:YES];
    UIImage *image = [[UMSocialScreenShoterDefault screenShoter] getScreenShot];
    [self.backView setHidden:NO];
    [self.shareButton setHidden:NO];
    [UMSocialSnsService presentSnsIconSheetView:self appKey:@"55a5c86567e58ecd13000507" shareText:@"我的照片地图 | place" shareImage:image shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToWechatFavorite,UMShareToQQ,UMShareToEmail,nil] delegate:nil];
}

@end
