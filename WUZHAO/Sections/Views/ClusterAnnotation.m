//
//  ClusterAnnotation.m
//  WUZHAO
//
//  Created by yiyi on 15/7/22.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "ClusterAnnotation.h"
static BOOL eql(id a, id b)
{
    if(a == b) {
        return YES;
    } else {
        return [a isEqual:b];
    }
}

static CLLocationDegrees const CMinimumInvalidDegree = 400.0;

@interface ClusterAnnotation()
@property (nonatomic, strong) NSMutableArray *annotationsInCluster;
@property (nonatomic, assign) CLLocationCoordinate2D minCoordinate;
@property (nonatomic, assign) CLLocationCoordinate2D maxCoordinate;

@end
@implementation ClusterAnnotation

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        _annotationsInCluster = [[NSMutableArray alloc]init];
        _minCoordinate.latitude = CMinimumInvalidDegree;
        _maxCoordinate.latitude = CMinimumInvalidDegree;
    }
    return self;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (self = [super init])
    {
        _coordinate = coordinate;
        _annotationsInCluster = [[NSMutableArray alloc]init];
        _minCoordinate = coordinate;
        _maxCoordinate = coordinate;
        
    }
    return self;
}

- (id)initWithAnnotation:(AddressMarkAnnotation *)annotation
{
    self = [super init];
    if (self)
    {
        CLLocationCoordinate2D annotationCoordinate = [annotation coordinate];
        _annotationsInCluster = [[NSMutableArray alloc]init];
        _minCoordinate = annotationCoordinate;
        _maxCoordinate = annotationCoordinate;
        _coordinate = annotationCoordinate;
        [_annotationsInCluster addObject:annotation];
        
    }
    return self;
}

-(NSArray *)annotationsInCluster
{
    return  [_annotationsInCluster copy];
}


#pragma mark - add / remove annotations
-(void)addAnnotation:(id<MKAnnotation> )annotation
{
    CLLocationCoordinate2D annotationCoordinate = annotation.coordinate;
    // check if min and max have been set
    if (self.minCoordinate.latitude >= CMinimumInvalidDegree) {
        _minCoordinate = annotationCoordinate;
    }
    if (self.maxCoordinate.latitude >= CMinimumInvalidDegree) {
        _maxCoordinate = annotationCoordinate;
    }
    
    // Add annotation to the cluster
    [_annotationsInCluster addObject:annotation];
    
    // recompute center coordinate
    _minCoordinate.latitude = MIN(_minCoordinate.latitude, annotationCoordinate.latitude);
    _minCoordinate.longitude = MIN(_minCoordinate.longitude,annotationCoordinate.longitude);
    _maxCoordinate.latitude = MAX(_maxCoordinate.latitude, annotationCoordinate.latitude);
    _maxCoordinate.longitude = MAX(_maxCoordinate.longitude, annotationCoordinate.longitude);
    
    _coordinate.latitude = _minCoordinate.latitude + (_maxCoordinate.latitude-_minCoordinate.latitude)/2.0;
    _coordinate.longitude = _minCoordinate.longitude + (_maxCoordinate.longitude-_minCoordinate.longitude)/2.0;
}
-(void)addAnnotations:(NSArray *)annotations
{
    for (id<MKAnnotation> annotion in annotations)
    {
        [self addAnnotation:annotion];
    }
}

-(void)removeAnnotation:(AddressMarkAnnotation *)annotation
{
    [_annotationsInCluster removeObject:annotation];
}

-(void)removeAnnotations:(NSArray *)annotations
{
    for ( id<MKAnnotation> annotion in annotations)
    {
        [self removeAnnotation:annotion];
    }
}

#pragma mark - utility

-(BOOL)isEqual:(ClusterAnnotation *)annotation
{
    if ( [annotation isKindOfClass:[ClusterAnnotation class]])
    {
        return NO;
    }
    if (self.coordinate.latitude == annotation.coordinate.latitude && self.coordinate.longitude == annotation.coordinate.longitude && eql(self.groupTag, annotation.groupTag))
    {
        NSSet *a_annotationsInCluser = [[NSSet alloc]initWithArray:self.annotationsInCluster];
        NSSet *b_annotationsInCluser = [[NSSet alloc]initWithArray:annotation.annotationsInCluster];
        if ([a_annotationsInCluser isEqual:b_annotationsInCluser])
        {
            return YES;
        }
    }
    return NO;
}
@end
