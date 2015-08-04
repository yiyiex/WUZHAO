//
//  CLLLocationUtility.m
//  WUZHAO
//
//  Created by yiyi on 15/8/2.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "CLLocationUtility.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
@interface CLLocationManager()

@end

@implementation CLLocationUtility

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        self.manager = [[CLLocationManager alloc]init];
        self.manager.delegate = self;
        self.manager.desiredAccuracy = kCLLocationAccuracyBest;
        if ( [self.manager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            [self.manager requestWhenInUseAuthorization];
        }
        
    }
    return self;
}
-(void)getCurrentLocationWithComplete:(void (^)(NSDictionary *))whenComplete
{
    self.completeSearchBlock = whenComplete;
    [self.manager startUpdatingLocation];  
}

#pragma mark - cllocation delegate
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"location failed!");
    NSDictionary *returnDic = @{@"success":@"NO",@"error":error};
    self.completeSearchBlock(returnDic);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"location success");
    NSLog(@"location: %@",locations);
    [self.manager stopUpdatingLocation];
     NSDictionary *returnDic = @{@"success":@"YES",@"location":locations.lastObject};
    self.completeSearchBlock(returnDic);
    
}


#pragma mark - Utility
/*
/* 根据ID来搜索POI. */
/*
- (void)searchPoiByID:(NSString *)poiId
{
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    //    B000A80WBJ    hotel
    //    B00141IEZK    dining
    //    B000A876EH    cinema
    //    B000A7O1CU    scenic
    request.searchType          = AMapSearchType_PlaceID;
    request.uid                 = poiId;
    request.requireExtension    = YES;
    
    [self.search AMapPlaceSearch:request];
    
}*/

/* 根据关键字来搜索POI. */
/*
- (void)searchPoiByKeyword
{
    AMapPlaceSearchRequest *request = [[AMapPlaceSearchRequest alloc] init];
    
    request.searchType          = AMapSearchType_PlaceKeyword;
    request.keywords            = @"肯德基";
    request.city                = @[@"010"];
    request.requireExtension    = YES;
    [self.search AMapPlaceSearch:request];
}
*/
/* 根据中心点坐标来搜周边的POI. */
/*
- (void)searchPoiByCenterCoordinate
{
    AMapPlaceSearchRequest *request = [[AMapPlaceSearchRequest alloc] init];
    
    request.searchType          = AMapSearchType_PlaceAround;
    request.location            = [AMapGeoPoint locationWithLatitude:39.990459 longitude:116.481476];
    request.keywords            = @"餐饮";
    // 按照距离排序.
    request.sortrule            = 1;
    request.requireExtension    = YES;
    
    // 添加搜索结果过滤
    AMapPlaceSearchFilter *filter = [[AMapPlaceSearchFilter alloc] init];
    filter.costFilter = @[@"100", @"200"];
    filter.requireFilter = AMapRequireGroupbuy;
    request.searchFilter = filter;
    
    [self.search AMapPlaceSearch:request];
}
*/

/* 在指定的范围内搜索POI. */
/*
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
}*/




@end
