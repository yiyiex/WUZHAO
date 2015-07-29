//
//  Comment.m
//  WUZHAO
//
//  Created by yiyi on 15/7/18.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "Comment.h"

@implementation Comment
@synthesize commentId = _commentId,commentString= _commentString,commentUser =_commentUser,createTime = _createTime,content = _content,replyUser=_replyUser,isFailed = _isFailed,postId = _postId;
-(User *)commentUser
{
    if (!_commentUser)
    {
        _commentUser = [[User alloc]init];
    }
    return _commentUser;
}
-(User *)replyUser
{
    if (!_replyUser)
    {
        _replyUser = [[User alloc]init];
    }
    return _replyUser;
}

-(instancetype )initWithDictionary:(NSDictionary *)comment
{
    self = [super init];
    if ([comment objectForKey:@"comment"])
    {
        self.content = [comment objectForKey:@"comment"];
    }
    if ([comment objectForKey:@"comment_id"] )
    {
        self.commentId = [(NSNumber *)[comment objectForKey:@"comment_id"] integerValue];
    }
    if ([comment objectForKey:@"post_id"] )
    {
        self.postId = [(NSNumber *)[comment objectForKey:@"post_id"] integerValue];
    }
    if([comment objectForKey:@"create_time"])
    {
        self.createTime = [comment objectForKey:@"create_time"];
    }
    if ([comment objectForKey:@"post_id"])
    {
        self.postId = [(NSNumber *)[comment objectForKey:@"post_id"]integerValue];
    }
    if ([comment objectForKey:@"nick"])
    {
        self.commentUser.UserName = [comment objectForKey:@"nick"];
    }
    if ([comment objectForKey:@"user_id"])
    {
        self.commentUser.UserID = [(NSNumber *)[comment objectForKey:@"user_id"]integerValue];
    }
    if ([comment objectForKey:@"avatar"])
    {
        self.commentUser.avatarImageURLString = [comment objectForKey:@"avatar"];
    }
    if ([[comment objectForKey:@"replyUserNick"]isEqualToString:@""])
    {
        self.commentString =[NSString stringWithFormat:@"%@: %@",self.commentUser.UserName,self.content];
        
    }
    else
    {
        self.replyUser.UserName = [comment objectForKey:@"replyUserNick"];
        self.replyUser.UserID = [[comment objectForKey:@"replyUserId"]integerValue];
        self.commentString = [NSString stringWithFormat:@"%@ 回复 %@: %@",self.commentUser.UserName,self.replyUser.UserName,self.content];
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    Comment *copy = [[[self class]allocWithZone:zone]init];
    copy->_commentId = _commentId;
    copy->_createTime = [_createTime copy];
    copy->_commentUser = [_commentUser copy];
    copy->_commentString = [_commentString copy];
    copy->_content = [_content copy];
    copy->_replyUser = [_replyUser copy];
    copy->_postId = _postId;
    copy->_isFailed = _isFailed;
    

    return copy;
}
-(id)mutableCopyWithZone:(NSZone *)zone
{
    Comment *copy =[[[self class]allocWithZone:zone]init];
    copy->_commentId = _commentId;
    copy->_createTime = [_createTime mutableCopy];
    copy->_commentUser = [_commentUser mutableCopy];
    copy->_commentString = [_commentString mutableCopy];
    copy->_content = [_content mutableCopy];
    copy->_replyUser = [_replyUser mutableCopy];
    copy->_postId = _postId;
    copy->_isFailed = _isFailed;
    
    return copy;
    
    
}

@end
