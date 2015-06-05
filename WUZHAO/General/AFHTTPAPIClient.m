//
//  API.m
//  testLogin
//
//  Created by yiyi on 14-11-25.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//
#import "macro.h"
#import "AFHTTPAPIClient.h"


@implementation AFHTTPAPIClient


-(NSURLSessionDataTask *)ExecuteRequestWithMethod:(NSString *)method api:(NSString *)api parameters:(NSDictionary *)param complete:(void (^)(NSDictionary *, NSError *))complete
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = @"";
    NSInteger userId = 0;
    if ([userDefaults objectForKey:@"token"])
    {
        token = [userDefaults objectForKey:@"token"];
    }
    if ([userDefaults integerForKey:@"userId"])
    {
        userId = [userDefaults integerForKey:@"userId"];
    }
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [self.requestSerializer setValue:app_Version forHTTPHeaderField:@"version"];
    [self.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    [self.requestSerializer setValue:[NSString stringWithFormat:@"%ld",(long)userId] forHTTPHeaderField:@"userId"];
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    if ( [method isEqualToString:@"GET"])
    {
        return  [self GET:api parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
            if (httpResponse.statusCode == 200)
            {
                if ( [[responseObject objectForKey:@"success"] isEqualToString:@"false"])
                {
                    NSLog(@"get infomation failed:");
                    if ([(NSNumber *)[responseObject objectForKey:@"code"]integerValue] ==110)
                    {
                        NSLog(@"token校验失败");
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"tokenIllegal" object:nil];
                        complete(@{@"msg":@"登录态失效，请重新登录"},nil);
                    }
                    else
                    {
                        complete(@{@"msg":[responseObject objectForKey:@"msg"]},nil);
                    }
                }
                else
                {
                     complete(responseObject,nil);   
                }
            }
            else
            {
                complete(@{@"msg":@"您请求的服务不存在或者服务器错误"},nil);
            }
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"request failed");
            NSLog(@"%@",error);
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
            complete(@{@"msg":@"请求成功，但服务器返回错误"},error);
            
        }];
        
    }
    else 
    {
        return  [self POST:api parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
            if (httpResponse.statusCode == 200)
            {
                /*
                if ( [[responseObject objectForKey:@"success"] isEqualToString:@"false"])
                {
                    NSLog(@"get infomation failed:");
                     NSLog(@"%@",responseObject);
                }
                else
                {
                    NSLog(@"get infomation success!");
                    NSLog(@"%@",responseObject);
                    
                }*/
            }
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
            complete(responseObject,nil);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"request failed");
            NSLog(@"%@",error);
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
            complete(@{@"msg":@"请求成功，但服务器返回错误"},nil);
        }];
    }
}

@end
