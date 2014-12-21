//
//  API.h
//  testLogin
//
//  Created by yiyi on 14-11-25.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
@interface AFHTTPAPIClient : AFHTTPSessionManager


@property (nonatomic,strong) NSDictionary *User;

+(AFHTTPAPIClient*)sharedInstance;

-(BOOL)IsAuthenticated;

//通过用户名密码登陆请求
-(NSURLSessionDataTask *)LoginWithUserName:(NSString *)UserName password:(NSString *)Password complete:(void (^)(void))complete;

@end
