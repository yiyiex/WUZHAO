//
//  PIOSearchAPI.m
//  WUZHAO
//
//  Created by yiyi on 15/2/27.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "POISearchAPI.h"
#define POIAPIHOST @"http://placeapp.cn/"

#import "POI.h"

@implementation POISearchAPI


+(POISearchAPI*)sharedInstance
{
    static POISearchAPI *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate,^{
        
        sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:POIAPIHOST]];
        sharedInstance.responseSerializer = [AFJSONResponseSerializer serializer];
        [sharedInstance.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json",@"text/html", nil]];
        //[sharedInstance.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"application/json"]];
        sharedInstance.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        
    });
    return sharedInstance;
}

-(void)SearchAroundPOIWithLongitude:(float)longitude Latitude:(float)latitude radius:(float)radius ignorepolitical:(NSInteger )ignore whenComplete:(void(^)(NSDictionary *result))whenComplete
{
    NSString *api = @"api/nearbypoi";
    NSString *location = [NSString stringWithFormat:@"%f,%f",latitude,longitude];

    
    NSDictionary *param = @{@"location":location,@"radius":[NSNumber numberWithFloat:radius],@"ignorepolitical":[NSNumber numberWithInteger:ignore]};
    
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:param complete:^(NSDictionary *result, NSError *error) {
        NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
        if (result)
        {
            if ([[result objectForKey:@"success"] isEqualToString:@"true"])
            {
                NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
                [data setValue:[result objectForKey:@"nextPageToken"] forKey:@"nextPageToken"];
                [data setValue:[result objectForKey:@"data"] forKey:@"POIs"];
                [returnData setValue:data forKey:@"data"];
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
        }
        else if (error)
        {
            [returnData setValue:@"服务器异常" forKey:@"error"];
        }
        whenComplete(returnData);
    }];
    


}

-(void)getPOILocationWithPoiId:(NSInteger)poiId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = @"api/poilocation";
    NSDictionary *param = @{@"poiid":[NSNumber numberWithInteger:poiId]};
    
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:param complete:^(NSDictionary *result, NSError * error) {
         NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
         if (result )
         {
             if ([[result objectForKey:@"success"] isEqualToString:@"true"])
             {
                 
                 NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
                 [data setObject:[[result objectForKey:@"data"]objectForKey:@"location" ] forKey:@"locationString"];
                 [returnData setValue:data forKey:@"data"];
             }
             else if ([result objectForKey:@"msg"])
             {
                 [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
             }
             else
             {
                 [returnData setValue:@"服务器错误" forKey:@"error"];
             }
         }
         else if (error)
         {
             [returnData setValue:@"服务器异常" forKey:@"error"];
         }
        whenComplete(returnData);
    }];
    
}

- (void)regeoGoogleLocation:(float)latitude longitude:(float)longtitude whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = @"api/gpoidefault?location=-33.8670522,151.1957362";
    NSDictionary *param = @{@"location":[NSString stringWithFormat:@"%f,%f",latitude,longtitude]};
    
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:param complete:^(NSDictionary *result, NSError * error) {
        NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
        if (result )
        {
            if ([[result objectForKey:@"success"] isEqualToString:@"true"])
            {
                
                NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
                [data setObject:[result objectForKey:@"data"] forKey:@"poiInfo"];
                [returnData setValue:data forKey:@"data"];
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
        }
        else if (error)
        {
            [returnData setValue:@"服务器异常" forKey:@"error"];
        }
        whenComplete(returnData);
    }];
}












@end
