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

@property (readwrite,nonatomic) NSUInteger UserID;
@property (readwrite,nonatomic,weak) NSString *UserName;
@property (readwrite,nonatomic,weak) NSURL *avatarImageURLString;


@end
@implementation User
-(instancetype)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    if (!self)
    {
        return  nil;
    }
    self.UserID = (NSUInteger)[[attributes valueForKeyPath:@"id"] integerValue];
    self.UserName = [attributes valueForKeyPath:@"UserName"];
    self.avatarImageURLString = [attributes valueForKeyPath:@"avator_image.url"];
    return self;

}

@end
