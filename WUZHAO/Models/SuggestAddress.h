//
//  SuggestAddress.h
//  WUZHAO
//
//  Created by yiyi on 15/7/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "POI.h"
#import "District.h"
#import "User.h"

typedef NS_ENUM(NSUInteger, SuggestAddressType)
{
    SuggestAddressType_POI = 1,
    SuggestAddressType_Distirct = 2
};
@interface SuggestAddress : NSObject

@property (nonatomic) SuggestAddressType type;
@property (nonatomic, strong) POI *poiInfo;
@property (nonatomic, strong) User *poiUser;

@property (nonatomic, strong) District *districtInfo;


-(instancetype)initWithDictionary:(NSDictionary *)attribute;
+(SuggestAddress *)newData1;
+(SuggestAddress *)newData2;
+(NSMutableArray *)newDatas;

@end
