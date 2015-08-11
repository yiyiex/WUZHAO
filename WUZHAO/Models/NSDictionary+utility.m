//
//  NSDictionary+utility.m
//  WUZHAO
//
//  Created by yiyi on 15/8/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "NSDictionary+utility.h"

@implementation NSDictionary (utility)
-(BOOL)hasObject:(NSString *)key
{
    if ([self objectForKey:key] && ![[self objectForKey:key] isKindOfClass:[NSNull class]])
    {
        return YES;
    }
    return NO;
}

@end
