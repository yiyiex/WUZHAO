//
//  NSString+Verify.m
//  WUZHAO
//
//  Created by yiyi on 15/4/20.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "NSString+Verify.h"
#import "RegExCategories.h"

@implementation NSString (Verify)

-(BOOL)isValidPassword
{
    //Rx *passwordRx = RX(@"^[a-zA-Z0-9_]+$");
    Rx *passwordRx = RX(@"^.{6,}$");
    return [self isMatch:passwordRx];
}

-(BOOL)isValidUsername
{
    Rx *userNameRx = RX(@"^[A-Za-z0-9_\u4E00-\u9FA5]+$");
    return  [self isMatch:userNameRx];
}

-(BOOL)isVaildEmail
{
    Rx *emailRx = RX(@"^[\\w.]+@[\\w.]+$");
    return  [self isMatch:emailRx];
}

@end
