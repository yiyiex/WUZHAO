//
//  User.m
//  testLogin
//
//  Created by yiyi on 14-11-25.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "User.h"
#import "AFHTTPRequestOperation.h"

@interface User ()

@end
@implementation User
@synthesize UserID,UserName,userToken,avatarImageURLString;
@synthesize numFollowers,numFollows,photosNumber,selfDescriptions;
@synthesize photoList;

-(instancetype)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    if (!self)
    {
        return  nil;
    }
    
    self.UserID = (NSUInteger)[[attributes valueForKeyPath:@"id"] integerValue];
    self.UserName = [attributes valueForKeyPath:@"UserName"];
    self.avatarImageURLString = [attributes valueForKeyPath:@"avator_imageUrl"];
    self.numFollowers = (NSUInteger)[[attributes valueForKey:@"follwers"] integerValue];
    self.numFollows = (NSUInteger)[[attributes valueForKey:@"follows"] integerValue];
    self.photosNumber = (NSUInteger)[[attributes valueForKey:@"photoNumber"] integerValue];
    self.selfDescriptions = [attributes valueForKey:@"selfDescriptions"];
    self.photoList = [[NSMutableArray alloc]init];
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
    
    copy->photoList = [photoList mutableCopy];
    
    return copy;
    

}





+(NSArray *)userList
{
    NSMutableArray *userList = [[NSMutableArray alloc]init];
    User *user = [[User alloc]initWithAttributes:@{
                                            @"id":@1,
                                            @"UserName":@"xiaoqiu1",
                                            @"avator_imageUrl": @"http://pic1.zhimg.com/9e2cf566532ec4cd24ce0f18b5282c79_l.jpg",
                                            @"follwers":@100,
                                            @"follows":@100,
                                            @"photoNumber":@100,
                                            @"selfDescriptions":@"test description",
                                            }];
    [userList addObject:user];
    User *user2 = [[User alloc]initWithAttributes:@{
                                                   @"id":@2,
                                                   @"UserName":@"xiaoqiu2",
                                                   @"avator_imageUrl": @"http://pic4.zhimg.com/88db1114b_l.jpg",
                                                   @"follwers":@100,
                                                   @"follows":@100,
                                                   @"photoNumber":@100,
                                                   @"selfDescriptions":@"test description",
                                                   }];
    [userList addObject:user2];
    
    
    
    
    
    
    return userList;
    
}

@end
