//
//  PIOSearchAPI.m
//  WUZHAO
//
//  Created by yiyi on 15/2/27.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "PIOSearchAPI.h"
#define PIOAPIHOST @"http://placeapp.cn/"

@implementation PIOSearchAPI


+(PIOSearchAPI*)sharedInstance
{
    static PIOSearchAPI *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate,^{
        
        sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:PIOAPIHOST]];
        sharedInstance.responseSerializer = [AFJSONResponseSerializer serializer];
        [sharedInstance.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json",@"text/html", nil]];
        //[sharedInstance.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"application/json"]];
        sharedInstance.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        
    });
    return sharedInstance;
}

-(void)SearchAroundPIOWithLongitude:(float)longitude Latitude:(float)latitude radius:(float)radius whenComplete:(void(^)(NSDictionary *result))whenComplete
{
    NSString *api = @"api/nearbypoi";
    NSString *location = [NSString stringWithFormat:@"%f,%f",latitude,longitude];

    
    NSDictionary *param = @{@"location":location,@"radius":[NSNumber numberWithFloat:radius]};
    
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

@end
