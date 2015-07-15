//
//  AddressInfoList.m
//  WUZHAO
//
//  Created by yiyi on 14-12-21.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "AddressPhotos.h"
#import "WhatsGoingOn.h"

@implementation AddressPhotos
-(NSMutableArray *)photoList
{
    if (!_photoList)
    {
        _photoList = [[NSMutableArray alloc]init];
    }
    return _photoList;
}

-(instancetype )initWithData:(NSDictionary *)data
{
    self = [super init];
    self.poi = [[POI alloc]initWithDictionary:data];
    if ([data objectForKey:@"photoNum"])
    {
        self.photoNum = [[data objectForKey:@"photoNum"]integerValue];
    }
    
    if ([data objectForKey:@"postList"])
    {
        [[data objectForKey:@"postList"]enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            WhatsGoingOn *item = [[WhatsGoingOn alloc]initWithAttributes:obj];
            [self.photoList addObject:item];
            
        }];
    }
    
    return self;
}


+(NSArray *)newDataSource
{
    NSDictionary *data1 = @{@"POI":@{@"uid":@"11111",@"name":@"杭州市·余杭区",@"location":@"-33.8670522,151.1957362"},
                           @"photoNum":@2,
                            @"photoList":@[@{@"photo":
                                         @"http://img4.douban.com/view/photo/photo/public/p2254231799.jpg",@"post_id":@1},
                                           @{@"photo":@"http://img3.douban.com/view/photo/photo/public/p2254477835.jpg",@"post_id":@2}]};
    NSDictionary *data2 = @{@"POI":@{@"uid":@"2222",@"name":@"上海市·徐汇区",@"location":@"33.8670522,151.1957362"},
                            @"photoNum":@10,
                            @"photoList":@[
                                    @{@"photo":@"http://img4.douban.com/view/status/raw/public/f8e55597055e768.jpg",@"post_id":@4},
                                    @{@"photo":@"http://img3.douban.com/view/status/raw/public/e8655e54beeb2a5.jpg",@"post_id":@5},
                                    @{@"photo":@"http://img4.douban.com/view/status/raw/public/aeefb22c9318dd8.jpg",@"post_id":@6},
                                    @{@"photo":@"http://img3.douban.com/view/photo/photo/public/p2237812724.jpg",@"post_id":@7},
                                    @{@"photo":@"http://img4.douban.com/view/photo/photo/public/p2233960027.jpg",@"post_id":@8},
                                    @{@"photo":@"http://img4.douban.com/view/photo/photo/public/p2234899216.jpg",@"post_id":@9}]};
    AddressPhotos *address1 = [[AddressPhotos alloc]initWithData:data1];
    AddressPhotos *address2 = [[AddressPhotos alloc]initWithData:data2];
    
    return @[address1,address2];
}



@end
