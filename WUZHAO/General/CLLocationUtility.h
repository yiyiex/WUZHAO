//
//  CLLLocationUtility.h
//  WUZHAO
//
//  Created by yiyi on 15/8/2.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CLLocationUtility : NSObject <CLLocationManagerDelegate>

@property (nonatomic,strong) CLLocationManager *manager;
@property (nonatomic, strong) void(^completeSearchBlock)(NSDictionary *returnData);

-(void)getCurrentLocationWithComplete:(void (^)(NSDictionary *))whenComplete;


@end
