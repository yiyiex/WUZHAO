//
//  PIOSearchAPI.m
//  WUZHAO
//
//  Created by yiyi on 15/2/27.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "PIOSearchAPI.h"
#define PIOAPIHOST @"https://maps.googleapis.com"
#define GOOGLEPLACEAPIKEY @"AIzaSyD75TeI-QYmsySYjoUlzVSpS2Oii7sbslM"
#define LANG @"ch"
@implementation PIOSearchAPI


+(PIOSearchAPI*)sharedInstance
{
    static PIOSearchAPI *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate,^{
        
        sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:PIOAPIHOST]];
        sharedInstance.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        
    });
    return sharedInstance;
}

-(void)SearchAroundPIOWithLongitude:(float)longitude Latitude:(float)latitude whenComplete:(void(^)(NSDictionary *result))whenComplete
{
    NSString *api = @"maps/api/place/nearbysearch/json";
    NSString *location = [NSString stringWithFormat:@"%f,%f",longitude,latitude];
    NSString *rankby = @"prominence";
    NSString *sensor = @"true";
    
    NSDictionary *param = @{@"key":GOOGLEPLACEAPIKEY,@"location":location,@"sensor":sensor,@"language":LANG,@"rankby":rankby};
    
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:param complete:^(NSDictionary *result, NSError *error) {
        NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
        if (result)
        {
           if ([result objectForKey:@"error_message"])
           {
               NSLog(@"请求无法被接受，key 不正确，或者被墙");
           }
            else
            {
                NSLog(@"%@",result);
            }
            returnData = result;
        }
        else if (error)
        {
            [returnData setValue:@"服务器异常" forKey:@"error"];
        }
        whenComplete(returnData);
    }];
    


}

@end
