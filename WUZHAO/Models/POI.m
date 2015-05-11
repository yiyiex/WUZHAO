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


@end

