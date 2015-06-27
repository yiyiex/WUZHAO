//
//  Geodetic.h
//  WUZHAO
//
//  Created by yiyi on 4/25/15.
//  Copyright (c) 2015 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Geodetic : NSObject

+(CLLocation *)transFromGPSToMars:(CLLocation *)location;
+(BOOL)isInsideChina:(CLLocation *)location;
@end
