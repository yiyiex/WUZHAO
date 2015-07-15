//
//  RecommendUserTableViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/7/14.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "RecommendUserTableViewCell.h"
#import "QDYHTTPClient.h"
#import "UIButton+ChangeAppearance.h"
#import "SVProgressHUD.h"
#import "UIImageView+ChangeAppearance.h"
#import "UIImageView+WebCache.h"
#import "UILabel+ChangeAppearance.h"
#import "macro.h"
#import "PhotoCommon.h"

@implementation RecommendUserTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    [self initView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(User *)cellUser
{
    if (!_cellUser)
    {
        _cellUser = [[User alloc]init];
    }
    return _cellUser;
}

#pragma mark - gesture and action
- (IBAction)followButtonPressed:(UIButton *)sender
{
    NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    if ([sender.titleLabel.text  isEqualToString:@"关注"])
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[QDYHTTPClient sharedInstance]followUser:self.cellUser.UserID withUserId:myUserId whenComplete:^(NSDictionary *result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([result objectForKey:@"data"])
                    {
                        //[SVProgressHUD showInfoWithStatus:@"关注成功"];
                        [sender setHidden:NO];
                        [sender setTitle:@"已关注" forState:UIControlStateNormal];
                        [sender setThemeBackGroundAppearance];
                        
                    }
                    else if ([result objectForKey:@"error"])
                    {
                        [SVProgressHUD showErrorWithStatus:[result objectForKey:@"error"]];
                    }
                });
                
            }];
        });
        
    }
    else if ([sender.titleLabel.text  isEqualToString:@"已关注"]||[sender.titleLabel.text  isEqualToString:@"互相关注"])
    {
        NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[QDYHTTPClient sharedInstance]unFollowUser:self.cellUser.UserID withUserId:myUserId whenComplete:^(NSDictionary *result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([result objectForKey:@"data"])
                    {
                        //[SVProgressHUD showInfoWithStatus:@"关注成功"];
                        [sender setHidden:NO];
                        [sender setTitle:@"关注" forState:UIControlStateNormal];
                        [sender setThemeFrameAppearence];
                        
                    }
                    else if ([result objectForKey:@"error"])
                    {
                        [SVProgressHUD showErrorWithStatus:[result objectForKey:@"error"]];
                    }
                });
            }];
        });
    }
}



#pragma mark - basic method
-(void)initView
{
    [self.titleView setBackgroundColor:THEME_COLOR_LIGHT_GREY_MORE_PARENT];
    
    [self.titleLabel setFont:WZ_FONT_SMALL_SIZE];
    [self.titleLabel setTextColor:THEME_COLOR_DARKER_GREY_PARENT];
    [self.titleLabel setText:@"可能感兴趣的人"];
    [PhotoCommon drawALineWithFrame:CGRectMake(0, 88 , self.contentView.frame.size.width, 12) andColor:THEME_COLOR_LIGHT_GREY_MORE_PARENT inLayer:self.contentView.layer];
    
    [self.avatorImageView setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    [self.userNameLabel setDarkGreyLabelAppearance];
    [self.userDescriptionLabel setSmallReadOnlyLabelAppearance];
}

-(void)setAppearance
{
    if ([self.userDescriptionLabel.text isEqualToString:@""])
    {
        [self.userNameLabelTopAlignment setConstant:10.0f];
    }
    else
    {
        [self.userNameLabelTopAlignment setConstant:2.0f];
    }
}

-(void)configWithUser:(User *)user
{
    self.cellUser = user;
    self.userNameLabel.text = user.UserName;
    self.userDescriptionLabel.text = user.selfDescriptions;
    
    NSInteger myUserId =  [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    
    [self.avatorImageView sd_setImageWithURL:[NSURL URLWithString:user.avatarImageURLString]];
    [self.avatorImageView setRoundConerWithRadius:self.avatorImageView.frame.size.width/2];
    [self.followButton setNormalButtonAppearance];
    if (user.UserID == myUserId)
    {
        [self.followButton setHidden:YES];
    }
    else
    {
        [self.followButton setHidden:NO];
        if (user.followType == FOLLOWED)
        {
            [self.followButton setTitle:@"已关注" forState:UIControlStateNormal];
            [self.followButton setThemeBackGroundAppearance];
        }
        else if (user.followType == FOLLOWEACH)
        {
            [self.followButton setTitle:@"互相关注" forState:UIControlStateNormal];
            [self.followButton setThemeBackGroundAppearance];
        }
        else if (user.followType == UNFOLLOW)
        {
            [self.followButton setTitle:@"关注" forState:UIControlStateNormal];
            [self.followButton setThemeFrameAppearence];
        }
    }
    
    [self setAppearance];
}


@end
