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

+(NSMutableArray *)configureFeedsWithData:(NSArray *)data
{
    NSMutableArray *feeds = [[NSMutableArray alloc]init];
    
    for (NSDictionary *notice in data)
    {
        if ( [(NSNumber *)[notice objectForKey:@"noticeType"] integerValue] >4 ||[(NSNumber *)[notice objectForKey:@"noticeType"] integerValue]<1)
        {
            break;
        }
        Feeds *feed = [[Feeds alloc]init];
        feed.feedsId = [(NSNumber *)[notice objectForKey:@"noticeId"] integerValue];
        feed.type = [(NSNumber *)[notice objectForKey:@"noticeType"] integerValue];
        feed.feedsUser.UserID =[(NSNumber *)[notice objectForKey:@"operatorId"] integerValue];
        feed.feedsUser.UserName = [notice objectForKey:@"operatorNick"];
        feed.feedsUser.avatarImageURLString = [notice objectForKey:@"operatorAvatar"];
        if (! [[notice objectForKey:@"content"]isKindOfClass:[NSNull class]])
        {
            feed.content = [notice objectForKey:@"content"];
        }
        if (! [[notice objectForKey:@"postId"] isKindOfClass:[NSNull class]])
        {
            feed.feedsPhoto.postId = [(NSNumber *)[notice objectForKey:@"postId"]integerValue];
            feed.feedsPhoto.imageUrlString = [notice objectForKey:@"photo"];
        }
        feed.time = [notice objectForKey:@"createTime"];
        [feeds addObject:feed];
        
    }
    return feeds;
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
