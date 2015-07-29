//
//  ClusterMapView.h
//  WUZHAO
//
//  Created by yiyi on 15/7/22.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

//#import <MAMapKit/MAMapKit.h>
#import <MapKit/MapKit.h>
#import "ClusterDistance.h"
#import "ClusterAnnotation.h"
#import "ClusterAlgorithms.h"

@interface ClusterMapView : MKMapView

//annotations will be ignored by the clustering algorithm
@property (nonatomic, strong) NSMutableSet *annotationsToIgnore;

//annotations displayed on the mapview
@property (nonatomic, readonly) NSArray *displayedAnnotations;

// is cluster enabled
@property (nonatomic, assign) BOOL clusteringEnabled;

//default 0.2   defines the cluster size in units of the map width
@property (nonatomic, assign) float clusterSize;

//defines the "zoom" from where the map shoud start clustering
/**if the map is zoomed below this value it won't cluster
/default : 0.0 */
@property (nonatomic, assign) CLLocationDegrees minLongitudeDeltaToCluster;

//defines how many annotations are need to build a cluster
/** if a cluster contains less annotations, they will shown as they are 
/default :0 */
@property (nonatomic, assign) NSUInteger minimumAnnotationCountPerCluster;

//clusters all annotations ,even if they are outside of the visible Coordinate Regin
/*default : NO */
@property (nonatomic, assign) BOOL clusterInvisibleViews;

-(void)doClustering;

@end
