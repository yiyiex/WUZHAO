//
//  API.h
//  testLogin
//
//  Created by yiyi on 14-11-25.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

#import "User.h"
#import "WhatsGoingOn.h"
@interface AFHTTPAPIClient : AFHTTPSessionManager
-(NSURLSessionDataTask *)ExecuteRequestWithMethod:(NSString *)method api:(NSString *)api parameters:(NSDictionary *)param complete:(void (^)(NSDictionary *, NSError *))complete;
@end
