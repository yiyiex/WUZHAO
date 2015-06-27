//
//  POI.h
//  WUZHAO
//
//  Created by yiyi on 15/4/6.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapSearchKit/AMapSearchAPI.h>


typedef  NS_ENUM(NSInteger, POI_TYPE)
{
    POI_TYPE_GAODE = 1,
    POI_TYPE_GOOGLE = 2
};

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
@property (nonatomic) POI_TYPE type;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (void)configureWithGaodeSearchResult:(AMapPOI *)p;
- (void)configureWithGoogleSearchResult:(NSDictionary *)result;
@end
