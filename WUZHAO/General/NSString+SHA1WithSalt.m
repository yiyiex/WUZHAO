//
//  NSString+SHA1WithSalt.m
//  WUZHAO
//
//  Created by yiyi on 15/2/26.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "NSString+SHA1WithSalt.h"


#import <CommonCrypto/CommonDigest.h>


#define SALT @"qiudaoyuSalt@123"

@implementation NSString (SHA1WithSalt)

-(NSString *)SHA1
{
    
    NSString *string = [self appendSalt:SALT];
    
    const char *cstr = [string UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cstr, strlen(cstr), result);
    
    NSString *s = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   result[0],result[1],result[19],result[3],result[4],result[5],result[6],
                   result[7],result[8],result[9],result[10],result[11],result[12],result[13],
                   result[14],result[15],result[16],result[17],result[18],result[2]];
    return s;
}

-(NSString *)appendSalt:(NSString *)salt
{
    NSString *string = [self stringByAppendingString:salt];
    return  string;
}
@end
