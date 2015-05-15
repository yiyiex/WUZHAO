//
//  CommentTableViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15-1-8.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "UIImageView+ChangeAppearance.h"
#import "UILabel+ChangeAppearance.h"
#import "UIButton+ChangeAppearance.h"

#import "UIImageView+WebCache.h"
#import "macro.h"

@implementation CommentTableViewCell
-(void)setAppearance
{
   // [self setAutoresizesSubviews:YES];
    [self.userAvatorView setRoundConerWithRadius:self.userAvatorView.frame.size.width/2];
    [self.userAvatorView setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    [self.userName setDarkGreyLabelAppearance];
    [self.userName setFont:WZ_FONT_SMALLP_BOLD_SIZE];
    [self.commentTime setBoldReadOnlyLabelAppearance];
    [self.commentTime setTextAlignment:NSTextAlignmentRight];
}

-(void)configureDataWith:(NSDictionary *)cellData parentController:(UIViewController *)parentController
{
    self.parentController = parentController;
    [self.userAvatorView sd_setImageWithURL:[NSURL URLWithString:[cellData objectForKey:@"avatarUrl"]]];
    self.userName.text = [NSString stringWithFormat:@"%@",[cellData objectForKey:@"userName"]];
    self.commentContent.delegate = (id<CommentTextViewDelegate>)self;
    [self.commentContent setTextWithoutUserNameWithCommentItem:cellData];
    self.commentTime.text =  [cellData objectForKey:@"time"];
    self.commentContent.delegate =(id<CommentTextViewDelegate>) self.parentController;
    [self setAppearance];
    [self configureGesture];
}
-(void)configureGesture
{
    if ([self.parentController respondsToSelector:@selector(avatarClick:)])
    {
        UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc]initWithTarget:self.parentController action:@selector(avatarClick:)];
        UITapGestureRecognizer *userNameTap = [[UITapGestureRecognizer alloc]initWithTarget:self.parentController action:@selector(avatarClick:)];
        [self.userAvatorView addGestureRecognizer:avatarTap];
        [self.userAvatorView setUserInteractionEnabled:YES];
        [self.userName addGestureRecognizer:userNameTap];
        [self.userName setUserInteractionEnabled:YES];
    }
    /*
    if([self.parentController respondsToSelector:@selector(commentClick:)])
    {
        UITapGestureRecognizer *commentTap = [[UITapGestureRecognizer alloc]initWithTarget:self.parentController action:@selector(commentClick:)];
        [self.commentContent addGestureRecognizer:commentTap];
        [self.commentContent setUserInteractionEnabled:YES];
    }*/
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    self.contentView.frame = self.bounds;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // (2)
    [self.contentView updateConstraintsIfNeeded];
    [self.contentView layoutIfNeeded];
    
    // (3)
    //self.commentContent.preferredMaxLayoutWidth = CGRectGetWidth(self.commentContent.frame);
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
