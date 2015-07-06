//
//  User.m
//  testLogin
//
//  Created by yiyi on 14-11-25.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "User.h"
#import "AFHTTPRequestOperation.h"
#import "WhatsGoingOn.h"

@interface User ()

@end
@implementation User
@synthesize UserID,UserName,userToken,avatarImageURLString;
@synthesize numFollowers,numFollows,photosNumber,selfDescriptions,followType;
@synthesize photoList;

-(NSMutableArray *)photoList
{
    if (!photoList)
    {
        photoList = [[NSMutableArray alloc]init];
    }
    return photoList;
}

-(instancetype)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    if (!self)
    {
        return  nil;
    }
    
    self.UserID = [(NSNumber *)[attributes objectForKey:@"user_id"] integerValue];
    if ([attributes objectForKey:@"nick"])
    {
        self.UserName = [attributes objectForKey:@"nick"];
    }
    if ([attributes objectForKey:@"avatar"])
    {
        self.avatarImageURLString = [attributes objectForKey:@"avatar"];
    }
    if ([attributes objectForKey:@"follower_num"])
    {
        self.numFollowers = [(NSNumber *)[attributes objectForKey:@"follower_num"] integerValue];
    }
    if ([attributes objectForKey:@"followed_num"])
    {
        self.numFollows = [(NSNumber *)[attributes objectForKey:@"followed_num"] integerValue];
    }
    if ([attributes objectForKey:@"post_num"])
    {
        self.photosNumber = [(NSNumber *)[attributes objectForKey:@"post_num"] integerValue];
    }
    if ([attributes objectForKey:@"description"])
    {
        self.selfDescriptions = [attributes objectForKey:@"description"];
    }
    if ([attributes objectForKey:@"followType"])
    {
        self.followType =[(NSNumber *)[attributes objectForKey:@"followType"] integerValue];
    }
   // self.photoList = [[NSMutableArray alloc]init];
    if ([attributes objectForKey:@"simplepost_list"])
    {
        for (NSDictionary *item in [attributes objectForKey:@"simplepost_list"])
        {
            WhatsGoingOn *photoItem = [[WhatsGoingOn alloc]initWithAttributes:item];
            [self.photoList addObject:photoItem];
        }
    }
    return self;

}


-(id)copyWithZone:(NSZone *)zone
{
    User *copy = [[[self class]allocWithZone:zone]init];
    copy->UserID = UserID;
    copy->UserName = [UserName copy];
    copy->userToken = [userToken copy];
    copy->selfDescriptions = [selfDescriptions copy];
    copy->avatarImageURLString = [avatarImageURLString copy];
    
    copy->numFollowers = numFollowers;
    copy->numFollows = numFollows;
    copy->photosNumber = photosNumber;
    copy->followType = followType;
    
    copy->photoList = [photoList copy];
    return copy;
    
    
}
-(id)mutableCopyWithZone:(NSZone *)zone
{
    User *copy =[[[self class]allocWithZone:zone]init];
    copy->UserID = UserID;
    copy->UserName = [UserName mutableCopy];
    copy->userToken = [userToken mutableCopy];
    copy->selfDescriptions = [selfDescriptions mutableCopy];
    copy->avatarImageURLString = [avatarImageURLString mutableCopy];
    
    copy->numFollowers = numFollowers;
    copy->numFollows = numFollows;
    copy->photosNumber = photosNumber;
    copy->followType = followType;
    
    copy->photoList = [photoList mutableCopy];
    
    return copy;
    

}

+(NSArray *)userList
{
    NSMutableArray *userList = [[NSMutableArray alloc]init];
    User *user = [[User alloc]initWithAttributes:@{
                                            @"id":@1,
                                            @"UserName":@"小球",
                                            @"avator_imageUrl": @"http://pic1.zhimg.com/9e2cf566532ec4cd24ce0f18b5282c79_l.jpg",
                                            @"follwers":@100,
                                            @"follows":@100,
                                            @"photoNumber":@100,
                                            @"selfDescriptions":@"生活不只是裆下，还有诗和远方",
                                            @"isFollow":@1,
                                            @"photoList":@[]
                                            }];
    [userList addObject:user];
    User *user2 = [[User alloc]initWithAttributes:@{
                                                   @"id":@2,
                                                   @"UserName":@"一一",
                                                   @"avator_imageUrl": @"http://pic4.zhimg.com/88db1114b_l.jpg",
                                                   @"follwers":@100,
                                                   @"follows":@100,
                                                   @"photoNumber":@100,
                                                   @"selfDescriptions":@"",
                                                   @"isFollow":@2,
                                                   @"photoList":@[]
                                                   }];
    [userList addObject:user2];
    return userList;
    
}

@end
