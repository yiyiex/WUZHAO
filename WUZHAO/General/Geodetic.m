//
//  Geodetic.m
//  WUZHAO
//
//  Created by yiyi on 4/25/15.
//  Copyright (c) 2015 yiyi. All rights reserved.
//

#import "Geodetic.h"

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
    if ([Geodetic outOfChina:location])
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

+(BOOL)outOfChina:(CLLocation *)location
{
    if (location.coordinate.longitude <72.004 || location.coordinate.longitude >137.8347)
    {
        if (location.coordinate.latitude <0.8293 ||location.coordinate.latitude > 55.8271)
        {
            return YES;
        }
        return  NO;
    }
    
    return NO;
}
@end
