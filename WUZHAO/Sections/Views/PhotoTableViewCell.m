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
    
    [self.addressLabel setTextColor:THEME_COLOR_DARK_GREY];
    [self.descriptionLabel setTextColor:THEME_COLOR_DARK_GREY];
    [self.commentClickButton setTintColor:THEME_COLOR_DARK_GREY];
    
    [self.zanClickButton setSmallButtonAppearance];
    [self.zanClickButton setGreyBackGroundAppearance];
    [self.commentClickButton setSmallButtonAppearance];
    [self.commentClickButton setGreyBackGroundAppearance];
    [self.moreButton setSmallButtonAppearance];
    [self.moreButton setGreyBackGroundAppearance];
    
    self.backgroundColor = [UIColor clearColor];
    
    [self.addIcon setHidden:[self.addressLabel.text isEqualToString:@""]?YES:NO];
    [self.descIcon setHidden:[self.descriptionLabel.text isEqualToString:@""]?YES:NO];
    [self.likeIcon setHidden:[self.likeLabel.text isEqualToString:@""]?YES:NO];
    [self.commentIcon setHidden:[self.commentLabel.text isEqualToString:@""]?YES:NO];
    
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
