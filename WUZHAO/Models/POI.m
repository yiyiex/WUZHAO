//
//  POI.m
//  WUZHAO
//
//  Created by yiyi on 15/4/6.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "POI.h"



@implementation POI

-(instancetype)init
{
    self= [super init];
    self.uid = [[NSString alloc]init];
    self.name = [[NSString alloc]init];
    self.classify = [[NSString alloc]init];
    self.location = [[NSString alloc]init];
    self.address = [[NSString alloc]init];
    self.province = [[NSString alloc]init];
    self.city = [[NSString alloc]init];
    self.district = [[NSString alloc]init];
    self.stamp = [[NSString alloc]init];
    return self;
}
-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        if ([dictionary objectForKey:@"uid"])
        {
            self.uid = [dictionary objectForKey:@"uid"];
        }
        if ([dictionary objectForKey:@"name"])
        {
            self.name = [dictionary objectForKey:@"name"];
        }
        if ([dictionary objectForKey:@"classify"])
        {
            self.classify = [dictionary objectForKey:@"classify"];
        }
        if ([dictionary objectForKey:@"location"])
        {
            self.location = [dictionary objectForKey:@"location"];
        }
        if ([dictionary objectForKey:@"address"])
        {
            self.address = [dictionary objectForKey:@"address"];
        }
        if ([dictionary objectForKey:@"address"])
        {
            self.province = [dictionary objectForKey:@"province"];
        }
        if ([dictionary objectForKey:@"city"])
        {
            self.city = [dictionary objectForKey:@"city"];
        }
        if ([dictionary objectForKey:@"district"])
        {
            self.district = [dictionary objectForKey:@"district"];
        }
        if ([dictionary objectForKey:@"stamp"])
        {
            self.stamp = [dictionary objectForKey:@"stamp"];
        }
        
    }
    return self;
}
-(void)configureWithGaodeSearchResult:(AMapPOI *)p
{
    self.uid = p.uid;
    self.name = p.name;
    self.address = p.address;
    self.city = p.city;
    self.district = p.district;
    self.province = p.province;
    self.stamp = p.timestamp;
    NSString *location = [NSString stringWithFormat:@"%f,%f",p.location.latitude,p.location.longitude];
    self.location = location;
    self.classify = p.type;
    self.type = POI_TYPE_GAODE;
}
-(void)configureWithGoogleSearchResult:(NSDictionary *)result
{
    self.uid = [result objectForKey:@"placeId"];
    self.name = [result objectForKey:@"name"];
    self.address = [result objectForKey:@"vicinity"];
    self.city = @"";
    self.district = @"";
    self.province = @"";
    self.stamp = @"";
    self.location = [result objectForKey:@"location"];
    self.classify = [result objectForKey:@"type"];
    self.type = POI_TYPE_GOOGLE;
}
-(void)configureWithGaodeaddressComponent:(AMapAddressComponent *)component
{
    self.uid = component.adcode;
    self.name = component.district;
    self.address = [NSString stringWithFormat:@"%@%@%@",component.province,component.city,component.district];
    self.city = [component.city isEqualToString:@""] ?component.province:component.city;
    self.district = component.district;
    self.province = component.province;
    self.stamp = @"";
    NSString *location = [NSString stringWithFormat:@"%f,%f",component.streetNumber.location.latitude,component.streetNumber.location.longitude];
    self.location = location;
    self.classify = @"行政区域";
    self.type = POI_TYPE_GAODE;
}


@end

