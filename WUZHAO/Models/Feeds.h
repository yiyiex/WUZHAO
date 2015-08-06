//
//  Feeds.h
//  WUZHAO
//
//  Created by yiyi on 15/4/14.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "WhatsGoingOn.h"
#import "POI.h"

typedef NS_ENUM(NSInteger, WZ_FEEDSTYPE)
{
    WZ_FEEDSTYPE_ZAN = 1,
    WZ_FEEDSTYPE_COMMENT = 2,
    WZ_FEEDSTYPE_FOLLOW = 3,
    WZ_FEEDSTYPE_REPLYCOMMENT = 4,
    WZ_FEEDSTYPE_PRIVATELETTER = 5,
    WZ_FEEDSTYPE_PLACERECOMMEND = 6
};

@interface Feeds : NSObject
@property (nonatomic) NSInteger feedsId;
@property (nonatomic,strong) User *feedsUser;
@property (nonatomic) NSInteger type;  //type  1-赞 2-评论 3-关注 4-回复 5 - 私信 6 - place推荐
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) WhatsGoingOn *feedsPhoto;
@property (nonatomic,strong) NSString *time;
@property (nonatomic, strong) POI *feedsPOI;

+(NSMutableArray *)configureFeedsWithData:(NSArray *)data;
+(NSMutableArray *)getLatestFeeds;
@end
