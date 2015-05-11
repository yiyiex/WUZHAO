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
#import "macro.h"

@implementation CommentTableViewCell
-(void)setAppearance
{
   // [self setAutoresizesSubviews:YES];
    [self.userAvatorView setRoundConerWithRadius:self.userAvatorView.frame.size.width/2];
    [self.userAvatorView setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    [self.userName setDarkGreyLabelAppearance];
    [self.commentContent setReadOnlyLabelAppearance];
    [self.commentContent sizeToFit];
    [self.commentTime setBoldReadOnlyLabelAppearance];
    [self.commentTime setTextAlignment:NSTextAlignmentRight];
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
    self.commentContent.preferredMaxLayoutWidth = CGRectGetWidth(self.commentContent.frame);
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
