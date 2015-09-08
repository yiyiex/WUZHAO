//
//  Ditrict.h
//  WUZHAO
//
//  Created by yiyi on 15/7/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "POI.h"

typedef NS_ENUM(NSInteger, DISTRICT_TYPE)
{
    DISTRICT_TYPE_CITY = 1,
    DISTRICT_TYPE_COUNTRY = 2
};

@interface District : NSObject

@property (nonatomic, strong) NSString *districtName;
@property (nonatomic, strong) NSString *districtInfo;
@property (nonatomic) NSInteger distirctId;
@property (nonatomic, strong) NSString *defaultImageUrl;

@property (nonatomic, strong) NSMutableArray *POIs;
@property (nonatomic, strong) NSMutableArray *photosList;
@property (nonatomic) DISTRICT_TYPE type;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
+(District *)newData;
+(NSMutableArray *)newDatas;

@end
