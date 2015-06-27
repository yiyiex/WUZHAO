//
//  Geodetic.m
//  WUZHAO
//
//  Created by yiyi on 4/25/15.
//  Copyright (c) 2015 yiyi. All rights reserved.
//

#import "Geodetic.h"

@interface Rectangle : NSObject
@property (nonatomic) float west;
@property (nonatomic) float east;
@property (nonatomic) float north;
@property (nonatomic) float south;

-(instancetype)initWithLatitude1:(float)latitude1 longitude1:(float)longitude1 latitude2:(float)latitude2 longitude2:(float)longitude2;
-(BOOL)includeLocation:(CLLocation *)location;
@end

@implementation Geodetic

// Krasovsky 1940
//
// a = 6378245.0, 1/f = 298.3
// b = a * (1 - f)
// ee = (a^2 - b^2) / a^2;

const double pi = 3.14159265358979324;
const double a = 6378245.0;
const double ee = 0.00669342162296594323;


+(CLLocation *)transFromGPSToMars:(CLLocation *)location
{
    double wgLat = location.coordinate.latitude;
    double wgLon = location.coordinate.longitude;
    double mgLat,mgLon;
    double dLat,dLon;
    CLLocation *marsGeo ;
    if ([Geodetic isInsideChina:location])
    {
        mgLat = location.coordinate.latitude;
        mgLon = location.coordinate.longitude;
    }
    else
    {
         dLat = [Geodetic transformLatitudeWithLatitude:(wgLon - 105.0) longitude:(wgLat - 35.0)];
         dLon = [Geodetic transformLongitudeWithLongitude:(wgLon - 105.0) longitude:(wgLat - 35.0)];

        double radLat = wgLat / 180.0 * pi;
        double magic = sin(radLat);
        magic = 1 - ee * magic * magic;
        double sqrtMagic = sqrt(magic);
        dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
        dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi);
        mgLat = wgLat + dLat;
        mgLon = wgLon + dLon;
    }
    marsGeo = [[CLLocation alloc]initWithLatitude:mgLat longitude:mgLon];
    return marsGeo;
}


+(double)transformLatitudeWithLatitude:(double)x longitude:(double)y
{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs((int)x));
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * pi) + 320 * sin(y * pi / 30.0)) * 2.0 / 3.0;
    return ret;
}
+(double)transformLongitudeWithLongitude:(float)x longitude:(float)y
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(abs((int)x));
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0;
    return ret;
}

+(BOOL)isInsideChina:(CLLocation *)location
{
    NSArray *includeRects = @[
                              [[Rectangle alloc]initWithLatitude1:49.220400 longitude1:079.446200 latitude2:42.889900 longitude2:096.330000],
                              [[Rectangle alloc]initWithLatitude1:54.141500 longitude1:109.687200 latitude2:39.374200 longitude2:135.000200],
                              [[Rectangle alloc]initWithLatitude1:42.889900 longitude1:073.124600 latitude2:29.529700 longitude2:124.143255],
                              [[Rectangle alloc]initWithLatitude1:29.529700 longitude1:082.968400 latitude2:26.718600 longitude2:097.035200],
                              [[Rectangle alloc]initWithLatitude1:29.529700 longitude1:097.025300 latitude2:20.414096 longitude2:124.367395],
                              [[Rectangle alloc]initWithLatitude1:20.414096 longitude1:107.975793 latitude2:17.871542 longitude2:111.744104]
    ];
    NSArray *excludeRects = @[
                              [[Rectangle alloc]initWithLatitude1:25.398623 longitude1:119.921265 latitude2:21.785006 longitude2:122.497559],
                              [[Rectangle alloc]initWithLatitude1:22.284000 longitude1:101.865200 latitude2:20.098800 longitude2:106.665000],
                              [[Rectangle alloc]initWithLatitude1:21.542200 longitude1:106.452500 latitude2:20.487800 longitude2:108.051000],
                              [[Rectangle alloc]initWithLatitude1:55.817500 longitude1:109.032300 latitude2:50.325700 longitude2:119.127000],
                              [[Rectangle alloc]initWithLatitude1:55.817500 longitude1:127.456800 latitude2:49.557400 longitude2:137.022700],
                              [[Rectangle alloc]initWithLatitude1:44.892200 longitude1:131.266200 latitude2:42.569200 longitude2:137.022700]
                              ];
    for (int i = 0; i < includeRects.count; i++)
    {
        if ([includeRects[i] includeLocation:location])
        {
            for (int j = 0; j < excludeRects.count; j++)
            {
                if ([excludeRects[j] includeLocation:location])
                {
                    return false;
                }
            }
            return true;
        }
    }
    return false;

}


@end




@implementation Rectangle

-(instancetype)initWithLatitude1:(float)latitude1 longitude1:(float)longitude1 latitude2:(float)latitude2 longitude2:(float)longitude2
{
    self = [super init];
    self.west = MIN(longitude1, longitude2);
    self.north = MAX(latitude1, latitude2);
    self.east = MAX(longitude1, longitude2);
    self.south = MIN(latitude1, latitude2);
    return self;
    
}
-(BOOL)includeLocation:(CLLocation *)location
{
    CLLocationCoordinate2D c =  location.coordinate;
    return self.west <= c.longitude && self.east >= c.longitude && self.north >= c.latitude && self.south <= c.latitude;
}


@end
