//
//  NoticeContentTextView.m
//  WUZHAO
//
//  Created by yiyi on 15/5/23.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "NoticeContentTextView.h"
#import "macro.h"

@interface NoticeContentTextView()
{
    NSDictionary *defaultAttributes;
    NSDictionary *highlightedAttributes;
}

@end
@implementation NoticeContentTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)linkUserNameWithUserList:(NSArray *)userList
{
    defaultAttributes = @{NSForegroundColorAttributeName:THEME_COLOR_DARK,NSFontAttributeName:WZ_FONT_COMMON_SIZE};
    highlightedAttributes = @{NSForegroundColorAttributeName:THEME_COLOR_DARKER,NSFontAttributeName:WZ_FONT_COMMON_SIZE};
    [userList enumerateObjectsUsingBlock:^(User *user, NSUInteger idx, BOOL *stop) {
        LinkedStringRangeTapHandler taphandler = ^(NSRange linkStringRange) {
            if ([self.delegate respondsToSelector:@selector(noticeContentTextView:didClickLinkUser:)])
            {
                [self.delegate noticeContentTextView:self didClickLinkUser:user];
            }};
        [self linkTextWithString:user.UserName defaultAttributes:defaultAttributes highlightAttributes:highlightedAttributes tabHandler:taphandler];
    
    }];
}

@end
