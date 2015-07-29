//
//  ClusterAlgorithms.m
//  WUZHAO
//
//  Created by yiyi on 15/7/22.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "ClusterAlgorithms.h"
#import "ClusterAnnotation.h"
#import "ClusterDistance.h"

static double euclidDistanceSquared(CLLocationCoordinate2D a, CLLocationCoordinate2D b)
{
    double latDelta = a.latitude-b.latitude;
    double lonDelta = a.longitude-b.longitude;
    return latDelta*latDelta + lonDelta*lonDelta;
}

@implementation ClusterAlgorithms
// Bubble clustering with iteration
+ (NSArray*)bubbleClusteringWithAnnotations:(NSArray*)annotationsToCluster
                              clusterRadius:(CLLocationDistance)radius
                                    grouped:(BOOL)grouped;
{
    NSMutableArray *clusteredAnnotations = [[NSMutableArray alloc] init];
    
    double radiusSquared = radius*radius;
    
    // Clustering
    for (id <MKAnnotation> annotation in annotationsToCluster)
    {
        // Find fitting existing cluster
        BOOL foundCluster = NO;
        CLLocationCoordinate2D annotationCoordinate = [annotation coordinate];
        for (ClusterAnnotation *clusterAnnotation in clusteredAnnotations) {
            // If the annotation is in range of the cluster, add it
            if(euclidDistanceSquared(annotationCoordinate, [clusterAnnotation coordinate]) <= radiusSquared) {
                
                foundCluster = YES;
                [clusterAnnotation addAnnotation:annotation];
                break;
            }
        }
        
        // If the annotation wasn't added to a cluster, create a new one
        if (!foundCluster){
            ClusterAnnotation *newCluster = [[ClusterAnnotation alloc] initWithAnnotation:annotation];
            [clusteredAnnotations addObject:newCluster];
        }
    }
    
    // whipe all empty or single annotations
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    for (ClusterAnnotation *anAnnotation in clusteredAnnotations) {
        if ([anAnnotation.annotationsInCluster count] == 1) {
            [returnArray addObject:[anAnnotation.annotationsInCluster lastObject]];
        } else if ([anAnnotation.annotationsInCluster count] > 1){
            [returnArray addObject:anAnnotation];
        }
    }
    
    return returnArray;
}

@end
