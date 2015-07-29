//
//  ClusterAlgorithms.h
//  WUZHAO
//
//  Created by yiyi on 15/7/22.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <MAMapKit/MAMapKit.h>
#import <MapKit/MapKit.h>
#import "ClusterDistance.h"
#import "ClusterAnnotation.h"

@protocol ClusterAlgorithmsDelegate;

@interface ClusterAlgorithms : NSObject

+ (NSArray*)bubbleClusteringWithAnnotations:(NSArray*)annotationsToCluster
                              clusterRadius:(CLLocationDistance)radius
                                    grouped:(BOOL)grouped;
@end


@protocol ClusterAlgorithmsDelegate <NSObject>
@required
-(NSArray *)algorithmClusteredPartially;
@optional
-(void)algorithmDidBeganClustering;
-(void)algorithmDidFinishClustering;
@end
