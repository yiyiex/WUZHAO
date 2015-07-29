//
//  ClusterAnnotation.h
//  WUZHAO
//
//  Created by yiyi on 15/7/22.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddressMarkAnnotation.h"
//#import <MAMapKit/MAMapKit.h>
#import <MapKit/MapKit.h>
#import "POI.h"
#import "WhatsGoingOn.h"

@interface ClusterAnnotation :  NSObject<MKAnnotation>
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *groupTag;

- (id)initWithAnnotation:(id<MKAnnotation> )annotation;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

-(NSArray *)annotationsInCluster;

-(void)addAnnotation:(id<MKAnnotation>)annotation;

-(void)addAnnotations:(NSArray *)annotations;

-(void)removeAnnotation:(id<MKAnnotation>)annotation;

-(void)removeAnnotations:(NSArray *)annotations;

@end

