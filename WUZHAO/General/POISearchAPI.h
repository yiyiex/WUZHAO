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

-(void)SearchAroundPOIWithLongitude:(float)longitude Latitude:(float)latitude radius:(float)radius ignorepolitical:(NSInteger )ignore whenComplete:(void(^)(NSDictionary *result))whenComplete;

-(void)getPOILocationWithPoiId:(NSInteger )poiId whenComplete:(void(^)(NSDictionary *reuslt))whenComplete;

- (void)regeoGoogleLocation:(float)latitude longitude:(float)longtitude whenComplete:(void (^)(NSDictionary *))whenComplete;
@end