//
//  CommentTextView.h
//  WUZHAO
//
//  Created by yiyi on 15/5/6.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "LinkTextView.h"
#import "User.h"
#import "WhatsGoingOn.h"

@protocol CommentTextViewDelegate;

@interface CommentTextView : LinkTextView

@property (nonatomic, weak) id<CommentTextViewDelegate> delegate;

-(void)reset;

-(void)setTextWithoutUserNameWithCommentItem:(NSDictionary *)commentItem;

-(void)setTextWithCommentStringList:(NSArray *)commentStringList CommentList:(NSArray *)commentList;

-(void)setTextWithCommentString:(NSString *)CommentString CommentItem:(NSDictionary *)commentItem;


@end

@protocol CommentTextViewDelegate <NSObject>

-(void)commentTextView:(CommentTextView *)commentTextView didClickLinkUser:(User *)user;
-(void)didClickUnlinedTextOncommentTextView:(CommentTextView *)commentTextView;
-(void)moreCommentClick:(CommentTextView *)commentTextView;

@end
