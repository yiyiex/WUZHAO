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

-(instancetype)init
{

    self = [super init];
    self.userAvatorView = [[UIImageView alloc]initWithFrame:CGRectMake(10.0f, 10.0f, 40.0f, 40.0f)];
    [self.contentView addSubview:self.userAvatorView];
    self.userName = [[UILabel alloc]initWithFrame:CGRectMake(65.0f, 10.0f,100.0f, 20.0f)];
    [self.contentView  addSubview:self.userName];
    self.commentContent = [[UILabel alloc]initWithFrame:CGRectMake(65.0f, 20.0f,self.frame.size.width -60.0f -10.0f,60.0f)];
    //[self.commentContent sizeToFit];
    [self.contentView  addSubview:self.commentContent];

    return self;
}

-(UIImageView *)userAvatorView
{
    if (!_userAvatorView)
    {
        _userAvatorView = [[UIImageView alloc]initWithFrame:CGRectMake(8.0f, 8.0f, 36.0f, 36.0f)];
        [self.contentView addSubview:_userAvatorView];
    }
    return _userAvatorView;
}

-(UILabel *)commentContent
{
    if (!_commentContent)
    {
        _commentContent = [[UILabel alloc]initWithFrame:CGRectMake(52.0f, 30.0f,self.frame.size.width -52.0f -60.0f,30.0f)];
        _commentContent.numberOfLines = 0;
        //[_commentContent sizeToFit];
        [self.contentView addSubview:_commentContent];
    }
    return _commentContent;
}

-(UILabel *)userName
{
    if (!_userName)
    {
        _userName = [[UILabel alloc]initWithFrame:CGRectMake(52.0f, 10.0f,100.0f, 20.0f)];
        [self.contentView addSubview:_userName];
    }
    return _userName;
}

-(UILabel *)commentTime
{
    if (!_commentTime)
    {
        _commentTime = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width-70, 10.0f, 60.0f, 20.0f)];
        [self.contentView addSubview:_commentTime];
    }
    return _commentTime;
}

-(void)setAppearance
{
    [self.userAvatorView setRoundConerWithRadius:self.userAvatorView.frame.size.width/2];
    [self.userAvatorView setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    [self.userName setDarkGreyLabelAppearance];
    [self.commentContent setReadOnlyLabelAppearance];
    [self.commentTime setBoldReadOnlyLabelAppearance];
    [self.commentTime setTextAlignment:NSTextAlignmentRight];
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
