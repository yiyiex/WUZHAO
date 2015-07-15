//
//  SuggestAddress.m
//  WUZHAO
//
//  Created by yiyi on 15/7/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "SuggestAddress.h"

@implementation SuggestAddress

-(instancetype)initWithDictionary:(NSDictionary *)attribute
{
    self = [super init];
    if (self)
    {
        if ([attribute objectForKey:@"type"])
        {
            self.type = [[attribute objectForKey:@"type"]integerValue];
        }
        if (self.type == SuggestAddressType_POI)
        {
            self.poiInfo = [[POI alloc]initWithDictionary:attribute];
        }
        if (self.type == SuggestAddressType_Distirct)
        {
            self.districtInfo = [[District alloc]initWithDictionary:attribute];
        }
        if ([attribute objectForKey:@"user"])
        {
            self.poiUser = [[User alloc]initWithAttributes:[attribute objectForKey:@"user"]];
        }
    }
    return self;
}

+(SuggestAddress *)newData1
{
    SuggestAddress *data = [[SuggestAddress alloc]initWithDictionary:@{
                                                                       @"addressType":@1,
                                                                       @"POI":@{
                                                                                @"poi_id":@"1",
                                                                                @"uid":@"1111",
                                                                                @"name":@"上海外滩·800m观景长廊，呦呵~哟西",
                                                                                @"defaultImage":@"http://photos.tuchong.com/274591/f/3090526.jpg",
                                                                                @"poiInfo":@"看尽上海的繁华"}}];
    return data;
}

+(SuggestAddress *)newData2
{
    SuggestAddress *data = [[SuggestAddress alloc]initWithDictionary:@{
                                                                       @"addressType":@2,
                                                                       @"district":@{@"name":@"上海",
                                                                                     @"id":@1,
                                                                                     @"info":@"中华第一都市",
                                                                                     @"defaultImage":@"http://cyjctrip.qiniudn.com/43900/1370186019452p17s2n3qa513edsqmkbef6n13t3p.jpg",
                                                                                     @"POIs":@[
                                                                                             @{
                                                                                                 @"poi_id":@"1",
                                                                                                 @"uid":@"1111",
                                                                                                 @"name":@"上海外滩",
                                                                                                 @"defaultImage":@"http://photos.tuchong.com/274591/f/3090526.jpg",
                                                                                                 @"poiInfo":@"看尽上海的繁华"},
                                                                                             @{
                                                                                                 @"poi_id":@"1",
                                                                                                 @"uid":@"1111",
                                                                                                 @"name":@"上海外滩",
                                                                                                 @"defaultImage":@"http://photos.tuchong.com/274591/f/3090526.jpg",
                                                                                                 @"poiInfo":@"看尽上海的繁华"},
                                                                                             @{
                                                                                                 @"poi_id":@"1",
                                                                                                 @"uid":@"1111",
                                                                                                 @"name":@"上海外滩",
                                                                                                 @"defaultImage":@"http://photos.tuchong.com/274591/f/3090526.jpg",
                                                                                                 @"poiInfo":@"看景上海的繁华"}
                                                                                             ]
                                                                                     
                                                                                     }}];
    return data;
}
+(NSMutableArray *)newDatas
{
    NSMutableArray *data = [[NSMutableArray alloc]init];
    [data addObject:[SuggestAddress newData1]];
    [data addObject:[SuggestAddress newData2]];
    [data addObject:[SuggestAddress newData1]];
    [data addObject:[SuggestAddress newData2]];
    [data addObject:[SuggestAddress newData1]];
    [data addObject:[SuggestAddress newData2]];
    [data addObject:[SuggestAddress newData1]];
    [data addObject:[SuggestAddress newData2]];
    [data addObject:[SuggestAddress newData1]];
    [data addObject:[SuggestAddress newData2]];
    [data addObject:[SuggestAddress newData1]];
    [data addObject:[SuggestAddress newData2]];
    return data;
}

@end
