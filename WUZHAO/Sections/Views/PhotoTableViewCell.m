//
//  PhotoTableViewCell.m
//  WUZHAO
//
//  Created by yiyi on 14-12-15.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "PhotoTableViewCell.h"

#import "UIImageView+ChangeAppearance.h"

#import "UIView+ChangeAppearance.h"

#define AvatorImageWidth 38

#define HorizontalInsets 10.0
#define VerticalInsets 10.0

@interface PhotoTableViewCell()



@end

@implementation PhotoTableViewCell

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

-(void)setAppearance
{
    [self.homeCellAvatorImageView setRoundConerWithRadius:19];
    
    [self.addressLabel setTextColor:THEME_COLOR_DARK_GREY];
    [self.descriptionLabel setTextColor:THEME_COLOR_DARK_GREY];
    
    [self.zanView setRoundCornerAppearance];
    [self.zanView setEnableButtonAppearance];
    
    [self.commentView setRoundCornerAppearance];
    [self.commentView setEnableButtonAppearance];
    
    self.commentClickButton.titleLabel.textColor = THEME_COLOR_DARK_GREY;
    self.zanClickButton.titleLabel.textColor = THEME_COLOR_DARK_GREY;
    self.backgroundColor = [UIColor clearColor];
}

-(void) updateConstraints
{
    
    NSLog(@"update constriants");
    NSArray *constraints = self.likeLabelView.constraints;
    for (NSLayoutConstraint *constraint in constraints)
    {
        if (constraint.firstAttribute == NSLayoutAttributeHeight)
        {
            constraint.constant = 0;
        }
        if (constraint.firstAttribute == NSLayoutAttributeBottom)
        {
            constraint.constant = 0;
        }
    }
    
    [super updateConstraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




- (IBAction)zanClick:(id)sender {
}

- (IBAction)CommentClick:(id)sender {
}
@end
