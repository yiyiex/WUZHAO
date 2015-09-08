//
//  PrivateLetter.h
//  WUZHAO
//
//  Created by yiyi on 15/7/25.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Message : NSObject
@property (nonatomic) NSInteger fromId;
@property (nonatomic) NSInteger toId;
@property (nonatomic) NSInteger messageId;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *createTime;
@property (nonatomic) BOOL isFailed;
@property (nonatomic) NSString *timeStamp;
-(instancetype)initWithDictionary:(NSDictionary *)dic;
@end

@interface Conversation : NSObject
@property (nonatomic, strong) User *me;
@property (nonatomic, strong) User *other;
@property (nonatomic, strong) NSMutableArray *messageList;
@property (nonatomic, strong) Message *latestMsg;
@property (nonatomic) NSInteger newMessageCount;

-(instancetype)initWithDictionary:(NSDictionary *)dic;
-(void)appendMessage:(Message *)message;
@end
