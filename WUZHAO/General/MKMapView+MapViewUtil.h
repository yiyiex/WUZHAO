//
//  MKMapView+MapViewUtil.h
//  WUZHAO
//
//  Created by yiyi on 15/7/23.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (MapViewUtil)
- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;
@end
