//
//  SubjectItemWithPostTableViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/8/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "SubjectItemWithPostTableViewCell.h"
#import "macro.h"
#import "UILabel+ChangeAppearance.h"
#import "UIImageView+ChangeAppearance.h"
#import "UIImageView+WebCache.h"
#import "PhotoCommon.h"


@implementation SubjectItemWithPostTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self initViews];
}

-(void)initViews
{
    [self.title setDarkGreyLabelAppearance];
    [self.title setFont:WZ_FONT_HIRAGINO_SMALL_SIZE];
    
    [self.postUserAvatar setRoundConerWithRadius:self.postUserAvatar.frame.size.width/2];
    [self.postUserAvatar setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    
    [self.postUserName setDarkGreyLabelAppearance];
    [self.postUserDescription setSmallReadOnlyLabelAppearance];
    [self.postTime setBoldReadOnlyLabelAppearance];
    [self.postTime setHidden:YES];
    [self.photoDescription setDarkGreyLabelAppearance];
    
    [self.followButton setTitle:@"" forState:UIControlStateNormal];
    [self.followButton setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureWithContent:(SubjectPost *)subjectPost
{
    self.title.text = subjectPost.title;
    [self.postUserAvatar sd_setImageWithURL:[NSURL URLWithString:subjectPost.userInfo.avatarImageURLString]];
    [self.postUserName setText:subjectPost.userInfo.UserName];
    [self.postUserDescription setText:subjectPost.userInfo.selfDescriptions];
    [self.postTime setText:subjectPost.createTime];
    [self.photo sd_setImageWithURL:[NSURL URLWithString:subjectPost.photoUrlString]];
    [self.photoDescription setText:subjectPost.subjectPhotoDescription];
    if (subjectPost.userInfo.followType == UNFOLLOW && subjectPost.userInfo.UserID !=[[NSUserDefaults standardUserDefaults]integerForKey:@"userId"])
    {
        [self.followButton setHidden:NO];
        //[self.postTime setHidden:YES];
    }
    else
    {
        [self.followButton setHidden:YES];
       // [self.postTime setHidden:NO];
    }
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.photoDescription.frame;
    CGSize newSize = [self.photoDescription sizeThatFits:CGSizeMake(WZ_APP_SIZE.width -16, MAXFLOAT)];
    frame.size.height = newSize.height;
    frame.size.width = WZ_APP_SIZE.width - 16;
    [self.photoDescription setFrame:frame];

}


@end
