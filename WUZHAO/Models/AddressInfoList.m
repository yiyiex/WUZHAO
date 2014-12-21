//
//  AddressInfoList.m
//  WUZHAO
//
//  Created by yiyi on 14-12-21.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "AddressInfoList.h"

@implementation AddressInfoList

+ (NSArray *)newDataSource
{
    NSMutableArray *datasource = [[NSMutableArray alloc]init];
    
    [datasource addObject:@"address test1"];
    [datasource addObject:@"address test2"];
    [datasource addObject:@"address test3"];
    [datasource addObject:@"address test4"];
    return datasource;
}

@end
