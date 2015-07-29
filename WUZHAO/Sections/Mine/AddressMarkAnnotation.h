//
//  AddressMarkAnnotation.h
//  WUZHAO
//
//  Created by yiyi on 15/7/7.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

//#import <MAMapKit/MAMapKit.h>
#import <MapKit/MapKit.h>
#import "POI.h"
#import "WhatsGoingOn.h"

@interface AddressMarkAnnotation :  NSObject<MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) POI *poi;
@property (nonatomic, strong) NSString *showImageUrl;
@property (nonatomic) NSInteger photoNum;
@property (nonatomic, strong) NSArray *photoList;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
