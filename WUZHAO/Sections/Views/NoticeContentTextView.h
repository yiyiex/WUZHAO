//
//  NoticeContentTextView.h
//  WUZHAO
//
//  Created by yiyi on 15/5/23.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "LinkTextView.h"
#import "User.h"

@protocol  NoticeContentTextViewDelegate;

@interface NoticeContentTextView : LinkTextView
@property (nonatomic, weak) id<NoticeContentTextViewDelegate> noticeContentTextViewDelegate;
-(void) linkUserNameWithUserList:(NSArray *)userList;

@end

@protocol NoticeContentTextViewDelegate <NSObject>

-(void) noticeContentTextView:(NoticeContentTextView *)noticeContentTextView didClickLinkUser:(User *)user;
@end
