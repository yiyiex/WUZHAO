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
#import "Comment.h"

@protocol CommentTextViewDelegate;

@interface CommentTextView : LinkTextView

@property (nonatomic, weak) id<CommentTextViewDelegate> delegate;

-(void)reset;

-(void)setTextWithoutUserNameWithCommentItem:(Comment *)commentItem;
-(void)setTextWithCommentList:(NSArray *)commentList withMoreItem:(NSInteger)moreCount;
-(void)setTextWithComment:(Comment *)comment;
@end

@protocol CommentTextViewDelegate <NSObject>

-(void)commentTextView:(CommentTextView *)commentTextView didClickLinkUser:(User *)user;

@optional
-(void)moreCommentClick:(CommentTextView *)commentTextView;
-(void)didClickUnlinedTextOncommentTextView:(CommentTextView *)commentTextView;

@end
