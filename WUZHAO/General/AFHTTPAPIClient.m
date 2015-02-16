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

#define KAPIHOST @"http://qiudaoyu.sinaapp.com/"
//#define KAPIHOST @"http://192.168.1.103/wuzhao/"


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
//current user info
- (User *)currentUser
{
    if (!_currentUser)
    {
        _currentUser = [[User alloc]init];
        
    }
    return _currentUser;
}

-(BOOL)IsAuthenticated
{
    if (self.currentUser.UserID)
    {
        return true;
    }
    return false;
}

//login and register
-(NSURLSessionDataTask *)LoginWithUserName:(NSString *)UserName password:(NSString *)Password complete:(void (^)(NSDictionary  *result, NSError *error))complete
{
    NSLog(@"mobile:%@,password:%@",UserName,Password);
    NSDictionary *userDic = @{@"email":UserName,@"pwd":Password};
    return [[AFHTTPAPIClient sharedInstance] POST:@"api/login" parameters:userDic success:^(NSURLSessionDataTask *task, id responseObject)
            {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                if (httpResponse.statusCode == 200)
                {
                    if ([[responseObject objectForKey:@"success" ] isEqualToString:@"false"])
                    {
                        NSLog(@"login failed：%@",[responseObject objectForKey:@"msg"]);

                        
                    }
                    else
                    {
                        NSLog(@"login success! %@," ,[responseObject objectForKey:@"msg"]);
                        NSDictionary *data = [responseObject objectForKey:@"data"];
                        self.currentUser.UserID =[[data objectForKey:@"user_id"] intValue];
                        self.currentUser.UserName = [data objectForKey:@"nick"];
                        self.currentUser.userToken = [responseObject objectForKey:@"token"];
                        NSLog(@"\n user info ***********************%@",self.currentUser);
                    }
                    complete(responseObject,nil);
                }
                
                else
                {
                    NSLog(@"%ld",(long)httpResponse.statusCode);
                    complete(@{@"msg":@"服务器错误"},nil);
                }
                
                
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                NSLog(@"请求不成功，服务器问题");
                complete(nil,error);
            }];
    
    
    
}


- (NSURLSessionDataTask *) RegisterWithUserName:(NSString *)userName email:(NSString *)email password:(NSString *)password complete:(void (^) (NSDictionary *result ,NSError *error))complete
{
    NSString *api = @"api/register";
    NSDictionary *userDic = @{@"nick":userName,@"email":email,@"pwd":password};
    NSLog(@"%@",userDic);
    return [[AFHTTPAPIClient sharedInstance] POST:api parameters:userDic success:^(NSURLSessionDataTask *task, id responseObject)
            {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                NSLog(@"服务器返回结果：**************%@",responseObject);
                if (httpResponse.statusCode == 200)
                {
                    if ( [[responseObject objectForKey:@"success"] isEqualToString:@"false"])
                    {
                        NSLog(@"register failed :%@",[responseObject objectForKey:@"success"]);
                    }
                    else
                    {
                        NSLog(@"register success!");
                        self.currentUser.UserID =(NSInteger) [[responseObject objectForKey:@"data"]objectForKey:@"user_id"];
                        self.currentUser.UserName = userDic[@"nick"];
                        self.currentUser.userToken = [responseObject objectForKey:@"token"];
                        NSLog(@"\n user info ***********************%@",self.currentUser);

                                                
                    }
                    complete(responseObject,nil);
                }
                else
                {
                    NSLog(@"%ld",(long)httpResponse.statusCode);
                    complete(@{@"sever error":@"服务器错误"},nil);
                }

                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                NSLog(@"服务器返回结果：**************%@",error);
                complete(nil,error);
                

            }];
}

//change pwd

-(void)UpdatePwdWithUserId:(NSInteger)userId password:(NSString *)password newpassword:(NSString *)newPwd whenComplete:(void (^)(NSDictionary *returnData))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/uploadauth/%ld",(long)userId];
    NSDictionary *param = @{@"pwd":password,@"newPwd":newPwd};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"POST" api:api parameters:param complete:^(NSDictionary *result, NSError *error) {
        if (result) {
            NSDictionary *data = [result objectForKey:@"data"];
            if (data)
            {
                
            }
            else
            {
                [returnData setValue:@"接口请求失败" forKey:@"error"];
            }
        }
        else if (error)
        {
            [returnData setValue:@"服务器异常" forKey:@"error"];
        }
        whenComplete(returnData);
    }];
}

//post one photo
- (void) GetQiNiuTokenWithUserId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/uploadauth/%ld",(long)userId];
    //NSDictionary *userDic = @{@"nick":@"",@"mobile":@"",@"pwd":@""};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:nil complete:^(NSDictionary *result, NSError *error) {
        if (result)
        {
            NSDictionary *data = [result objectForKey:@"data"];
            if (data)
            {
                NSMutableDictionary *tokenData = [[NSMutableDictionary alloc]init];
                [tokenData setValue:[data objectForKey:@"upload_token"] forKey:@"uploadToken"];
                [tokenData setValue:[NSString stringWithFormat:@"%ld",(long)[[AFHTTPAPIClient sharedInstance]currentUser].UserID] forKey:@"userId"];
                [tokenData setValue:[data objectForKey:@"file_name"] forKey:@"imageName"];
                [returnData setValue:tokenData forKey:@"data"];
                
            }
            else
            {
                [returnData setValue:@"接口请求失败" forKey:@"error"];
            }
        }
        else if (error)
        {
            [returnData setValue:@"服务器异常" forKey:@"error"];
        }
        whenComplete(returnData);
    }];
}
-(void) PostPhotoInfomationWithUserId:(NSInteger)userId method:(NSString *)method photo:(NSString *)photoName thought:(NSString *)thought haspoi:(BOOL)haspoi provider:(NSInteger)provider uid:(NSString *)uid name:(NSString *)name classify:(NSString *)classify location:(NSString *)location address:(NSString *)address province:(NSString *)province city:(NSString *)city district:(NSString *)district stamp:(NSString *)stamp whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/post/%ld",(long)userId];
    NSDictionary *photoInfo = @{@"photo":photoName,
                                @"method":method,
                                @"thought":thought,
                                @"haspoi":haspoi?@"true":@"false",
                                @"provider":[NSNumber numberWithInteger:provider],
                                @"uid":uid,@"name":name,
                                @"classify":classify,
                                @"location":location,
                                @"address":address,
                                @"province":province,
                                @"city":city,
                                @"district":district,
                                @"stamp":stamp};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"POST" api:api parameters:photoInfo complete:^(NSDictionary *result, NSError *error) {
        if (result) {
            NSDictionary *data = [result objectForKey:@"data"];
            if (data)
            {
                
            }
            else
            {
                [returnData setValue:@"接口请求失败" forKey:@"error"];
            }
        }
        else if (error)
        {
            [returnData setValue:@"服务器异常" forKey:@"error"];
        }
        whenComplete(returnData);
    }];
}


//personal info

- (void)GetPersonalInfoWithUserId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/user/%ld",(long)userId];
    //NSDictionary *param = @{@"user_id":[NSNumber numberWithInteger:userId]};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:nil complete:^(NSDictionary *result, NSError *error) {
        if (result)
        {
            NSDictionary *data = [result objectForKey:@"data"];
            if (data)
            {
                User *user = [[User alloc]init];
                user.UserID = [(NSNumber *)[data objectForKey:@"user_id"] integerValue];
                user.UserName = [data objectForKey:@"nick"];
                user.avatarImageURLString = [data objectForKey:@"avatar"];
                user.selfDescriptions = [data objectForKey:@"description"];
                user.photosNumber = [(NSNumber *)[data objectForKey:@"post_num"] integerValue];;
                user.email = [data objectForKey:@"email"];
                
                user.numFollows = [(NSNumber *)[data objectForKey:@"followed_num"] integerValue];
                user.numFollowers =[(NSNumber *)[data objectForKey:@"follower_num"] integerValue];
                NSArray *photoList = [data objectForKey:@"simplepost_list"];
                NSMutableDictionary *photoItem = [[NSMutableDictionary alloc]init];
                for (NSDictionary *item in photoList)
                {
                    [photoItem setObject:[item objectForKey:@"post_id"] forKey:@"postId"];
                    [photoItem setObject:[item objectForKey:@"create_time"] forKey:@"time"];
                    [photoItem setObject:[item objectForKey:@"photo"] forKey:@"photoUrl"];
                    [user.photoList addObject:photoItem];
                    [photoItem removeAllObjects];
                
                }
                [returnData setObject:user forKey:@"data"];
               // [returnData setValue:user forKey:@"data"];
            }
            else
            {
                [returnData setObject:@"接口请求失败" forKey:@"error"];
            }
        }
        
        else if (error)
        {
            [returnData setObject:@"服务器异常" forKey:@"error"];
        }
        whenComplete(returnData);
        
    }];
    
}

- (void)GetPersonalPhotosListWithUserId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/*******%ld",(long)userId];
    NSDictionary *param = @{@"user_id":[NSNumber numberWithInteger:userId]};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    whenComplete(returnData);
}

-(void)GetPersonalAddressListWithUserId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/*******%ld",(long)userId];
    NSDictionary *param = @{@"user_id":[NSNumber numberWithInteger:userId]};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    whenComplete(returnData);
}

-(void )GetPersonalFollowersListWithUserId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/*******%ld",(long)userId];
    NSDictionary *param = @{@"user_id":[NSNumber numberWithInteger:userId]};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    whenComplete(returnData);
}

-(void )GetPersonalFollowsListWithUserId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/*******%ld",(long)userId];
    NSDictionary *param = @{@"user_id":[NSNumber numberWithInteger:userId]};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    whenComplete(returnData);
}

//photo info
//http://192.168.1.103/wuzhao/api/newupdate/1


-(void)GetWhatsGoingOnWithUserId:(NSInteger )userId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/newupdate/%ld",(long)userId];
    //NSDictionary *param = @{@"user_id":nsint};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:nil complete:^(NSDictionary *result, NSError *error) {
        if ([result objectForKey:@"success"])
        {
            NSArray *data = [result objectForKey:@"data"];
            NSMutableArray *postData = [[NSMutableArray alloc]init];
            if (data)
            {
                NSInteger dataCount = [data count];
                
                // item.photoUser = [[User alloc]init];
                for (NSInteger i = 0;i <dataCount;i++)
                {
                    WhatsGoingOn *item = [[WhatsGoingOn alloc]init];
                    
                    item.postId =[(NSNumber *)[[data objectAtIndex:i] objectForKey:@"post_id"] integerValue];
                
                    
                    item.photoUser.UserID = [(NSNumber *)[[data objectAtIndex:i] objectForKey:@"user_id"]integerValue];
                    item.photoUser.UserName = [data[i] objectForKey:@"nick"];
                    item.photoUser.avatarImageURLString = [data[i] objectForKey:@"avatar"];
                    item.photoUser.selfDescriptions = [data[i] objectForKey:@"description"];
                
                
                    item.postTime = [data[i] objectForKey:@"create_time"];
                    item.imageUrlString = [data[i] objectForKey:@"photo"];
                    item.imageDescription = [data[i] objectForKey:@"thought"];
                    item.likeCount = [(NSNumber *)[data[i] objectForKey:@"like_num"] integerValue];
                    
                    item.commentNum = [(NSNumber *)[data[i] objectForKey:@"comment_num"]integerValue];
                    
                    item.poiId = [(NSNumber *)[data[i] objectForKey:@"poi_id"] integerValue];
                    item.poiName = [data[i] objectForKey:@"poi_name"];
                    
                    
                    if ([[data[i] objectForKey:@"more_comments"] isEqualToString:@"false"])
                    {
                        item.hasMoreComments =  NO;
                    }
                    else
                    {
                        item.hasMoreComments = YES;
                    }
                    NSMutableString *commentString = [[NSMutableString alloc]init];
                    NSMutableArray *commentList = [[NSMutableArray alloc]init];
                    NSArray *commentListInData = [data[i] objectForKey:@"comment_list"];
                    NSMutableDictionary *commentItem = [[NSMutableDictionary alloc]init];
                    for (NSDictionary *comment in commentListInData)
                    {
                        [commentItem setValue:[comment objectForKey:@"comment"] forKey:@"content"];
                        [commentItem setValue:[comment objectForKey:@"comment_id"] forKey:@"comment_id"];
                        [commentItem setValue:[comment objectForKey:@"create_time"] forKey:@"time"];
                        [commentItem setValue:[comment objectForKey:@"post_id"] forKey:@"postId"];
                        [commentItem setValue:[comment objectForKey:@"user_id"] forKey:@"userName"];
                        [commentItem setValue:[comment objectForKey:@"user_name"] forKey:@"userId"];
                        [commentList addObject:commentItem];
                        [commentString appendString:[NSString stringWithFormat:@"<userName>%@</userName>%@\n",[commentItem objectForKey:@"userName"],[commentItem objectForKey:@"content"]]];
                        
                        
                    }
                    item.comment = [commentString mutableCopy];
                    item.commentList = [commentList mutableCopy];
                    
                    [postData addObject:item];
                    
                    
                
                }
                [returnData setValue:postData forKey:@"data"];
            }
            else
            {
                [returnData setValue:@"接口请求失败" forKey:@"error"];
                
            }
        }
        else if (error)
        {
            [returnData setValue:@"服务器错误" forKey:@"error"];
        }
        whenComplete(returnData);
    }];
}
// data = {'post_id':'1','user_id':'11','comment':'用什么相机拍的这是？iphone么'}
-(void)ZanPhotoWithUserId:(NSInteger)userId postId:(NSInteger)postId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/like/%ld",(long)postId];
   // NSDictionary *param = @{@"user_id":[NSNumber numberWithInteger:self.currentUser.UserID],@"post_id":[NSNumber numberWithInteger:postId]};
    NSDictionary *param = @{@"user_id":@"2",@"post_id":@"1"};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    whenComplete(returnData);
}
-(void)CommentPhotoWithUserId:(NSInteger)userId postId:(NSInteger)postId comment:(NSString *)comment whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/comment/%ld",(long)postId];
    NSDictionary *param = @{@"user_id":[NSNumber numberWithInteger:self.currentUser.UserID],@"post_id":[NSNumber numberWithInteger:postId],@"comment":comment};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    whenComplete(returnData);
}

-(void)GetPhotoInfoWithPostId:(NSInteger)postId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/post/%ld",(long)postId];
    NSDictionary *param = @{@"user_id":[NSNumber numberWithInteger:postId]};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:param complete:^(NSDictionary *result, NSError *error) {
        
    }];
    whenComplete(returnData);
}

-(NSURLSessionDataTask *)ExecuteRequestWithMethod:(NSString *)method api:(NSString *)api parameters:(NSDictionary *)param complete:(void (^)(NSDictionary *, NSError *))complete
{
    if ( [method isEqualToString:@"GET"])
    {
        return  [[AFHTTPAPIClient sharedInstance] GET:api parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
            if (httpResponse.statusCode == 200)
            {
                if ( [[responseObject objectForKey:@"success"] isEqualToString:@"false"])
                {
                    NSLog(@"get infomation failed:");
                    NSLog(@"%@",responseObject);
                }
                else
                {
                    NSLog(@"get infomation seccuess!");
                     NSLog(@"%@",responseObject);
                    
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
        return  [[AFHTTPAPIClient sharedInstance] POST:api parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
            if (httpResponse.statusCode == 200)
            {
                if ( [[responseObject objectForKey:@"success"] isEqualToString:@"false"])
                {
                    NSLog(@"get infomation failed:");
                     NSLog(@"%@",responseObject);
                }
                else
                {
                    NSLog(@"get infomation success!");
                    NSLog(@"%@",responseObject);
                    
                }
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
