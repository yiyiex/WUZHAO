//
//  POI.h
//  WUZHAO
//
//  Created by yiyi on 15/4/6.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface POI : NSObject

@property (nonatomic,strong) NSString *uid;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *classify;
@property (nonatomic,strong) NSString *location;
@property (nonatomic,strong) NSString *address;
@property (nonatomic,strong) NSString *province;
@property (nonatomic,strong) NSString *city;
@property (nonatomic,strong) NSString *district;
@property (nonatomic,strong) NSString *stamp;
-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
