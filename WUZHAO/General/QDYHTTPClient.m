//
//  QDYHTTPClient.m
//  WUZHAO
//
//  Created by yiyi on 15/2/11.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "QDYHTTPClient.h"

#define KAPIHOST @"http://qiudaoyu.sinaapp.com/"
//#define KAPIHOST @"http://192.168.1.103/wuzhao/"

@implementation QDYHTTPClient
+(QDYHTTPClient*)sharedInstance
{
    static QDYHTTPClient *sharedInstance = nil;
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
    NSDictionary *userDic = @{@"email":UserName,@"pwd":Password};
    return [[QDYHTTPClient sharedInstance] POST:@"api/login" parameters:userDic success:^(NSURLSessionDataTask *task, id responseObject)
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
                        self.currentUser.userToken = [data objectForKey:@"token"];
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
                complete(nil,error);
            }];
    
    
    
}


- (NSURLSessionDataTask *) RegisterWithUserName:(NSString *)userName email:(NSString *)email password:(NSString *)password complete:(void (^) (NSDictionary *result ,NSError *error))complete
{
    NSString *api = @"api/register";
    NSDictionary *userDic = @{@"nick":userName,@"email":email,@"pwd":password};
    return [[QDYHTTPClient sharedInstance] POST:api parameters:userDic success:^(NSURLSessionDataTask *task, id responseObject)
            {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
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
    NSString *api = [NSString stringWithFormat:@"api/uploadauth/",(long)userId];
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
- (void) GetQiNiuTokenWithUserId:(NSInteger)userId type:(NSInteger)type whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/uploadauth"];
    //NSDictionary *userDic = @{@"nick":@"",@"mobile":@"",@"pwd":@""};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    NSDictionary *param = @{@"userid":[NSNumber numberWithInt:userId],@"type":[NSNumber numberWithInt:type]};
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:param complete:^(NSDictionary *result, NSError *error) {
        if (result)
        {
            NSDictionary *data = [result objectForKey:@"data"];
            if (data)
            {
                NSMutableDictionary *tokenData = [[NSMutableDictionary alloc]init];
                [tokenData setValue:[data objectForKey:@"upload_token"] forKey:@"uploadToken"];
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
                
                for (NSDictionary *item in photoList)
                {
                    NSMutableDictionary *photoItem = [[NSMutableDictionary alloc]init];
                    [photoItem setObject:[item objectForKey:@"post_id"] forKey:@"postId"];
                    [photoItem setObject:[item objectForKey:@"create_time"] forKey:@"time"];
                    [photoItem setObject:[item objectForKey:@"photo"] forKey:@"photoUrl"];
                    [user.photoList addObject:photoItem];
                    
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
    //NSString *api = [NSString stringWithFormat:@"api/*******%ld",(long)userId];
    //NSDictionary *param = @{@"user_id":[NSNumber numberWithInteger:userId]};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    whenComplete(returnData);
}

-(void)GetPersonalAddressListWithUserId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    //NSString *api = [NSString stringWithFormat:@"api/*******%ld",(long)userId];
    //NSDictionary *param = @{@"user_id":[NSNumber numberWithInteger:userId]};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    whenComplete(returnData);
}

-(void )GetPersonalFollowersListWithUserId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"/api/guanzhuzhe/%ld",(long)userId];
    //NSDictionary *param = @{@"user_id":[NSNumber numberWithInteger:userId]};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:nil complete:^(NSDictionary *result, NSError *error) {
        NSMutableArray *userList = [[NSMutableArray alloc]init];
        if ([result objectForKey:@"success"])
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
            else
            {
                [returnData setValue:@"接口请求失败" forKey:@"error"];
            }
            
        }
        else
        {
            [returnData setValue:@"服务器错误" forKey:@"error"];
        }
        whenComplete(returnData);
        
    }];
    
}

-(void )GetPersonalFollowsListWithUserId:(NSInteger)userId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/guanzhule/%ld",(long)userId];
    //NSDictionary *param = @{@"user_id":[NSNumber numberWithInteger:userId]};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:nil complete:^(NSDictionary *result, NSError *error) {
        NSMutableArray *userList = [[NSMutableArray alloc]init];
        if ([result objectForKey:@"success"])
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
            else
            {
                [returnData setValue:@"接口请求失败" forKey:@"error"];
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
        if ([result objectForKey:@"data"])
        {
            [returnData setValue:@"上传头像成功" forKey:@"data"];
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
     NSDictionary *param = @{@"user_id":[NSNumber numberWithInteger:userId]};
    //NSDictionary *param = @{@"user_id":@"2",@"post_id":@"1"};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"POST" api:api parameters:param complete:^(NSDictionary *result, NSError *error) {
        if ([result objectForKey:@"success"])
        {
            NSArray *data = [result objectForKey:@"data"];
            if (data)
            {
                [returnData setValue:@"点赞成功" forKey:@"data"];
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
-(void)CancelZanPhotoWithUserId:(NSInteger)userId postId:(NSInteger)postId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/unlike/%ld",(long)postId];
    NSDictionary *param = @{@"user_id":[NSNumber numberWithInteger:userId]};
    //NSDictionary *param = @{@"user_id":@"2",@"post_id":@"1"};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"POST" api:api parameters:param complete:^(NSDictionary *result, NSError *error) {
        if ([result objectForKey:@"success"])
        {
            NSArray *data = [result objectForKey:@"data"];
            if (data)
            {
                [returnData setValue:@"点赞成功" forKey:@"data"];
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

-(void)GetPhotoZanUserListWithPostId:(NSInteger)postId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"api/like/%ld",(long)postId];
    //NSDictionary *param = @{@"user_id":[NSNumber numberWithInteger:userId]};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:nil complete:^(NSDictionary *result, NSError *error) {
        NSMutableArray *userList = [[NSMutableArray alloc]init];
        if ([result objectForKey:@"success"])
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
            else
            {
                [returnData setValue:@"接口请求失败" forKey:@"error"];
            }
            
        }
        else
        {
            [returnData setValue:@"服务器错误" forKey:@"error"];
        }
        whenComplete(returnData);
        
    }];
}

-(void)CommentPhotoWithUserId:(NSInteger)userId postId:(NSInteger)postId comment:(NSString *)comment whenComplete:(void (^)(NSDictionary *))whenComplete
{
    // NSString *api = [NSString stringWithFormat:@"api/comment/%ld",(long)postId];
    //NSDictionary *param = @{@"user_id":[NSNumber numberWithInteger:self.currentUser.UserID],@"post_id":[NSNumber numberWithInteger:postId],@"comment":comment};
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    whenComplete(returnData);
}

-(void)GetPhotoInfoWithPostId:(NSInteger)postId whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"/api/post/%ld",(long)postId];
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:nil complete:^(NSDictionary *result, NSError *error) {
    if ([result objectForKey:@"success"])
        {
            WhatsGoingOn *postItem = [[WhatsGoingOn alloc]init];
            NSDictionary *data = [result objectForKey:@"data"];
            if (data)
            {
                postItem.postId =[(NSNumber *)[data objectForKey:@"post_id"] integerValue];
                
                
                postItem.photoUser.UserID = [(NSNumber *)[data objectForKey:@"user_id"]integerValue];
                postItem.photoUser.UserName = [data objectForKey:@"nick"];
                postItem.photoUser.avatarImageURLString = [data objectForKey:@"avatar"];
                postItem.photoUser.selfDescriptions = [data objectForKey:@"description"];
                
                
                postItem.postTime = [data objectForKey:@"create_time"];
                postItem.imageUrlString = [data objectForKey:@"photo"];
                postItem.imageDescription = [data objectForKey:@"thought"];
                postItem.likeCount = [(NSNumber *)[data objectForKey:@"like_num"] integerValue];
                
                postItem.commentNum = [(NSNumber *)[data objectForKey:@"comment_num"]integerValue];
                
                postItem.poiId = [(NSNumber *)[data objectForKey:@"poi_id"] integerValue];
                postItem.poiName = [data objectForKey:@"poi_name"];
                
                
                if ([[data objectForKey:@"more_comments"] isEqualToString:@"false"])
                {
                    postItem.hasMoreComments =  NO;
                }
                else
                {
                    postItem.hasMoreComments = YES;
                }
                NSMutableString *commentString = [[NSMutableString alloc]init];
                NSMutableArray *commentList = [[NSMutableArray alloc]init];
                NSArray *commentListInData = [data objectForKey:@"comment_list"];
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
                postItem.comment = [commentString mutableCopy];
                postItem.commentList = [commentList mutableCopy];
                
               // postItem.photoUser
                [returnData setValue:postItem forKey:@"data"];
                
            }
            else
            {
                [returnData setValue:@"接口请求失败" forKey:@"error"];
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
        if ([result objectForKey:@"success"])
        {
            NSArray *data = [result objectForKey:@"data"];
            if (data)
            {
                [returnData setValue:@"关注成功" forKey:@"data"];
            }
            else
            {
                [returnData setValue:@"接口请求失败" forKey:@"error"];
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
        if ([result objectForKey:@"success"])
        {
            NSArray *data = [result objectForKey:@"data"];
            if (data)
            {
                [returnData setValue:@"关注成功" forKey:@"data"];
            }
            else
            {
                [returnData setValue:@"接口请求失败" forKey:@"error"];
            }
            
        }
        else
        {
            [returnData setValue:@"服务器错误" forKey:@"error"];
        }
        whenComplete(returnData);
    }];
}

-(void)searchWithType:(NSString *)type keyword:(NSString *)keyword whenComplete:(void (^)(NSDictionary *))whenComplete
{
    NSString *api = [NSString stringWithFormat:@"/api/search?type=%@&keyword=%@",type,keyword];
    NSMutableDictionary *returnData = [[NSMutableDictionary alloc]init];
    [self ExecuteRequestWithMethod:@"GET" api:api parameters:nil complete:^(NSDictionary *result, NSError *error) {
        if ([result objectForKey:@"success"])
        {
            NSArray *data = [result objectForKey:@"data"];
            if (data)
            {
                [returnData setValue:data forKey:@"data"];
            }
            else
            {
                [returnData setValue:@"接口请求失败" forKey:@"error"];
            }
            
        }
        else
        {
            [returnData setValue:@"服务器错误" forKey:@"error"];
        }
        whenComplete(returnData);
    }];
}

@end
