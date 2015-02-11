//
//  TheAddress.m
//  WUZHAO
//
//  Created by yiyi on 15-1-5.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "TheAddress.h"

@interface TheAddress()

@property (readwrite ,nonatomic ) NSUInteger addressID;
@property (readwrite ,nonatomic,strong) NSString *addressName;
//@property (readonly,nonatomic,strong) NSURL *avatarImageURLString;

@property (readwrite ,nonatomic) NSUInteger numFollows;
@property (readwrite ,nonatomic) NSUInteger numSharedPeople;
@property (readwrite ,nonatomic) NSUInteger photosNumber;
@property (readwrite ,nonatomic) NSString *addressDescriptions;

@end
@implementation TheAddress

@end
