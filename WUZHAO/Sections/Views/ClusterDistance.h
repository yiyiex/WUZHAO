//
//  ClusterDistance.h
//  WUZHAO
//
//  Created by yiyi on 15/7/22.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <MAMapKit/MAMapKit.h>
#import <MapKit/MapKit.h>

/** @fn double CLLocationCoordinateDistance(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2)
 @brief calculates the distance between two given coordinates in meters
 */
double CLLocationCoordinateDistance(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2);

/// Returns YES if pt is contained within the bounds or region
BOOL MKCoordinateRegionContainsPoint(MKCoordinateRegion region, CLLocationCoordinate2D pt);

/// Returns YES if b is fully contained in a (i.e. the intersection of a and b = b)
BOOL MKCoordinateRegionContainsRegion(MKCoordinateRegion a, MKCoordinateRegion b);

