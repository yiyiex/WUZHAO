//
//  User.h
//  testLogin
//
//  Created by yiyi on 14-11-25.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (readonly,nonatomic ) NSUInteger UserID;
@property (readonly,nonatomic,strong) NSString *UserName;
@property (readonly,nonatomic,strong) NSURL *avatarImageURLString;

@property (readonly,nonatomic) NSUInteger Follows;
@property (readonly,nonatomic) NSUInteger Followers;
@property (readonly,nonatomic) NSUInteger PhotosNumber;
@property (readonly,nonatomic) NSString *SelfDescriptions;

@property (readonly,nonatomic) BOOL isFollowed;

@property (readonly,nonatomic,strong) NSString *userToken;

- (instancetype) initWithAttributes:(NSDictionary *)attributes;
@end
