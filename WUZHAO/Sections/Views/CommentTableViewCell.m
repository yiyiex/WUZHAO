//
//  CommentTableViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15-1-8.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "CommentTableViewCell.h"

@implementation CommentTableViewCell

-(instancetype)init
{

    self = [super init];
    self.userAvatorView = [[RoundImageView alloc]initWithFrame:CGRectMake(10.0f, 10.0f, 40.0f, 40.0f)];
    [self.contentView addSubview:self.userAvatorView];
    self.userName = [[UIBlackLabel alloc]initWithFrame:CGRectMake(65.0f, 10.0f,100.0f, 20.0f)];
    [self.contentView  addSubview:self.userName];
    self.commentContent = [[UIReadOnlyLabel alloc]initWithFrame:CGRectMake(65.0f, 20.0f,self.frame.size.width -60.0f -10.0f,60.0f)];
    //[self.commentContent sizeToFit];
    [self.contentView  addSubview:self.commentContent];

    return self;
}

-(RoundImageView *)userAvatorView
{
    if (!_userAvatorView)
    {
        _userAvatorView = [[RoundImageView alloc]initWithFrame:CGRectMake(10.0f, 10.0f, 40.0f, 40.0f)];
        [self.contentView addSubview:_userAvatorView];
    }
    return _userAvatorView;
}

-(UIReadOnlyLabel *)commentContent
{
    if (!_commentContent)
    {
        _commentContent = [[UIReadOnlyLabel alloc]initWithFrame:CGRectMake(65.0f, 20.0f,self.frame.size.width -60.0f -10.0f,60.0f)];
        _commentContent.numberOfLines = 0;
        //[_commentContent sizeToFit];
        [self.contentView addSubview:_commentContent];
    }
    return _commentContent;
}

-(UIBlackLabel *)userName
{
    if (!_userName)
    {
        _userName = [[UIBlackLabel alloc]initWithFrame:CGRectMake(65.0f, 10.0f,100.0f, 20.0f)];
        [self.contentView addSubview:_userName];
    }
    return _userName;
}

-(UIThemeLabel *)commentTime
{
    if (!_commentTime)
    {
        _commentTime = [[UIThemeLabel alloc]initWithFrame:CGRectMake(self.frame.size.width-70, 10.0f, 60.0f, 20.0f)];
        [self.contentView addSubview:_commentTime];
    }
    return _commentTime;
}




- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
