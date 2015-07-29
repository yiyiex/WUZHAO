//
//  Comment.h
//  WUZHAO
//
//  Created by yiyi on 15/7/18.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"


@interface Comment : NSObject

@property (nonatomic) NSInteger commentId;
@property (nonatomic) NSString  *createTime;
@property (nonatomic) NSInteger postId;
@property (nonatomic, strong) User *commentUser;
@property (nonatomic, strong) NSString *commentString;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) User *replyUser;
@property (nonatomic) BOOL isFailed;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
