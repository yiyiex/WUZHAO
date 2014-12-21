//
//  FootPrint.m
//  WUZHAO
//
//  Created by yiyi on 14-12-21.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "FootPrint.h"

@implementation FootPrint

+(NSArray *)newData
{
    NSMutableArray *data = [[NSMutableArray alloc]init];
    FootPrint *item = [[FootPrint alloc]init];
    item.addressInfo = @"上海 test1";
    item.topImageUrl = @"http://img3.douban.com/view/photo/photo/public/p2206858462.jpg";
    [data addObject:item];
    
    item.addressInfo = @"上海 test2";
    item.topImageUrl = @"http://img3.douban.com/view/photo/photo/public/p2206860902.jpg";
    [data addObject:item];
    
    item.addressInfo = @"上海 test3";
    item.topImageUrl = @"http://img3.douban.com/view/photo/photo/public/p2206861122.jpg";
    [data addObject:item];
    
    item.addressInfo = @"上海 test4";
    item.topImageUrl = @"http://img3.douban.com/view/photo/photo/public/p2206861334.jpg";
    [data addObject:item];
    
    return data;
}
@end
