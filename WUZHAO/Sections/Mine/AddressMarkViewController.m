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
#import "AddressMarkAnnotation.h"
#import "UIImageView+WebCache.h"
#import "UIView+ChangeAppearance.h"

@interface AddressMarkViewController ()<AMapSearchDelegate,MAMapViewDelegate>
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) NSMutableArray *annotations;
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
-(void)setNavigation
{
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
    [view setRoundAppearance];
    [self.view bringSubviewToFront:backButton];
}

-(void)initMapView
{
    [MAMapServices sharedServices].apiKey = GAODE_SDK_KEY;
    self.search.delegate = self;
    self.mapView = [[MAMapView alloc]initWithFrame:self.view.frame];
    self.mapView.delegate = self;
    self.mapView.showsScale = NO;
    self.mapView.showsCompass = NO;
    
    [self.mapView setZoomLevel:1.4];
    
    self.mapView.logoCenter = CGPointMake(CGRectGetWidth(self.mapView.frame)-28, CGRectGetHeight(self.mapView.frame)-8);
    
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
    [self.mapView setCenterCoordinate:centerAnnotation.coordinate];
}

#pragma mark - MAMapViewDelegate
-(MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(AddressMarkAnnotation <MAAnnotation> *)annotation
{
    if ([annotation isKindOfClass:[AddressMarkAnnotation class]])
    {
        static NSString *annotationReuseIdentifier = @"addressMarkAnnotation";
        AddressMarkAnnotationView *annotationView = (AddressMarkAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationReuseIdentifier];
        if (annotationView == nil)
        {
            annotationView = [[AddressMarkAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annotationReuseIdentifier];
        }
        WhatsGoingOn *item = annotation.photoList[0];
        [annotationView setPhotoNumber:annotation.photoNum];
        [annotationView setImageWithImageUrl:item.imageUrlString];
        
        return annotationView;
        
    }
    return nil;
}

#pragma mark - button action
-(void)backButtonClick:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
