//
//  User.h
//  testLogin
//
//  Created by yiyi on 14-11-25.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject <NSCopying, NSMutableCopying>

@property (readwrite,nonatomic ) NSInteger UserID;
@property (readwrite,nonatomic,strong) NSString *UserName;
@property (readwrite,nonatomic,strong) NSString *avatarImageURLString;

@property (readwrite,nonatomic) NSInteger numFollows;
@property (readwrite,nonatomic) NSInteger numFollowers;
@property (readwrite,nonatomic) NSInteger photosNumber;
@property (readwrite,nonatomic) NSString *phoneNum;
@property (readwrite,nonatomic) NSString *email;
@property (readwrite,nonatomic) NSString *selfDescriptions;

@property (readonly,nonatomic) BOOL isFollowed;

@property (readwrite,nonatomic,strong) NSString *userToken;

@property (readwrite ,nonatomic ,strong) NSMutableArray *photoList;

- (instancetype) initWithAttributes:(NSDictionary *)attributes;

+(NSArray *)userList;
@end
