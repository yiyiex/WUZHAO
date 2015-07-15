//
//  AddressInfoList.h
//  WUZHAO
//
//  Created by yiyi on 14-12-21.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "POI.h"

@interface AddressPhotos : NSObject

@property (nonatomic, strong) POI *poi;
@property (nonatomic) NSInteger photoNum;
@property (nonatomic , strong) NSMutableArray *photoList;

-(instancetype )initWithData:(NSDictionary *)data;

+ (NSArray *) newDataSource;
@end
