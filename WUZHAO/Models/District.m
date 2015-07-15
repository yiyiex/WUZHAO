//
//  Ditrict.m
//  WUZHAO
//
//  Created by yiyi on 15/7/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "District.h"

@implementation District

-(NSMutableArray *)POIs
{
    if (!_POIs)
    {
        _POIs = [[NSMutableArray alloc]init];
    }
    return _POIs;
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        if ([dictionary objectForKey:@"name"])
        {
            self.districtName = [dictionary objectForKey:@"name"];
        }
        if ([dictionary objectForKey:@"id"])
        {
            self.distirctId = [[dictionary objectForKey:@"id"]integerValue];
        }
        if ([dictionary objectForKey:@"description"])
        {
            self.districtInfo = [dictionary objectForKey:@"description"];
        }
        if ([dictionary objectForKey:@"defaultImage"])
        {
            self.defaultImageUrl = [dictionary objectForKey:@"defaultImage"];
        }
        if ([dictionary objectForKey:@"poiList"])
        {
            [[dictionary objectForKey:@"poiList"]enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                POI *poi = [[POI alloc]initWithDictionary:obj];
                [self.POIs addObject:poi];
            }];
        }
    }
    return self;
}


+(District *)newData
{
    District *district = [[District alloc]initWithDictionary:@{@"name":@"上海",
                                                               @"id":@1,
                                                               @"description":@"中华第一都市",
                                                               @"defaultImage":@"http://cyjctrip.qiniudn.com/43900/1370186019452p17s2n3qa513edsqmkbef6n13t3p.jpg",
                                                               @"poiList":@[
                                                                       @{
                                                                           @"poi_id":@"1",
                                                                           @"uid":@"1111",
                                                                           @"name":@"上海外滩",
                                                                           @"defaultImage":@"http://photos.tuchong.com/274591/f/3090526.jpg",
                                                                           @"poiInfo":@"看景上海的繁华"},
                                                                       @{
                                                                           @"poi_id":@"1",
                                                                           @"uid":@"1111",
                                                                           @"name":@"上海外滩",
                                                                           @"defaultImage":@"http://photos.tuchong.com/274591/f/3090526.jpg",
                                                                           @"poiInfo":@"看景上海的繁华"},
                                                                       @{
                                                                           @"poi_id":@"1",
                                                                           @"uid":@"1111",
                                                                           @"name":@"上海外滩",
                                                                           @"defaultImage":@"http://photos.tuchong.com/274591/f/3090526.jpg",
                                                                           @"poiInfo":@"看景上海的繁华"}
                                                                       ]
                                                               
                                                               }];
    return district;
}
+(NSMutableArray *)newDatas
{
    NSMutableArray *datas = [[NSMutableArray alloc]init];
    [datas addObject:[District newData]];
    [datas addObject:[District newData]];
    [datas addObject:[District newData]];
    [datas addObject:[District newData]];
    [datas addObject:[District newData]];
    [datas addObject:[District newData]];
    [datas addObject:[District newData]];
    [datas addObject:[District newData]];
    [datas addObject:[District newData]];
    [datas addObject:[District newData]];
    [datas addObject:[District newData]];
    return datas;
}
@end
