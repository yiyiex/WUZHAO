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
    [self.title setFont:WZ_FONT_LARGE_SIZE];
    [self.title setScrollEnabled:NO];
    [self.title setEditable:NO];
    
    [self.photoDescription setScrollEnabled:NO];
    [self.photoDescription setEditable:NO];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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


-(void)configureWithContent:(SubjectPost *)subjectPost
{
    NSAttributedString *title = [[NSAttributedString alloc]initWithString:subjectPost.title attributes:self.titleTextAttributes];
    [self.title setAttributedText:title];
    NSAttributedString *photoDescription = [[NSAttributedString alloc]initWithString:subjectPost.subjectPhotoDescription attributes:self.photoDescriptionAttributes];
    [self.photoDescription setAttributedText:photoDescription];
    [self.photoDescription setAttributedText:photoDescription];
    [self.photoDescription setText:subjectPost.subjectPhotoDescription];
    [self updateFrameOfTextView:self.title heightConstraint:self.titleLabelHeightConstraint];
    [self updateFrameOfTextView:self.photoDescription heightConstraint:self.photoDescriptionlHeightConstraint];
    
    [self.photo sd_setImageWithURL:[NSURL URLWithString:subjectPost.photoUrlString]];
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
       // newSize.height +=8;
        frame.size = newSize ;
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
