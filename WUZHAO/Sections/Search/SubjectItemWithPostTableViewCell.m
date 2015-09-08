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
-(NSDictionary *)titleTextAttributes
{
    if (!_titleTextAttributes)
    {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineSpacing = 6;
        _titleTextAttributes = @{NSForegroundColorAttributeName:THEME_COLOR_FONT_GREY,NSFontAttributeName:WZ_FONT_COMMON_SIZE,NSParagraphStyleAttributeName:paragraphStyle};
    }
    return _titleTextAttributes;
}
-(NSDictionary *)photoDescriptionAttributes
{
    if (!_photoDescriptionAttributes)
    {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineSpacing = 6;
        _photoDescriptionAttributes = @{NSForegroundColorAttributeName:THEME_COLOR_DARK_GREY,NSFontAttributeName:WZ_FONT_COMMON_SIZE,NSParagraphStyleAttributeName:paragraphStyle};
    }
    return _photoDescriptionAttributes;
}

-(void)initViews
{
    [self.postUserAvatar setRoundConerWithRadius:self.postUserAvatar.frame.size.width/2];
    [self.postUserAvatar setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    
    [self.postUserName setDarkGreyLabelAppearance];
    [self.postUserDescription setSmallReadOnlyLabelAppearance];
    [self.postTime setBoldReadOnlyLabelAppearance];
    [self.postTime setHidden:YES];
    
    [self.followButton setTitle:@"" forState:UIControlStateNormal];
    [self.followButton setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    
    [self.title setScrollEnabled:NO];
    [self.title setEditable:NO];
    
    [self.photoDescription setScrollEnabled:NO];
    [self.photoDescription setEditable:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureWithContent:(SubjectPost *)subjectPost
{
    NSAttributedString *title = [[NSAttributedString alloc]initWithString:subjectPost.title attributes:self.titleTextAttributes];
    [self.title setAttributedText:title];
    [self.title setText:subjectPost.title];
    NSAttributedString *photoDescription = [[NSAttributedString alloc]initWithString:subjectPost.subjectPhotoDescription attributes:self.photoDescriptionAttributes];
    [self.photoDescription setAttributedText:photoDescription];
    [self.photoDescription setText:subjectPost.subjectPhotoDescription];
    [self updateFrameOfTextView:self.title heightConstraint:nil];
    [self updateFrameOfTextView:self.photoDescription heightConstraint:nil];
    
    [self.postUserAvatar sd_setImageWithURL:[NSURL URLWithString:subjectPost.userInfo.avatarImageURLString]];
    [self.postUserName setText:subjectPost.userInfo.UserName];
    [self.postUserDescription setText:subjectPost.userInfo.selfDescriptions];
    [self.postTime setText:subjectPost.createTime];
    [self.photo sd_setImageWithURL:[NSURL URLWithString:subjectPost.photoUrlString]];
    

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

#pragma mark - textview utility
-(void)updateFrameOfTextView:(UITextView *)textView heightConstraint:(NSLayoutConstraint *)heightConstraint
{
    if ([textView.text isEqualToString:@""])
    {
        CGRect frame = textView.frame;
        frame.size.height = 0;
        textView.frame = frame;
        if (heightConstraint)
        {
            [heightConstraint setConstant:0.0f];
        }
    }
    else
    {
        CGRect frame = textView.frame;
        CGSize maxSize = CGSizeMake( WZ_APP_SIZE.width -8.0f, FLT_MAX);
        CGSize newSize = [textView sizeThatFits:maxSize];
        //newSize.height +=8;
        frame.size = newSize;
        textView.frame = frame;
        if (heightConstraint)
        {
            [heightConstraint setConstant:newSize.height];
        }
    }
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self updateFrameOfTextView:self.title heightConstraint:self.titleLabelHeightConstraint];
    [self updateFrameOfTextView:self.photoDescription heightConstraint:self.photoDescriptionlHeightConstraint];
    
}




@end
