//
//  SubjectItemWithoutPostTableViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/8/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "SubjectItemWithoutPostTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "macro.h"
#import "UILabel+ChangeAppearance.h"
#import "PhotoCommon.h"


@implementation SubjectItemWithoutPostTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self initViews];
}
-(void)initViews
{
    [self.title setDarkGreyLabelAppearance];
    [self.title setFont:WZ_FONT_LARGE_SIZE];
    
    [self.photoDescription setDarkGreyLabelAppearance];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureWithContent:(SubjectPost *)subjectPost
{
    [self.photo sd_setImageWithURL:[NSURL URLWithString:subjectPost.photoUrlString]];
    [self.photoDescription setText:subjectPost.subjectPhotoDescription];
    self.title.text = subjectPost.title;
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
