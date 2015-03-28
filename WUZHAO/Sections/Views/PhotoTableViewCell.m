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
#import "UILabel+ChangeAppearance.h"
#import "UIButton+ChangeAppearance.h"

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
    [self.homeCellAvatorImageView setRoundConerWithRadius:18];
    [self.homeCellAvatorImageView setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];

    [self.postUserName setDarkGreyLabelAppearance];
    [self.postUserSelfDescription setSmallReadOnlyLabelAppearance];
    [self.postTimeLabel setBoldReadOnlyLabelAppearance];
    
    [self.addressLabelView setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    [self.addressLabel setBlodBlackLabelAppearance];
    
    [self.homeCellImageView setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    
    [self.descriptionLabel setTextColor:[UIColor blackColor]];
    
    [self.likeLabel setThemeLabelAppearance];
    
    [self.zanClickButton setSmallButtonAppearance];
    [self.zanClickButton setGreyBackGroundAppearance];
    [self.commentClickButton setSmallButtonAppearance];
    [self.commentClickButton setGreyBackGroundAppearance];
    [self.moreButton setSmallButtonAppearance];
    [self.moreButton setGreyBackGroundAppearance];
    
    //self.backgroundColor = [UIColor clearColor];
       
}

-(void) updateConstraints
{
    [super updateConstraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
