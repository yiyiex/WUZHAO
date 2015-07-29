//
//  AddressMarkAnnotation.m
//  WUZHAO
//
//  Created by yiyi on 15/7/7.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "AddressMarkAnnotation.h"

@implementation AddressMarkAnnotation


#pragma mark - life cycle

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (self = [super init])
    {
        _coordinate = coordinate;
    }
    return self;
}
@end
