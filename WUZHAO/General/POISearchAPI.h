//
//  PIOSearchAPI.h
//  WUZHAO
//
//  Created by yiyi on 15/2/27.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "AFHTTPAPIClient.h"

@interface POISearchAPI : AFHTTPAPIClient

+(POISearchAPI*)sharedInstance;

//根据坐标，通过google地图搜索附近地址；用于国外坐标搜索
- (void)SearchAroundPOIWithLongitude:(float)longitude Latitude:(float)latitude radius:(float)radius ignorepolitical:(NSInteger )ignore pagetoken:(NSString *)pagetoken whenComplete:(void(^)(NSDictionary *result))whenComplete;

//获取指定POI的location信息
- (void)getPOILocationWithPoiId:(NSInteger )poiId whenComplete:(void(^)(NSDictionary *reuslt))whenComplete;

//根据坐标，通过google 反解析当前地址
- (void)regeoGoogleLocation:(float)latitude longitude:(float)longtitude whenComplete:(void (^)(NSDictionary *))whenComplete;

//根据关键字，通过google搜索POI
-(void)SearchAroundPOIWithKeyWord:(NSString *)keyword whenComplete:(void (^)(NSDictionary *))whenComplete;

//获取用户的所有POI列表
- (void)getUserPOIsWithUserId:(NSInteger )userId whenComplete:(void (^)(NSDictionary *))whenComplete;

//获取指定用户指定POI下的照片列表
- (void)getPOIDetail:(NSInteger)poiId userId:(NSInteger )userId whenComplete:(void (^)(NSDictionary *))whenComplete;

//获取指定用户历史使用POI记录
- (void)getUserPOIHistory:(NSInteger )userId whenComplete:(void (^)(NSDictionary *))whenComplete;

@end
