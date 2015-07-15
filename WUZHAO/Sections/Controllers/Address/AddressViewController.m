//
//  AddressViewController.m
//  WUZHAO
//
//  Created by yiyi on 15-1-4.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "AddressViewController.h"
#import "CommonContainerViewController.h"
#import "PhotosCollectionViewController.h"


#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "POIAnnotation.h"

#import "SVProgressHUD.h"
#import "QDYHTTPClient.h"
#import "POISearchAPI.h"
#import "macro.h"

#define SEGUEFIRST @"photoCollectionViewSegue"
#define SEGUESECOND @"sharedPeopleTableViewSegue"

@interface AddressViewController () <CommonContainerViewControllerDelegate,MAMapViewDelegate,AMapSearchDelegate>

@property (nonatomic, strong) MAMapView *addressMapView;
@property (nonatomic, strong) MAPointAnnotation *annotation;
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic) AMapSearchType searchType;

@property (nonatomic, strong) IBOutlet CommonContainerViewController *containerViewController;
@property (nonatomic,strong) PhotosCollectionViewController *photoCollectionViewCon;

@property (nonatomic) BOOL shouldRefresh;
@end

@implementation AddressViewController
@synthesize search = _search;
@synthesize searchType = _searchType;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    if ([self.view respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self.view setLayoutMargins:UIEdgeInsetsZero];
    }
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarItem;
    
    self.shouldRefresh = true;
    [self initMapView];
    [self initAnnocations];
    [self.containerViewController swapViewControllersWithIdentifier:SEGUEFIRST];
    [self getLatestAddressPhoto];
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
   // [self clearMapView];
}
-(void)dealloc
{
    [self clearMapView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedContainer"])
    {
        
        self.containerViewController = (CommonContainerViewController *)segue.destinationViewController;
        self.containerViewController.delegate = self;
        self.containerViewController.ChildrenName = @[SEGUEFIRST,SEGUESECOND];
        
    }
}

-(void)setPoiName:(NSString *)poiName
{
    [self.navigationItem setTitle:poiName];
    _poiName = poiName;
}

-(CommonContainerViewController *)containerViewController
{
    if (!_containerViewController)
    {
        _containerViewController = [[CommonContainerViewController alloc]initWithChildren:@[SEGUEFIRST,SEGUESECOND]];
        
        _containerViewController.delegate = self;
    }
    return _containerViewController;
}

-(void)initMapView
{
    [MAMapServices sharedServices].apiKey = GAODE_SDK_KEY;
    self.search.delegate = self;
    self.addressMapView = [[MAMapView alloc]initWithFrame:CGRectMake(0,64, WZ_APP_SIZE.width, 110)];
    self.addressMapView.delegate = self;
    self.addressMapView.showsScale = NO;
    self.addressMapView.showsCompass = NO;

    self.addressMapView.logoCenter = CGPointMake(CGRectGetWidth(self.addressMapView.frame)-28, CGRectGetHeight(self.addressMapView.frame)-8);
    
    self.addressMapView.showsUserLocation = YES;
    self.addressMapView.userTrackingMode = MAUserTrackingModeFollow;
    [self.view addSubview:self.addressMapView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 174, WZ_APP_SIZE.width, 30)];
    titleLabel.text = @"  最新";
    [titleLabel setFont:WZ_FONT_COMMON_BOLD_SIZE];
    [titleLabel setTextColor:THEME_COLOR_LIGHT_GREY];
    [self.view addSubview:titleLabel];
}
-(void)initAnnocations
{
    self.annotation = [[MAPointAnnotation alloc]init];
    if (self.poiLocation)
    {
        self.annotation.coordinate = CLLocationCoordinate2DMake([self.poiLocation[0] floatValue], [self.poiLocation[1] floatValue]);
        self.annotation.title = self.poiName;
        [self.addressMapView addAnnotation:self.annotation];
        self.addressMapView.centerCoordinate = self.annotation.coordinate;
        
        [self.addressMapView setZoomLevel:14.2 animated:YES];
    }
    else if (self.poiId)
    {
        [[POISearchAPI sharedInstance]getPOILocationWithPoiId:self.poiId whenComplete:^(NSDictionary *reuslt) {
            if ([reuslt objectForKey:@"data"])
            {
                NSDictionary *data = [reuslt objectForKey:@"data"];
                NSString *locationString = [data objectForKey:@"locationString"];
                NSArray *location = [locationString componentsSeparatedByString:@","];
                self.annotation.coordinate = CLLocationCoordinate2DMake([location[0] floatValue], [location[1] floatValue]);
                self.annotation.title = self.poiName;
                [self.addressMapView addAnnotation:self.annotation];
                self.addressMapView.centerCoordinate = self.annotation.coordinate;
                
                [self.addressMapView setZoomLevel:14.2 animated:YES];
                
            }
            else if ([reuslt objectForKey:@"error"])
            {
                [SVProgressHUD showErrorWithStatus:[reuslt objectForKey:@"error"]];
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:@"地址定位失败"];
            }
        }];
    }
    //self.annotation.coordinate = CLLocationCoordinate2DMake(29.797155 , 119.69141);
    
    
}
-(void)clearMapView
{
    self.search.delegate = nil;
    self.addressMapView.showsUserLocation = NO;
    [self.addressMapView removeAnnotations:self.addressMapView.annotations];
    [self.addressMapView removeOverlays:self.addressMapView.overlays];
    self.addressMapView.delegate = nil;
}
#pragma mark - AMapSearchDelegate

/* POI 搜索回调. */
- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)respons
{
    if (request.searchType != self.searchType)
    {
        return;
    }
    
    if (respons.pois.count == 0)
    {
        return;
    }
    
    NSMutableArray *poiAnnotations = [NSMutableArray arrayWithCapacity:respons.pois.count];
    
    [respons.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        
        [poiAnnotations addObject:[[POIAnnotation alloc] initWithPOI:obj]];
        
    }];
    
    /* 将结果以annotation的形式加载到地图上. */
    [self.addressMapView addAnnotations:poiAnnotations];
    
    /* 如果只有一个结果，设置其为中心点. */
    if (poiAnnotations.count == 1)
    {
        self.addressMapView.centerCoordinate = [poiAnnotations[0] coordinate];
    }
    /* 如果有多个结果, 设置地图使所有的annotation都可见. */
    else
    {
        [self.addressMapView showAnnotations:poiAnnotations animated:NO];
    }
}

#pragma mark - MAMapViewDelegate
-(MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIdentifier = @"pointReuseIdentifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView *)[self.addressMapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIdentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:pointReuseIdentifier];
        }
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
        annotationView.draggable = YES;
        annotationView.pinColor = MAPinAnnotationColorGreen;
        return annotationView;
    }
    return nil;
}

#pragma mark - commoncontainerView delegate
-(void)finishLoadChildController:(UIViewController *)childController
{
    if ([childController isKindOfClass: [PhotosCollectionViewController class]])
    {
        self.photoCollectionViewCon = (PhotosCollectionViewController *)childController;
        [self.photoCollectionViewCon.collectionView setBackgroundColor:[UIColor whiteColor]];
        [self setPhotoCollectionData];
        
    }
}

-(void)setPhotoCollectionData
{
    [self.photoCollectionViewCon setDatasource:self.photoCollectionDatasource];
    [self.photoCollectionViewCon.collectionView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)getLatestAddressPhoto
{
    if (self.poiId <=0)
    {
        if (self.photoCollectionDatasource)
        {
            [self setPhotoCollectionData];
            return;
        }
        else
        {
            return;
        }
    }
    if (self.poiName)
    {
        [self.navigationItem setTitle:self.poiName];
    }
    self.shouldRefresh = false;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[QDYHTTPClient sharedInstance]GetPOIInfoWithPoiId:self.poiId whenComplete:^(NSDictionary *returnData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([returnData objectForKey:@"data"])
                {
                    self.photoCollectionDatasource = [[returnData objectForKey:@"data"]mutableCopy];
                    [self setPhotoCollectionData];
                    //[self.photoCollectionViewCon loadData];
                }
                else if ([returnData objectForKey:@"error"])
                {
                    
                    
                }
                self.shouldRefresh = true;
            });

        }];
    });

}

#pragma mark - Utility

/* 根据ID来搜索POI. */
- (void)searchPoiByID:(NSString *)poiId
{
    AMapPlaceSearchRequest *request = [[AMapPlaceSearchRequest alloc] init];
    //    B000A80WBJ    hotel
    //    B00141IEZK    dining
    //    B000A876EH    cinema
    //    B000A7O1CU    scenic
    request.searchType          = AMapSearchType_PlaceID;
    request.uid                 = poiId;
    request.requireExtension    = YES;
    
    [self.search AMapPlaceSearch:request];
    
}

/* 根据关键字来搜索POI. */
- (void)searchPoiByKeyword
{
    AMapPlaceSearchRequest *request = [[AMapPlaceSearchRequest alloc] init];
    
    request.searchType          = AMapSearchType_PlaceKeyword;
    request.keywords            = @"肯德基";
    request.city                = @[@"010"];
    request.requireExtension    = YES;
    [self.search AMapPlaceSearch:request];
}

/* 根据中心点坐标来搜周边的POI. */
- (void)searchPoiByCenterCoordinate
{
    AMapPlaceSearchRequest *request = [[AMapPlaceSearchRequest alloc] init];
    
    request.searchType          = AMapSearchType_PlaceAround;
    request.location            = [AMapGeoPoint locationWithLatitude:39.990459 longitude:116.481476];
    request.keywords            = @"餐饮";
    /* 按照距离排序. */
    request.sortrule            = 1;
    request.requireExtension    = YES;
    
    /* 添加搜索结果过滤 */
    AMapPlaceSearchFilter *filter = [[AMapPlaceSearchFilter alloc] init];
    filter.costFilter = @[@"100", @"200"];
    filter.requireFilter = AMapRequireGroupbuy;
    request.searchFilter = filter;
    
    [self.search AMapPlaceSearch:request];
}

/* 在指定的范围内搜索POI. */
- (void)searchPoiByPolygon
{
    NSArray *points = [NSArray arrayWithObjects:
                       [AMapGeoPoint locationWithLatitude:39.990459 longitude:116.481476],
                       [AMapGeoPoint locationWithLatitude:39.890459 longitude:116.581476],
                       nil];
    AMapGeoPolygon *polygon = [AMapGeoPolygon polygonWithPoints:points];
    
    AMapPlaceSearchRequest *request = [[AMapPlaceSearchRequest alloc] init];
    
    request.searchType          = AMapSearchType_PlacePolygon;
    request.polygon             = polygon;
    request.keywords            = @"Apple";
    request.requireExtension    = YES;
    
    [self.search AMapPlaceSearch:request];
}
@end
