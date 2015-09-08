//
//  PrivateLetter.m
//  WUZHAO
//
//  Created by yiyi on 15/7/25.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "PrivateLetter.h"


@implementation Message

-(instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self)
    {
        if ([dic objectForKey:@"messageId"])
        {
            self.messageId = [(NSNumber *)[dic objectForKey:@"messageId"] integerValue];
        }
        if ([dic objectForKey:@"fromId"])
        {
            self.fromId = [(NSNumber *)[dic objectForKey:@"fromId"] integerValue];
        }
        if ([dic objectForKey:@"toId"])
        {
            self.toId = [(NSNumber *)[dic objectForKey:@"toId"] integerValue];
        }
        if ([dic objectForKey:@"createTime"])
        {
            self.createTime = [dic objectForKey:@"createTime"];
        }
        if ([dic objectForKey:@"content"])
        {
            self.content = [dic objectForKey:@"content"];
        }
        if ([dic objectForKey:@"timeStamp"])
        {
            self.timeStamp = [dic objectForKey:@"timeStamp"];
        }

    }
    return self;
}

@end

@implementation Conversation
-(instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self)
    {
        if ([dic objectForKey:@"me"])
        {
            self.me = [[User alloc]initWithAttributes:[dic objectForKey:@"me"]];
        }
        if ([dic objectForKey:@"nick"])
        {
            self.other = [[User alloc]initWithAttributes:dic];
        }
        else if ([dic objectForKey:@"other"])
        {
            self.other = [[User alloc]initWithAttributes:[dic objectForKey:@"other"]];
        }
        if ([dic objectForKey:@"msgList"])
        {
            NSArray *msgList = [dic objectForKey:@"msgList"];
            if (msgList.count>0)
            {
                [self configureMessageList:[dic objectForKey:@"msgList"]];
            }
        }
        if ([dic objectForKey:@"unReadNum"])
        {
            self.newMessageCount = [(NSNumber *)[dic objectForKey:@"unReadNum"]integerValue];
        }

        
    }
    return self;
}

-(User *)me
{
    if (!_me)
    {
        _me = [[User alloc]init];
    }
    return _me;
}
-(User *)other
{
    if (!_other)
    {
        _other = [[User alloc]init];
    }
    return _other;
}
-(NSMutableArray *)messageList
{
    if (!_messageList)
    {
        _messageList = [[NSMutableArray alloc]init];
    }
    return _messageList;
}


-(void)configureMessageList:(NSArray *)msgList
{
    NSMutableArray *list = [[NSMutableArray alloc]init];
    NSMutableArray *section = [[NSMutableArray alloc]init];
    [list addObject:section];
    Message *msg = [[Message alloc]initWithDictionary:msgList[0]];
    [section addObject:msg];
    for (NSInteger i = 1;i<msgList.count;i++)
    {
        Message *currentMsg = [[Message alloc]initWithDictionary:msgList[i]];
        Message *beforeMsg = [[Message alloc]initWithDictionary:msgList[i-1]];
        if ([currentMsg.createTime isEqualToString:beforeMsg.createTime])
        {
            [section addObject:currentMsg];
        }
        else
        {
            section = [[NSMutableArray alloc]init];
            [section addObject:currentMsg];
            [list addObject:section];
        }
    }
    self.messageList = list;
    self.latestMsg = [[Message alloc]initWithDictionary:[msgList lastObject]];
}
-(void)appendMessage:(Message *)message
{
    if ([message.createTime isEqualToString:self.latestMsg.createTime])
    {
        NSMutableArray *lastSection = [self.messageList lastObject];
        [lastSection addObject:message];
    }
    else
    {
        NSMutableArray *newSection = [[NSMutableArray alloc]init];
        [newSection addObject:message];
        [self.messageList addObject:newSection];
    }
    self.latestMsg = message;
}




@end
