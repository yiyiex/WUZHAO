//
//  API.m
//  testLogin
//
//  Created by yiyi on 14-11-25.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "AFHTTPAPIClient.h"

@implementation AFHTTPAPIClient

#define KAPIHOST @"http://caomei001.com"


@synthesize User;

+(AFHTTPAPIClient*)sharedInstance
{
    static AFHTTPAPIClient *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate,^{
        
        sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:KAPIHOST]];
        sharedInstance.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        
    });
    return sharedInstance;
}


-(BOOL)IsAuthenticated
{
    if (self.User != nil)
    {
        return true;
    }
    return false;
}


-(NSURLSessionDataTask *)LoginWithUserName:(NSString *)UserName password:(NSString *)Password complete:(void (^)(void))complete
{
    
    NSDictionary *userDic = @{@"username":UserName,@"password":Password};
    return [[AFHTTPAPIClient sharedInstance] POST:@"app/login" parameters:userDic success:^(NSURLSessionDataTask *task, id responseObject)
            {
                NSLog(@"loginsuccessfully");
                self.User = userDic;
                complete();
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                NSLog(@"login error:%@",error);
                self.User = userDic;
                complete();
            }];
    
    
    
}

@end
