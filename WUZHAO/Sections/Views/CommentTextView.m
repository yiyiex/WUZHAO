//
//  CommentTextView.m
//  WUZHAO
//
//  Created by yiyi on 15/5/6.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "CommentTextView.h"
#import "User.h"
#import "macro.h"


@interface CommentTextView()
{
    NSDictionary *defaultAttributes;
    NSDictionary *highlightedAttributes;
    
}


@end
@implementation CommentTextView
@synthesize delegate;


-(void)reset
{
    [super reset];
    self.commentTextViewDelegate = nil;
    
}

-(void)setTextWithoutUserNameWithCommentItem:(Comment *)commentItem
{
    [self setTextColor:THEME_COLOR_DARK_GREY_PARENT];
    [self setFont:WZ_FONT_COMMON_SIZE];
    
    defaultAttributes = @{NSForegroundColorAttributeName:THEME_COLOR_DARK_GREY,NSFontAttributeName:WZ_FONT_COMMON_SIZE};
    highlightedAttributes = @{NSForegroundColorAttributeName:THEME_COLOR_DARK_GREY,NSFontAttributeName:WZ_FONT_COMMON_SIZE};
    Comment *newComment = [commentItem mutableCopy];
    if (newComment.replyUser && newComment.replyUser.UserID >0)
    {
        newComment.commentString = [NSString stringWithFormat:@"回复 %@ : %@",newComment.replyUser.UserName,newComment.content];
    }
    else
    {
        newComment.commentString = [NSString stringWithFormat:@"%@",newComment.content];
    }
    [self linkUserNamesWithComment:newComment];
}
-(void)setTextWithCommentList:(NSArray *)commentList withMoreItem:(NSInteger)moreCount
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineSpacing = 6;
    
    defaultAttributes = @{NSForegroundColorAttributeName:THEME_COLOR_DARK_GREY,NSFontAttributeName:WZ_FONT_COMMON_SIZE,NSParagraphStyleAttributeName:paragraphStyle};
    highlightedAttributes = @{NSForegroundColorAttributeName:THEME_COLOR_DARK_GREY,NSFontAttributeName:WZ_FONT_COMMON_SIZE,NSParagraphStyleAttributeName:paragraphStyle};

    for (NSInteger i = 0;i <commentList.count;i++)
    {
        Comment *comment = commentList[i];
        NSMutableArray *linkStrings = [[NSMutableArray alloc]init];
        NSMutableArray *taphandlers = [[NSMutableArray alloc]init];
        if (comment.commentUser.UserName)
        {
            [linkStrings addObject:comment.commentUser.UserName];
            LinkedStringRangeTapHandler taphandler = ^(NSRange linkStringRange) {
                if ([self.commentTextViewDelegate respondsToSelector:@selector(commentTextView:didClickLinkUser:)])
                {
                    [self.commentTextViewDelegate commentTextView:self didClickLinkUser:comment.commentUser];
                }};
            [taphandlers addObject:taphandler];
            
        }
    
        if (comment.replyUser.UserName)
        {
            [linkStrings addObject:comment.replyUser.UserName];
            LinkedStringRangeTapHandler taphandler = ^(NSRange linkStringRange) {
                if ([self.commentTextViewDelegate respondsToSelector:@selector(commentTextView:didClickLinkUser:)])
                {
                    [self.commentTextViewDelegate commentTextView:self didClickLinkUser:comment.replyUser];
                }};
            
            [taphandlers addObject:taphandler];
            
        }
        if (i == 0)
        {
            NSAttributedString *attributedString = [[NSAttributedString alloc]initWithString:comment.commentString attributes:@{NSForegroundColorAttributeName:THEME_COLOR_DARK_GREY_PARENT,NSFontAttributeName:WZ_FONT_COMMON_SIZE}];
            [self setText:attributedString linkStrings:linkStrings defaultAttributes:defaultAttributes highlightedAttributes:highlightedAttributes tapHandlers:taphandlers];
        }
        else
        {
            
            NSString *appendString = [NSString stringWithFormat:@"\n%@",comment.commentString];
            NSAttributedString *attributedString = [[NSAttributedString alloc]initWithString:appendString attributes:@{NSForegroundColorAttributeName:THEME_COLOR_DARK_GREY_PARENT,NSFontAttributeName:WZ_FONT_COMMON_SIZE}];
            [self appendText:attributedString linkStrings:linkStrings defaultAttributes:defaultAttributes highlightedAttributes:highlightedAttributes tapHandlers:taphandlers];
        }

        
    }
    if (moreCount>5)
    {
        LinkedStringRangeTapHandler taphandler = ^(NSRange linkStringRange) {
            
            if ([self.commentTextViewDelegate respondsToSelector:@selector(moreCommentClick:)])
            {
                [self.commentTextViewDelegate moreCommentClick:self];
            }
        };
        
        NSString *commentString = [NSString stringWithFormat:@"\n查看全部%ld条评论",(long)moreCount];
        NSAttributedString *appendString = [[NSAttributedString alloc]initWithString:commentString attributes:@{NSForegroundColorAttributeName:THEME_COLOR_DARK_GREY_PARENT,NSFontAttributeName:WZ_FONT_COMMON_SIZE}];
        [self appendText:appendString linkStrings:@[commentString] defaultAttributes:defaultAttributes highlightedAttributes:highlightedAttributes tapHandlers:@[taphandler]];
    }


}

-(void)linkUserNamesWithComment:(Comment *)comment
{
    self.text = comment.commentString;
    if (comment.commentUser.UserName)
    {
        [self linkTextWithString:comment.commentUser.UserName defaultAttributes:defaultAttributes highlightAttributes:highlightedAttributes tabHandler:^(NSRange linkStringRange) {
            if ([self.commentTextViewDelegate respondsToSelector:@selector(commentTextView:didClickLinkUser:)])
            {
                NSLog(@"comment textview username click");
                [self.commentTextViewDelegate commentTextView:self didClickLinkUser:comment.commentUser];
            }
        }];

    }
    if (comment.replyUser && ![comment.replyUser.UserName isEqualToString:@""])
    {
        [self linkTextWithString:comment.replyUser.UserName  defaultAttributes:defaultAttributes highlightAttributes:highlightedAttributes tabHandler:^(NSRange linkStringRange) {
            if ([self.commentTextViewDelegate respondsToSelector:@selector(commentTextView:didClickLinkUser:)])
            {
                NSLog(@"comment textview reply username click");
                [self.commentTextViewDelegate commentTextView:self didClickLinkUser:comment.replyUser];
            }
        }];
    }
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    NSRange tappedStringRange = [self handleTouches:touches];
    if (tappedStringRange.length == 0 && tappedStringRange.location == 0)
    {
        if ([self.commentTextViewDelegate respondsToSelector:@selector(didClickUnlinedTextOncommentTextView:)])
        {
            [self.commentTextViewDelegate didClickUnlinedTextOncommentTextView:self];
            
        }
    }
    
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
