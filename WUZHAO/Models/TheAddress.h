//
//  TheAddress.h
//  WUZHAO
//
//  Created by yiyi on 15-1-5.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TheAddress : NSObject

@property (readonly,nonatomic ) NSUInteger addressID;
@property (readonly,nonatomic,strong) NSString *addressName;
//@property (readonly,nonatomic,strong) NSURL *avatarImageURLString;

@property (readonly,nonatomic) NSUInteger numFollows;
@property (readonly,nonatomic) NSUInteger numSharedPeople;
@property (readonly,nonatomic) NSUInteger photosNumber;
@property (readonly,nonatomic) NSString *addressDescriptions;


@property (readonly,nonatomic) BOOL isFollowed;

@end
