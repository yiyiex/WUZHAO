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
#import "AddressPhotosCollectionViewController.h"
#import "UIViewController+Basic.h"


#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "MKMapView+MapViewUtil.h"
#import <MapKit/MapKit.h>
#import "POIAnnotation.h"

#import "SVProgressHUD.h"
#import "QDYHTTPClient.h"
#import "POISearchAPI.h"
#import "macro.h"

#define SEGUEFIRST @"photoCollectionViewSegue"
#define SEGUESECOND @"sharedPeopleTableViewSegue"

@interface AddressViewController () <CommonContainerViewControllerDelegate,MAMapViewDelegate,MKMapViewDelegate,AMapSearchDelegate>

@property (nonatomic, strong) MKMapView *addressMapView;
@property (nonatomic, strong) MKPointAnnotation *annotation;
@property (nonatomic, strong) UIButton *mapViewShowButton;

@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic) AMapSearchType searchType;

@property (nonatomic, strong) IBOutlet CommonContainerViewController *containerViewController;
@property (nonatomic,strong) AddressPhotosCollectionViewController *photoCollectionViewCon;
@end

@implementation AddressViewController
@synthesize search = _search;
@synthesize searchType = _searchType;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;

    [self setBackItem];
    [self initMapView];
    [self initAnnocations];
    //[self.containerViewController swapViewControllersWithIdentifier:SEGUEFIRST];
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
        self.containerViewController.ChildrenName = @[SEGUEFIRST];
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
    self.addressMapView = [[MKMapView alloc]initWithFrame:CGRectMake(0,64, WZ_APP_SIZE.width, 110)];
    self.addressMapView.delegate = self;

    //self.addressMapView.showsUserLocation = YES;
    //self.addressMapView.userTrackingMode = MAUserTrackingModeFollow;
    self.mapViewShowButton = [[UIButton alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width - 28, 174,28, 28)];
    [self.mapViewShowButton setImage:[UIImage imageNamed:@"map_arrow_down"] forState:UIControlStateNormal];
    [self.mapViewShowButton setImage:[UIImage imageNamed:@"map_arrow_up"] forState:UIControlStateHighlighted];
    [self.mapViewShowButton.layer setCornerRadius:2.0f];
    [self.mapViewShowButton.layer setMasksToBounds:YES];
    [self.mapViewShowButton addTarget:self action:@selector(expandMapView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addressMapView];
    [self.view addSubview:self.mapViewShowButton];
    
    
}
-(void)initAnnocations
{
    self.annotation = [[MKPointAnnotation alloc]init];
    if (self.poiLocation)
    {
        self.annotation.coordinate = CLLocationCoordinate2DMake([self.poiLocation[0] floatValue], [self.poiLocation[1] floatValue]);
        self.annotation.title = self.poiName;
        [self addAnnotationToMapView:self.annotation];
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
                [self addAnnotationToMapView:self.annotation];
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
-(void)addAnnotationToMapView:(MKPointAnnotation *)annotation
{
    [self.addressMapView addAnnotation:annotation];
    [self.addressMapView setCenterCoordinate:annotation.coordinate zoomLevel:10 animated:YES];
    
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

#pragma mark - MKMapViewDelegate
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIdentifier = @"pointReuseIdentifier";
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.addressMapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIdentifier];
        if (annotationView == nil)
        {
            annotationView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:pointReuseIdentifier];
        }
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
        annotationView.draggable = YES;
        annotationView.pinColor = MKPinAnnotationColorGreen;
        return annotationView;
    }
    return nil;
}

#pragma mark - commoncontainerView delegate
-(void)beginLoadChildController:(UIViewController *)childController
{
    if ([childController isKindOfClass: [AddressPhotosCollectionViewController class]])
    {
        self.photoCollectionViewCon = (AddressPhotosCollectionViewController *)childController;
        
        [self getLatestData];
        
    }

}
-(void)finishLoadChildController:(UIViewController *)childController
{
    if ([childController isKindOfClass: [AddressPhotosCollectionViewController class]])
    {
        
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

-(void)getLatestData
{
    if (self.poiName)
    {
        [self.navigationItem setTitle:self.poiName];
    }
    if (self.photoCollectionViewCon)
    {
        self.photoCollectionViewCon.poi.poiId = self.poiId;
        self.photoCollectionViewCon.poi.name = self.poiName;
        if (self.recommendFirstPostId >0)
        {
            self.photoCollectionViewCon.recommendFirstPostId = self.recommendFirstPostId;
        }
        if (self.userId>0)
        {
            self.photoCollectionViewCon.userId = self.userId;
        }
        [self.photoCollectionViewCon getLatestData];
    }

}

#pragma mark - button action
-(void)expandMapView:(id)sender
{
    if (self.addressMapView.frame.size.height == self.view.frame.size.height)
    {
        [UIView animateWithDuration:0.3 animations:^{
            [self.addressMapView setFrame:CGRectMake(0, 64, WZ_APP_SIZE.width, 110)];
            [self.mapViewShowButton setFrame:CGRectMake(WZ_APP_SIZE.width - 28, 174, 28, 28)];
        } completion:^(BOOL finished) {
            [self.mapViewShowButton setHighlighted:NO];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^{
            [self.addressMapView setFrame:CGRectMake(0, 64, WZ_APP_SIZE.width, self.view.frame.size.height)];
            [self.mapViewShowButton setFrame:CGRectMake(WZ_APP_SIZE.width - 28, self.view.frame.size.height - 28, 28, 28)];
        } completion:^(BOOL finished) {
            [self.mapViewShowButton setHighlighted:YES];
        }];
    }
    
}
@end
