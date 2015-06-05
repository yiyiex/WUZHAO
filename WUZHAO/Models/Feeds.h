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

typedef NS_ENUM(NSInteger, WZ_FEEDSTYPE)
{
    WZ_FEEDSTYPE_ZAN = 1,
    WZ_FEEDSTYPE_COMMENT = 2,
    WZ_FEEDSTYPE_FOLLOW = 3,
    WZ_FEEDSTYPE_REPLYCOMMENT = 4
};

@interface Feeds : NSObject
@property (nonatomic) NSInteger feedsId;
@property (nonatomic,strong) User *feedsUser;
@property (nonatomic) NSInteger type;  //type  1-赞 2-评论 3-关注 4-回复
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) WhatsGoingOn *feedsPhoto;
@property (nonatomic,strong) NSString *time;
+(NSMutableArray *)getLatestFeeds;
@end
