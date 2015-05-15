//
//  QDYHTTPClient.m
//  WUZHAO
//
//  Created by yiyi on 15/2/11.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "QDYHTTPClient.h"


#define KAPIHOST @"http://placeapp.cn/"


@implementation QDYHTTPClient
+(QDYHTTPClient*)sharedInstance
{
    static QDYHTTPClient *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate,^{
        
        sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:KAPIHOST]];
        sharedInstance.responseSerializer = [AFJSONResponseSerializer serializer];
        [sharedInstance.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"application/json"]];
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
    if (self.currentUser.UserID && self.currentUser.userToken)
    {
        return true;
    }
    return false;
}

//login and register
-(NSURLSessionDataTask *)LoginWithUserName:(NSString *)UserName password:(NSString *)Password loginType:(NSString *)type complete:(void (^)(NSDictionary  *result, NSError *error))complete
{
    NSDictionary *userDic;
    if ([type isEqualToString:@"nick"])
    {
        userDic = @{@"username":UserName,@"pwd":Password,@"type":type};
    }
    else if ([type isEqualToString:@"email"])
    {
        userDic = @{@"email":UserName,@"pwd":Password,@"type":type};
    }
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];

    return [[QDYHTTPClient sharedInstance] POST:@"api/login" parameters:userDic success:^(NSURLSessionDataTask *task, id responseObject)
            {
                [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
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
                        self.currentUser.userToken = [data objectForKey:@"token"];
                        //self.currentUser.userToken = @"";
                        [self setDefaultUserInfoWithUser:self.currentUser];
                        [self updateLocalUserInfo];
                        NSLog(@"^---^ user id%ld",(long)self.currentUser.UserID);
                        NSLog(@"^---^ user token%@",self.currentUser.userToken);
                        
                        NSLog(@"%@",data);
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
                [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
                complete(nil,error);
            }];
    
    
    
}


- (NSURLSessionDataTask *) RegisterWithUserName:(NSString *)userName email:(NSString *)email password:(NSString *)password complete:(void (^) (NSDictionary *result ,NSError *error))complete
{
    NSString *api = @"api/register";
    NSDictionary *userDic = @{@"nick":userName,@"email":email,@"pwd":password};
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    return [[QDYHTTPClient sharedInstance] POST:api parameters:userDic success:^(NSURLSessionDataTask *task, id responseObject)
            {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
                [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
                if (httpResponse.statusCode == 200)
                {
                    if ( [[responseObject objectForKey:@"success"] isEqualToString:@"false"])
                    {
                        NSLog(@"register failed :%@",[responseObject objectForKey:@"success"]);
                    }
                    else
                    {
                        NSDictionary *data = [responseObject objectForKey:@"data"];
                        self.currentUser.UserID =[[data objectForKey:@"user_id"] intValue];
                        self.currentUser.UserName = [data objectForKey:@"nick"];
                        self.currentUser.userToken = [data objectForKey:@"token"];
                        NSLog(@"\n user info ***********************%@",self.currentUser);
                        [self setDefaultUserInfoWithUser:self.currentUser];
                        [self updateLocalUserInfo];
                        
                        
                    }
                    complete(responseObject,nil);
                }
                else
                {
                    NSLog(@"%ld",(long)httpResponse.statusCode);
                    complete(@{@"sever error":@"服务器错误"},nil);
                }
                
                
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
                NSLog(@"服务器返回结果：**************%@",error);
                complete(nil,error);
                
                
            }];
}

//log out
-(void)logOutWithUserId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = @"api/logout";
    NSDictionary *param = @{@"userId":[NSNumber numberWithInteger:userId]};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"POST" api:api parameters:param complete:^(NSDictionary *result, NSError *error) {
        if (result) {
            if ([[result objectForKey:@"success"] isEqualToString:@"true"])
            {
                NSDictionary *data = [result objectForKey:@"data"];
                if (data)
                {
                    [returnData setValue:@"退出成功" forKey:@"data"];
                }
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
        }
        else if (error)
        {
            [returnData setValue:@"服务器异常" forKey:@"error"];
        }
        whenComplete(returnData);
    }];
}

//change pwd

-(void)UpdatePwdWithUserId:(NSInteger)userId password:(NSString *)password newpassword:(NSString *)newPwd whenComplete:(void (^)(NSDictionary *returnData))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/updatepwd"];
    NSDictionary *param = @{@"userId":[NSNumber numberWithInteger:userId],@"oldPwd":password,@"newPwd":newPwd};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"POST" api:api parameters:param complete:^(NSDictionary *result, NSError *error) {
        if (result) {
            if ([[result objectForKey:@"success"] isEqualToString:@"true"])
            {
                [returnData setValue:@"密码更新成功" forKey:@"data"];
            }
            else if ([result objectForKey:@"msg"])
            {
                //[returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
                [returnData setValue:@"旧密码输入错误" forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
        }
        else if (error)
        {
            [returnData setValue:@"服务器异常" forKey:@"error"];
        }
        whenComplete(returnData);
    }];
}

//update personal infomation
-(void)UpdatePersonalInfoWithUser:(User *)user oldNick:(NSString *)oldNick whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/updateuser"];

    NSDictionary *param = @{@"userId":[NSNumber numberWithInteger:user.UserID],@"oldNick":oldNick,@"newNick":user.UserName,@"description":user.selfDescriptions};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"POST" api:api parameters:param complete:^(NSDictionary *result, NSError *error) {
        if (result)
        {
            if ([[result objectForKey:@"success"] isEqualToString:@"true"])
            {
                [returnData setValue:@"更新个人信息成功" forKey:@"data"];
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
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
- (void) GetQiNiuTokenWithUserId:(NSInteger)userId type:(NSInteger)requestType whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/uploadauth"];
    //NSDictionary *userDic = @{@"nick":@"",@"mobile":@"",@"pwd":@""};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    NSDictionary *param = @{@"userid":[NSNumber numberWithInteger:userId],@"type":[NSNumber numberWithInteger:requestType]};
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:param complete:^(NSDictionary *result, NSError *error) {
        if (result)
        {
            if ([[result objectForKey:@"success"] isEqualToString:@"true"])
            {
                NSDictionary *data = [result objectForKey:@"data"];
                if (data)
                {
                    NSMutableDictionary *tokenData = [[NSMutableDictionary alloc]init];
                    [tokenData setValue:[data objectForKey:@"upload_token"] forKey:@"uploadToken"];
                    [tokenData setValue:[data objectForKey:@"file_name"] forKey:@"imageName"];
                    [returnData setValue:tokenData forKey:@"data"];
                    
                }
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
        }
        else if (error)
        {
            [returnData setValue:@"服务器异常" forKey:@"error"];
        }
        whenComplete(returnData);
    }];
}
-(void) PostPhotoInfomationWithUserId:(NSInteger)userId  photo:(NSString *)photoName thought:(NSString *)thought haspoi:(BOOL)haspoi provider:(NSInteger)provider uid:(NSString *)uid name:(NSString *)name classify:(NSString *)classify location:(NSString *)location address:(NSString *)address province:(NSString *)province city:(NSString *)city district:(NSString *)district stamp:(NSString *)stamp whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/post/%ld",(long)userId];
    NSDictionary *photoInfo = @{@"photo":photoName,
                                @"thought":thought,
                                @"haspoi":haspoi?@"true":@"false",
                                @"provider":[NSNumber numberWithInteger:provider],
                                @"uid":uid,
                                @"name":name,
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
            if ([[result objectForKey:@"success"] isEqualToString:@"true"])
            {
                NSDictionary *data = [result objectForKey:@"data"];
                if (data)
                {
                    [returnData setValue:data forKey:@"data"];
                }
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
        }
        else if (error)
        {
            [returnData setValue:@"服务器异常" forKey:@"error"];
        }
        whenComplete(returnData);
    }];
}

//delete one post
-(void)deletePhotoWithUserId:(NSInteger)userId postId:(NSInteger)postId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/deletepost"];
    NSDictionary *param = @{@"user_id":[NSNumber numberWithInteger:userId],
                            @"post_id":[NSNumber numberWithInteger:postId]};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"POST" api:api parameters:param complete:^(NSDictionary *result, NSError *error) {
        if (result)
        {
            if ([[result objectForKey:@"success"] isEqualToString:@"true"])
            {
                if ([result objectForKey:@"data"])
                {
                    [returnData setValue:@"删除成功" forKey:@"data"];
                }
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
        }
        else
        {
            [returnData setValue:@"服务器异常" forKey:@"error"];
        }
        whenComplete(returnData);
        
    }];
}
//address info
-(void)GetPOIInfoWithPoiId:(NSInteger)poiId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/poiphotos/%ld",(long)poiId];
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    NSMutableArray *poiInfo = [[NSMutableArray alloc]init];
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:nil complete:^(NSDictionary *result, NSError *error) {
        if (result)
        {
            if ([[result objectForKey:@"success"] isEqualToString:@"true"])
            {
                NSDictionary *data = [result objectForKey:@"data"];
                if (data)
                {
                    for (NSDictionary *d in data)
                    {
                        WhatsGoingOn *item  = [[WhatsGoingOn alloc]init];
                        item.postId = [(NSNumber *)[d objectForKey:@"post_id"]integerValue];
                        item.postTime = [d objectForKey:@"create_time"];
                        item.imageUrlString = [d objectForKey:@"photo"];
                        [poiInfo addObject:item];
                    }
                    [returnData setObject:poiInfo forKey:@"data"];
                    
                }
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
        }
        
        else if (error)
        {
            [returnData setObject:@"服务器异常" forKey:@"error"];
        }
        whenComplete(returnData);
    }];
}


//personal info
-(void)GetPersonalSimpleInfoWithUserId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/personalinfo/%ld",(long)userId];
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:nil complete:^(NSDictionary *result, NSError *error) {
        if (result)
        {
            if ([[result objectForKey:@"success"] isEqualToString:@"true"])
            {
                NSDictionary *data = [result objectForKey:@"data"];
                if (data)
                {
                    User *user = [[User alloc]initWithAttributes:data];
                    [returnData setObject:user forKey:@"data"];
                    // [returnData setValue:user forKey:@"data"];
                }
                
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
        }
        
        else if (error)
        {
            [returnData setObject:@"服务器异常" forKey:@"error"];
        }
        whenComplete(returnData);
    }];
}
-(void)GetPersonalInfoWithUserId:(NSInteger)userId currentUserId:(NSInteger)currentUserId page:(NSInteger)page whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/user/%ld?page=%ld&currentUserId=%ld",(long)userId,(long)page,(long)currentUserId];
    //NSDictionary *param = @{@"user_id":[NSNumber numberWithInteger:userId]};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:nil complete:^(NSDictionary *result, NSError *error) {
        if (result)
        {
            if ([[result objectForKey:@"success"] isEqualToString:@"true"])
            {
                NSDictionary *data = [result objectForKey:@"data"];
                if (data)
                {
                    User *user = [[User alloc]initWithAttributes:data];
                    [returnData setObject:user forKey:@"data"];
                    // [returnData setValue:user forKey:@"data"];
                }
                
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
        }
        
        else if (error)
        {
            [returnData setObject:@"服务器异常" forKey:@"error"];
        }
        whenComplete(returnData);
    }];
    
}


-(void)GetPersonalFollowersListWithUserId:(NSInteger)userId currentUserId:(NSInteger)currentUserId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"/api/guanzhuzhe/%ld?currentUserId=%ld",(long)userId,(long)currentUserId];
    //NSDictionary *param = @{@"user_id":[NSNumber numberWithInteger:userId]};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:nil complete:^(NSDictionary *result, NSError *error) {
        NSMutableArray *userList = [[NSMutableArray alloc]init];
        if (result)
        {
            if ([[result objectForKey:@"success"] isEqualToString:@"true"])
            {
                NSArray *data = [result objectForKey:@"data"];
                if (data)
                {
                    for (NSDictionary *item in data)
                    {
                        User *user = [[User alloc]initWithAttributes:item];
                        [userList addObject:user];
                    }
                    [returnData setValue:userList forKey:@"data"];
                }
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
        }
        else
        {
            [returnData setValue:@"服务器错误" forKey:@"error"];
        }
        whenComplete(returnData);
        
    }];
    
}

-(void)GetPersonalFollowsListWithUserId:(NSInteger)userId currentUserId:(NSInteger)currentUserId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/guanzhule/%ld?currentUserId=%ld",(long)userId,(long)currentUserId];
    //NSDictionary *param = @{@"user_id":[NSNumber numberWithInteger:userId]};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:nil complete:^(NSDictionary *result, NSError *error) {
        NSMutableArray *userList = [[NSMutableArray alloc]init];
        if (result)
        {
            if ([[result objectForKey:@"success"] isEqualToString:@"true"])
            {
                NSArray *data = [result objectForKey:@"data"];
                if (data)
                {
                    for (NSDictionary *item in data)
                    {
                        User *user = [[User alloc]initWithAttributes:item];
                        
                        [userList addObject:user];
                    }
                    [returnData setValue:userList forKey:@"data"];
                }
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
            
        }
        else
        {
            [returnData setValue:@"服务器错误" forKey:@"error"];
        }
        whenComplete(returnData);
        
    }];
}

-(void)PostAvatorWithUserId:(NSInteger)userId avatorName:(NSString *)avatarName whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/avatar/%ld",(long)userId];
    NSDictionary *param = @{@"avatar":avatarName};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"POST" api:api parameters:param complete:^(NSDictionary *result, NSError *error) {
     if (result)
     {
         if ([[result objectForKey:@"success"] isEqualToString:@"true"])
         {
            if ([result objectForKey:@"data"])
            {
                [returnData setValue:@"上传头像成功" forKey:@"data"];
            }
         }
         else if ([result objectForKey:@"msg"])
         {
             [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
         }
         else
         {
             [returnData setValue:@"服务器错误" forKey:@"error"];
         }
    }
     else if (error)
     {
         [returnData setValue:@"服务器异常" forKey:@"error"];
     }
        whenComplete(returnData);
    }];
}
//photo info
//http://192.168.1.103/wuzhao/api/newupdate/1


-(void)GetWhatsGoingOnWithUserId:(NSInteger )userId page:(NSInteger)page whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/newupdate/%ld?page=%ld",(long)userId,(long)page];
    //NSDictionary *param = @{@"user_id":nsint};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:nil complete:^(NSDictionary *result, NSError *error) {
        if (result)
        {
            if ([[result objectForKey:@"success"] isEqualToString:@"true"])
            {
                NSArray *data = [result objectForKey:@"data"];
                NSMutableArray *postData = [[NSMutableArray alloc]init];
                if (data)
                {
                    NSInteger dataCount = [data count];
                    
                    // item.photoUser = [[User alloc]init];
                    for (NSInteger i = 0;i <dataCount;i++)
                    {
                        WhatsGoingOn *item = [[WhatsGoingOn alloc]initWithAttributes:data[i]];
                        [postData addObject:item];
                    }
                    [returnData setValue:postData forKey:@"data"];
                }
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
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
     NSDictionary *param = @{@"user_id":[NSNumber numberWithInteger:userId]};
    //NSDictionary *param = @{@"user_id":@"2",@"post_id":@"1"};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"POST" api:api parameters:param complete:^(NSDictionary *result, NSError *error) {
        if (result)
        {
            if ([[result objectForKey:@"success"] isEqualToString:@"true"])
            {
                NSArray *data = [result objectForKey:@"data"];
                if (data)
                {
                    [returnData setValue:@"点赞成功" forKey:@"data"];
                }
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
        }
        else if (error)
        {
            [returnData setValue:@"服务器错误" forKey:@"error"];
        }
        
         whenComplete(returnData);
    }];
   
}
-(void)CancelZanPhotoWithUserId:(NSInteger)userId postId:(NSInteger)postId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/unlike/%ld",(long)postId];
    NSDictionary *param = @{@"user_id":[NSNumber numberWithInteger:userId]};
    //NSDictionary *param = @{@"user_id":@"2",@"post_id":@"1"};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"POST" api:api parameters:param complete:^(NSDictionary *result, NSError *error) {
        if (result)
        {
            if ([[result objectForKey:@"success"] isEqualToString:@"true"])
            {
                NSArray *data = [result objectForKey:@"data"];
                if (data)
                {
                    [returnData setValue:@"点赞成功" forKey:@"data"];
                }
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
        }
        else if (error)
        {
            [returnData setValue:@"服务器错误" forKey:@"error"];
        }
        
        whenComplete(returnData);
    }];
}

-(void)GetPhotoZanUserListWithPostId:(NSInteger)postId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/like/%ld",(long)postId];
    //NSDictionary *param = @{@"user_id":[NSNumber numberWithInteger:userId]};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:nil complete:^(NSDictionary *result, NSError *error) {
        NSMutableArray *userList = [[NSMutableArray alloc]init];
        if (result)
        {
            if ([[result objectForKey:@"success"] isEqualToString:@"true"])
            {
                NSArray *data = [result objectForKey:@"data"];
                if (data)
                {
                    for (NSDictionary *item in data)
                    {
                        User *user = [[User alloc]init];
                        user.UserID = [(NSNumber *)[item objectForKey:@"user_id"] integerValue];
                        user.UserName = [item objectForKey:@"nick"];
                        user.selfDescriptions = [item objectForKey:@"description"];
                        user.avatarImageURLString = [item objectForKey:@"avatar"];
                        
                        [userList addObject:user];
                    }
                  
                    [returnData setValue:userList forKey:@"data"];
                }
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
            
        }
        else
        {
            [returnData setValue:@"服务器错误" forKey:@"error"];
        }
        whenComplete(returnData);
        
    }];
}

-(void)GetCommentListWithPostId:(NSInteger)postId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"/api/comment/%ld",(long)postId];
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:nil complete:^(NSDictionary *result, NSError *error) {
        if (result)
        {
            if ([[result objectForKey:@"success"] isEqualToString:@"true"])
            {
                NSArray *data = [result objectForKey:@"data"];
                if (data)
                {
                    WhatsGoingOn *item = [[WhatsGoingOn alloc]init];
                    item.postId = postId;
                    [item configureWithCommentList:data commentNum:data.count];
                    [returnData setValue:item forKey:@"data"];
                }
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
            
        }
        else
        {
            [returnData setValue:@"服务器错误" forKey:@"error"];
        }
        whenComplete(returnData);
    }];
}

-(void)CommentPhotoWithUserId:(NSInteger)userId postId:(NSInteger)postId comment:(NSString *)comment replyUserId:(NSInteger)replyUserId  whenComplete:(void (^)(NSDictionary *))whenComplete
{
     NSString *api = [NSString stringWithFormat:@"/api/putcomment"];
    NSDictionary *param;
    if (replyUserId >0)
    {
         param = @{@"user_id":[NSNumber numberWithInteger:userId],@"post_id":[NSNumber numberWithInteger:postId],@"comment":comment,@"replyUserId":[NSNumber numberWithInteger:replyUserId]};
     
    }
    else
    {
           param = @{@"user_id":[NSNumber numberWithInteger:userId],@"post_id":[NSNumber numberWithInteger:postId],@"comment":comment};
       
    }
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"POST" api:api parameters:param complete:^(NSDictionary *result, NSError *error) {
        if (result)
        {
            if ([[result objectForKey:@"success"] isEqualToString:@"true"])
            {
                NSNumber *data = [result objectForKey:@"data"];
                if (data)
                {
                    [returnData setValue:data forKey:@"data"];
                }
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
            
        }
        else
        {
            [returnData setValue:@"服务器错误" forKey:@"error"];
        }
         whenComplete(returnData);
    }];
   
}

-(void)DeleteCommentPhotoWithCommentId:(NSInteger)commentId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"/api/deletecomment"];
    NSDictionary *param = @{@"comment_id":[NSNumber numberWithInteger:commentId]};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"POST" api:api parameters:param complete:^(NSDictionary *result, NSError *error) {
        if (result)
        {
            if ([[result objectForKey:@"success"] isEqualToString:@"true"])
            {
                NSNumber *data = [result objectForKey:@"data"];
                if (data)
                {
                    [returnData setValue:data forKey:@"data"];
                }
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
            
        }
        else
        {
            [returnData setValue:@"服务器错误" forKey:@"error"];
        }
        whenComplete(returnData);
    }];
}

-(void)GetPhotoInfoWithPostId:(NSInteger)postId userId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"/api/post/%ld?user_id=%ld",(long)postId,(long)userId];
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:nil complete:^(NSDictionary *result, NSError *error) {
        if (result)
        {
            if ([[result objectForKey:@"success"] isEqualToString:@"true"])
            {
                
                NSDictionary *data = [result objectForKey:@"data"];
                if (data)
                {
                   // postItem.photoUser
                    WhatsGoingOn *postItem = [[WhatsGoingOn alloc]initWithAttributes:data];
                    [returnData setValue:postItem forKey:@"data"];
                    
                }
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
            
        }
        else
        {
            [returnData setValue:@"服务器错误" forKey:@"error"];
        }
        whenComplete(returnData);
    }];
    
}
-(void)followUser:(NSInteger)userIdToFollow withUserId:(NSInteger)myUserId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/follow/%ld",(long)myUserId];
    NSDictionary *param = @{@"followed_id":[NSNumber numberWithInteger:userIdToFollow]};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"POST" api:api parameters:param complete:^(NSDictionary *result, NSError *error) {
        if (result)
        {
            if ([[result objectForKey:@"success"] isEqualToString:@"true"])
            {
                NSArray *data = [result objectForKey:@"data"];
                if (data)
                {
                    [returnData setValue:@"关注成功" forKey:@"data"];
                }
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
            
        }
        else
        {
            [returnData setValue:@"服务器错误" forKey:@"error"];
        }
        whenComplete(returnData);
    }];
}

-(void)unFollowUser:(NSInteger)userIdToUnFollow withUserId:(NSInteger)myUserId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/unfollow/%ld",(long)myUserId];
    NSDictionary *param = @{@"followed_id":[NSNumber numberWithInteger:userIdToUnFollow]};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"POST" api:api parameters:param complete:^(NSDictionary *result, NSError *error) {
        if (result)
        {
            if ([[result objectForKey:@"success"] isEqualToString:@"true"])
            {
                NSArray *data = [result objectForKey:@"data"];
                if (data)
                {
                    [returnData setValue:@"关注成功" forKey:@"data"];
                }
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
            
        }
        else
        {
            [returnData setValue:@"服务器错误" forKey:@"error"];
        }
        whenComplete(returnData);
    }];
}
#pragma mark- search with type [poi,user]
-(void)searchWithType:(NSString *)type keyword:(NSString *)keyword whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/search?type=%@&keyword=%@",type,keyword];
    NSString *encodeApi = [api stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"GET" api:encodeApi parameters:nil complete:^(NSDictionary *result, NSError *error) {
        if (result)
        {
            if ([[result objectForKey:@"success"] isEqualToString:@"true"])
            {
                NSMutableArray *userList = [[NSMutableArray alloc]init];
                NSArray *data = [result objectForKey:@"data"];
                if (data)
                {
                    for (NSDictionary *item in data)
                    {
                        User *user = [[User alloc]initWithAttributes:item];
                        [userList addObject:user];
                    }
                    [returnData setValue:userList forKey:@"data"];
                }
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
            
        }
        else
        {
            [returnData setValue:@"服务器错误" forKey:@"error"];
        }
        whenComplete(returnData);
    }];
}

-(void)explorephotoWithUserId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/explorephoto/%ld",(long)userId];
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:nil complete:^(NSDictionary *result, NSError *error) {
        if (result)
        {
            if ([[result objectForKey:@"success"] isEqualToString:@"true"])
            {
                NSArray *data = [result objectForKey:@"data"];
                NSMutableArray *poiInfo = [[NSMutableArray alloc]init];
                if (data)
                {
                    for (NSDictionary *d in data)
                    {
                        WhatsGoingOn *item  = [[WhatsGoingOn alloc]init];
                        item.postId = [(NSNumber *)[d objectForKey:@"post_id"]integerValue];
                        item.postTime = [d objectForKey:@"create_time"];
                        item.imageUrlString = [d objectForKey:@"photo"];
                        [poiInfo addObject:item];
                    }
                    [returnData setObject:poiInfo forKey:@"data"];
                }
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
            
        }
        else
        {
            [returnData setValue:@"服务器错误" forKey:@"error"];
        }
        whenComplete(returnData);
    }];
}

-(void)feedBackWithUserId:(NSInteger)userId content:(NSString *)content contact:(NSString *)contact whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/feedback"];
    NSDictionary *param = @{@"userId":[NSNumber numberWithInteger:userId],@"content":content,@"contact":contact};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"POST" api:api parameters:param complete:^(NSDictionary *result, NSError *error) {
        if (result)
        {
            if ([result objectForKey:@"success"])
            {
                [returnData setValue:@"反馈成功" forKey:@"data"];
                
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
        }
        else if (error)
        {
            [returnData setValue:@"网络请求失败" forKey:@"error"];
        }
        whenComplete(returnData);
    }];
}

-(void)getNoticeNumWithUserId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/noticeunreadnum/%ld",(long)userId];
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:nil complete:^(NSDictionary *result, NSError *error) {
        if (result)
        {
            if ([result objectForKey:@"success"])
            {
                [returnData setValue:(NSNumber *)[result objectForKey:@"unreadNum"] forKey:@"data"];
                
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
        }
        else if (error)
        {
            [returnData setValue:@"网络请求失败" forKey:@"error"];
        }
        whenComplete(returnData);
    }];
}
-(void)getNoticeWithUserId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/notice/%ld",(long)userId];
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:nil complete:^(NSDictionary *result, NSError *error) {
        if (result)
        {
            if ([result objectForKey:@"success"])
            {
                NSArray *data = [result objectForKey:@"data"];
                NSMutableArray *feeds = [[NSMutableArray alloc]init];
                for (NSDictionary *notice in data)
                {
                    /*
                    {
                        
                        "noticeId": 3,
                        "operatorId": 6,
                        "noticeType": 3,
                        "operatorNick": "哈利小球",
                        "operatorAvatar": "http://7u2ibb.com1.z0.glb.clouddn.com/qdy_avatar_6_1426923010351.jpg/am",
                        "content": null,
                        "photo": "",
                        "postId": null,
                        "createTime": "14小时"
                    },*/
                    Feeds *feed = [[Feeds alloc]init];
                    feed.feedsId = [(NSNumber *)[notice objectForKey:@"noticeId"] integerValue];
                    feed.type = [(NSNumber *)[notice objectForKey:@"noticeType"] integerValue];
                    feed.feedsUser.UserID =[(NSNumber *)[notice objectForKey:@"operatorId"] integerValue];
                    feed.feedsUser.UserName = [notice objectForKey:@"operatorNick"];
                    feed.feedsUser.avatarImageURLString = [notice objectForKey:@"operatorAvatar"];
                    if (! [[notice objectForKey:@"content"]isKindOfClass:[NSNull class]])
                    {
                        feed.content = [notice objectForKey:@"content"];
                    }
                    if (! [[notice objectForKey:@"postId"] isKindOfClass:[NSNull class]])
                    {
                        feed.feedsPhoto.postId = [(NSNumber *)[notice objectForKey:@"postId"]integerValue];
                        feed.feedsPhoto.imageUrlString = [notice objectForKey:@"photo"];
                    }
                    feed.time = [notice objectForKey:@"createTime"];
                    [feeds addObject:feed];
                    
                }
                [returnData setObject:feeds forKey:@"data"];
            }
            else if ([result objectForKey:@"msg"])
            {
                [returnData setValue:[result objectForKey:@"msg"] forKey:@"error"];
            }
            else
            {
                [returnData setValue:@"服务器错误" forKey:@"error"];
            }
            
        }
        else if (error)
        {
            [returnData setValue:@"网络请求失败" forKey:@"error"];
        }
   
        whenComplete(returnData);
    }];
}

#pragma mark - basic method
-(void)setDefaultUserInfoWithUser:(User *)user
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:user.UserID forKey:@"userId"];
    NSLog(@"%@",[userDefaults objectForKey:@"userId"]);
    if (![user.userToken isEqualToString:@""] && user.userToken)
    {
        [userDefaults setObject:user.userToken forKey:@"token"];
    }
    [userDefaults setObject:user.UserName forKey:@"userName"];
    [userDefaults setObject:@"" forKey:@"avatarUrl"];
    NSLog(@"%lu",(long)[userDefaults integerForKey:@"userId"]);
    [userDefaults synchronize];
}
-(void)updateLocalUserInfo
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger userId = [userDefaults integerForKey:@"userId"];
    [[QDYHTTPClient sharedInstance]GetPersonalSimpleInfoWithUserId:userId whenComplete:^(NSDictionary *returnData) {
        if ([returnData objectForKey:@"data"])
        {
            User *user = [returnData objectForKey:@"data"];
            [userDefaults setObject:user.UserName forKey:@"userName"];
            [userDefaults setObject:user.avatarImageURLString forKey:@"avatarUrl"];
        }
        else
        {
            NSLog(@"更新个人信息失败");
            [userDefaults setObject:@"" forKey:@"avatarUrl"];
            
        }
    }];
}
@end
