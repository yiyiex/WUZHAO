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
    [self.userName setFont:WZ_FONT_COMMON_SIZE];
    [self.commentTime setBoldReadOnlyLabelAppearance];
    [self.commentTime setTextAlignment:NSTextAlignmentRight];
}

-(void)configureDataWith:(Comment *)cellData parentController:(UIViewController *)parentController
{
    self.parentController = parentController;
    [self.userAvatorView sd_setImageWithURL:[NSURL URLWithString:cellData.commentUser.avatarImageURLString]];
    self.userName.text = [NSString stringWithFormat:@"%@",cellData.commentUser.UserName];
    self.commentContent.delegate = (id<CommentTextViewDelegate>)self;
    [self.commentContent setTextWithoutUserNameWithCommentItem:cellData];
    CGRect frame = self.commentContent.frame;
    CGSize maxSize = CGSizeMake( WZ_APP_SIZE.width -104.0f, FLT_MAX);
    CGSize newSize = [self.commentContent sizeThatFits:maxSize];
    frame.size.height = newSize.height;
    self.commentContent.frame = frame;
    
    NSLog(@"comment content height%f",self.commentContent.frame.size.height);
    self.commentTime.text =  cellData.createTime;
    if(cellData.isFailed && cellData.commentUser.UserID == [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"])
    {
        [self.infoImage setHidden:NO];
        [self.commentTime setHidden:YES];
    }
    else
    {
        [self.infoImage setHidden:YES];
        [self.commentTime setHidden:NO];
    }
    
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
    if ([self.parentController respondsToSelector:@selector(infoImageClick:)])
    {
        UITapGestureRecognizer *infoImageTap = [[UITapGestureRecognizer alloc]initWithTarget:self.parentController action:@selector(infoImageClick:)];
        [self.infoImage addGestureRecognizer:infoImageTap];
        [self.infoImage setUserInteractionEnabled:YES];
    }
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
