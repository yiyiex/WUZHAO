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
    if ( [method isEqualToString:@"GET"])
    {
        return  [self GET:api parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
            if (httpResponse.statusCode == 200)
            {
                if ( [[responseObject objectForKey:@"success"] isEqualToString:@"false"])
                {
                    NSLog(@"get infomation failed:");
                    //NSLog(@"%@",responseObject);
                }
                else
                {
                     NSLog(@"get infomation seccuess!");
                     //NSLog(@"%@",responseObject);
                    
                }
            }
            complete(responseObject,nil);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"request failed");
            NSLog(@"%@",error);
            complete(@{@"msg":@"请求成功，但服务器返回错误"},nil);
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
            complete(responseObject,nil);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"request failed");
            NSLog(@"%@",error);
            complete(@{@"msg":@"请求成功，但服务器返回错误"},nil);
        }];
    }
}

@end
