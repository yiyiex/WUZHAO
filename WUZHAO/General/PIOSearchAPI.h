//
//  PIOSearchAPI.h
//  WUZHAO
//
//  Created by yiyi on 15/2/27.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "AFHTTPAPIClient.h"

@interface PIOSearchAPI : AFHTTPAPIClient

+(PIOSearchAPI*)sharedInstance;

-(void)SearchAroundPIOWithLongitude:(float)longitude Latitude:(float)latitude whenComplete:(void(^)(NSDictionary *result))whenComplete;
@end
