//
//  Feeds.m
//  WUZHAO
//
//  Created by yiyi on 15/4/14.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "Feeds.h"

@implementation Feeds

-(User *)feedsUser
{
    if (!_feedsUser)
    {
        _feedsUser = [[User alloc]init];
    }
    return _feedsUser;
}

-(WhatsGoingOn *)feedsPhoto
{
    if (!_feedsPhoto)
    {
        _feedsPhoto = [[WhatsGoingOn alloc]init];
    }
    return _feedsPhoto;
}

+(NSMutableArray *)getLatestFeeds
{
    NSArray *userList = [[User userList]mutableCopy];
    NSArray *whatsGoingOnList = [[WhatsGoingOn newDataSource]mutableCopy];
    NSMutableArray *allfeeds = [[NSMutableArray alloc]init];
    Feeds *feeds;
    feeds = [[Feeds alloc]init];
    feeds.feedsUser = [userList[0] mutableCopy];
    feeds.type = 0;
    feeds.feedsPhoto = whatsGoingOnList[0];
    feeds.time = @"刚刚";
    [allfeeds addObject:feeds];
    
    feeds = [[Feeds alloc]init];
    feeds.feedsUser = [userList[1] mutableCopy];
    feeds.type = 1;
    feeds.content = @"赞赞的";
    feeds.feedsPhoto = whatsGoingOnList[1];
    feeds.time = @"15小时";
    [allfeeds addObject:feeds];
    
    feeds = [[Feeds alloc]init];
    feeds.feedsUser = [userList[0] mutableCopy];
    feeds.type = 2;
    feeds.feedsPhoto = whatsGoingOnList[0];
    feeds.time = @"2周";
    [allfeeds addObject:feeds];
    
    feeds = [[Feeds alloc]init];
    feeds.feedsUser = [userList[1] mutableCopy];
    feeds.type = 0;
    feeds.feedsPhoto = whatsGoingOnList[2];
    feeds.time = @"4个月";
    [allfeeds addObject:feeds];
    
    feeds = [[Feeds alloc]init];
    feeds.feedsUser = [userList[0] mutableCopy];
    feeds.type = 1;
    feeds.content = @"我想发表一段很长很长的感言，奈何词穷。。。。。。。。。。。。。。。。。。。。。。。。。。。";
    feeds.feedsPhoto = whatsGoingOnList[3];
    feeds.time = @"半年";
    [allfeeds addObject:feeds];
    
    feeds = [[Feeds alloc]init];
    feeds.feedsUser = [userList[1] mutableCopy];
    feeds.type = 2;
    feeds.feedsPhoto = whatsGoingOnList[4];
    feeds.time = @"1年";
    [allfeeds addObject:feeds];
    
    return allfeeds;
}
@end
