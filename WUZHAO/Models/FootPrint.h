//
//  FootPrint.h
//  WUZHAO
//
//  Created by yiyi on 14-12-21.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FootPrint : NSObject

@property (nonatomic,strong) NSString  *addressInfo;
@property (nonatomic,strong) NSString *topImageUrl;
@property (nonatomic,strong) NSArray *imagesUrl;

+(NSArray *)newData;
@end
