//
//  Ditrict.h
//  WUZHAO
//
//  Created by yiyi on 15/7/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "POI.h"

@interface District : NSObject

@property (nonatomic, strong) NSString *districtName;
@property (nonatomic, strong) NSString *districtInfo;
@property (nonatomic) NSInteger distirctId;
@property (nonatomic, strong) NSString *defaultImageUrl;

@property (nonatomic, strong) NSMutableArray *POIs;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
+(District *)newData;
+(NSMutableArray *)newDatas;

@end
