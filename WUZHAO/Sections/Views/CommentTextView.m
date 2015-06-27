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
    self.delegate = nil;
    
}

-(void)setTextWithoutUserNameWithCommentItem:(NSDictionary *)commentItem
{
    [self setTextColor:THEME_COLOR_DARK_GREY_PARENT];
    [self setFont:WZ_FONT_COMMON_SIZE];
    
    defaultAttributes = @{NSForegroundColorAttributeName:THEME_COLOR_DARK_GREY,NSFontAttributeName:WZ_FONT_COMMON_SIZE};
    highlightedAttributes = @{NSForegroundColorAttributeName:THEME_COLOR_DARK_GREY,NSFontAttributeName:WZ_FONT_COMMON_SIZE};
    
    NSString *commentString;
    if ([[commentItem objectForKey:@"replyUserId"]integerValue]>0)
    {
        commentString = [NSString stringWithFormat:@"回复 %@ : %@",[commentItem objectForKey:@"replyUserName"],[commentItem objectForKey:@"content"]];
    }
    else
    {
        commentString = [NSString stringWithFormat:@"%@",[commentItem objectForKey:@"content"]];
    }
    [self setTextWithCommentString:commentString CommentItem:commentItem];
}
-(void)setTextWithCommentStringList:(NSArray *)commentStringList CommentList:(NSArray *)commentList
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineSpacing = 6;
    
    defaultAttributes = @{NSForegroundColorAttributeName:THEME_COLOR_DARK_GREY,NSFontAttributeName:WZ_FONT_COMMON_SIZE,NSParagraphStyleAttributeName:paragraphStyle};
    highlightedAttributes = @{NSForegroundColorAttributeName:THEME_COLOR_DARK_GREY,NSFontAttributeName:WZ_FONT_COMMON_SIZE,NSParagraphStyleAttributeName:paragraphStyle};

    for (NSInteger i = 0;i <commentList.count;i++)
    {
        NSMutableArray *linkStrings = [[NSMutableArray alloc]init];
        NSMutableArray *taphandlers = [[NSMutableArray alloc]init];
        if ([commentList[i] objectForKey:@"userName"])
        {
            [linkStrings addObject:[commentList[i] objectForKey:@"userName"]];
            LinkedStringRangeTapHandler taphandler = ^(NSRange linkStringRange) {
                User *user = [[User alloc]init];
                user.UserID = [[commentList[i] objectForKey:@"userId"]integerValue];
                user.UserName = [commentList[i] objectForKey:@"userName"];
                if ([self.delegate respondsToSelector:@selector(commentTextView:didClickLinkUser:)])
                {
                    [self.delegate commentTextView:self didClickLinkUser:user];
                }};

            [taphandlers addObject:taphandler];
            
        }
    
        if ([commentList[i] objectForKey:@"replyUserName"])
        {
            [linkStrings addObject:[commentList[i] objectForKey:@"replyUserName"]];
            LinkedStringRangeTapHandler taphandler = ^(NSRange linkStringRange) {
                User *user = [[User alloc]init];
                user.UserID = [[commentList[i] objectForKey:@"replyUserId"]integerValue];
                user.UserName = [commentList[i] objectForKey:@"replyUserName"];
                if ([self.delegate respondsToSelector:@selector(commentTextView:didClickLinkUser:)])
                {
                    [self.delegate commentTextView:self didClickLinkUser:user];
                }};
            
            [taphandlers addObject:taphandler];
            
        }
        if (i == 0)
        {
            NSAttributedString *attributedString = [[NSAttributedString alloc]initWithString:commentStringList[i] attributes:@{NSForegroundColorAttributeName:THEME_COLOR_DARK_GREY_PARENT,NSFontAttributeName:WZ_FONT_COMMON_SIZE}];
            [self setText:attributedString linkStrings:linkStrings defaultAttributes:defaultAttributes highlightedAttributes:highlightedAttributes tapHandlers:taphandlers];
        }
        else
        {
            
            NSString *appendString = [NSString stringWithFormat:@"\n%@",commentStringList[i]];
            NSAttributedString *attributedString = [[NSAttributedString alloc]initWithString:appendString attributes:@{NSForegroundColorAttributeName:THEME_COLOR_DARK_GREY_PARENT,NSFontAttributeName:WZ_FONT_COMMON_SIZE}];
            [self appendText:attributedString linkStrings:linkStrings defaultAttributes:defaultAttributes highlightedAttributes:highlightedAttributes tapHandlers:taphandlers];
        }
        
    }
    if (commentStringList.count == 6)
    {
        LinkedStringRangeTapHandler taphandler = ^(NSRange linkStringRange) {
            
            if ([self.delegate respondsToSelector:@selector(moreCommentClick:)])
            {
                [self.delegate moreCommentClick:self];
            }
        };
        
        NSString *commentString = [NSString stringWithFormat:@"\n%@",commentStringList[5]];
        NSAttributedString *appendString = [[NSAttributedString alloc]initWithString:commentString attributes:@{NSForegroundColorAttributeName:THEME_COLOR_DARK_GREY_PARENT,NSFontAttributeName:WZ_FONT_COMMON_SIZE}];
        [self appendText:appendString linkStrings:@[commentStringList[5]] defaultAttributes:defaultAttributes highlightedAttributes:highlightedAttributes tapHandlers:@[taphandler]];
    }

}

-(void)setTextWithCommentString:(NSString *)commentString CommentItem:(NSDictionary *)commentItem
{
    self.text = commentString;
    [self linkUserNamesWithCommentItem:commentItem];
}

-(void)linkUserNamesWithCommentItem:(NSDictionary *)item
{
    if ([item objectForKey:@"userId"])
    {
        [self linkTextWithString:[item objectForKey:@"userName"]  defaultAttributes:defaultAttributes highlightAttributes:highlightedAttributes tabHandler:^(NSRange linkStringRange) {
            User *user = [[User alloc]init];
            user.UserID = [[item objectForKey:@"userId"]integerValue];
            user.UserName = [item objectForKey:@"userName"];
            if ([self.delegate respondsToSelector:@selector(commentTextView:didClickLinkUser:)])
            {
                NSLog(@"comment textview username click");
                [self.delegate commentTextView:self didClickLinkUser:user];
            }
        }];

    }
    if (![[item objectForKey:@"replyUserName"]isEqualToString:@""])
    {
        [self linkTextWithString:[item objectForKey:@"replyUserName"]  defaultAttributes:defaultAttributes highlightAttributes:highlightedAttributes tabHandler:^(NSRange linkStringRange) {
            User *user = [[User alloc]init];
            user.UserID = [[item objectForKey:@"replyUserId"]integerValue];
            user.UserName = [item objectForKey:@"relpyUserName"];
            if ([self.delegate respondsToSelector:@selector(commentTextView:didClickLinkUser:)])
            {
                NSLog(@"comment textview reply username click");
                [self.delegate commentTextView:self didClickLinkUser:user];
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
        if ([self.delegate respondsToSelector:@selector(didClickUnlinedTextOncommentTextView:)])
        {
            [self.delegate didClickUnlinedTextOncommentTextView:self];
            
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
