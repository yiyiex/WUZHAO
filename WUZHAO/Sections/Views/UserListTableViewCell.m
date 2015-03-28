//
//  UserListTableViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15-1-5.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "UserListTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+ChangeAppearance.h"

#import "UILabel+ChangeAppearance.h"
#import "UIButton+ChangeAppearance.h"
#import "UIImageView+ChangeAppearance.h"

#import "MineViewController.h"

#import "macro.h"

#import "QDYHTTPClient.h"
#import "SVProgressHUD.h"

#define AVATARIMAGEWIDTH 36
@interface UserListTableViewCell()
@property (nonatomic,strong) User *cellUser;
@end
@implementation UserListTableViewCell

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}
- (void)awakeFromNib {
    // Initialization code
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
        [[QDYHTTPClient sharedInstance]followUser:self.cellUser.UserID withUserId:myUserId whenComplete:^(NSDictionary *result) {
            if ([result objectForKey:@"data"])
            {
                //[SVProgressHUD showInfoWithStatus:@"关注成功"];
                [sender setTitle:@"已关注" forState:UIControlStateNormal];
                
            }
            else if ([result objectForKey:@"error"])
            {
                [SVProgressHUD showErrorWithStatus:[result objectForKey:@"error"]];
            }
        }];
    }
    else if ([sender.titleLabel.text  isEqualToString:@"已关注"])
    {
        NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
        [[QDYHTTPClient sharedInstance]unFollowUser:self.cellUser.UserID withUserId:myUserId whenComplete:^(NSDictionary *result) {
            if ([result objectForKey:@"data"])
            {
                //[SVProgressHUD showInfoWithStatus:@"关注成功"];
                [sender setTitle:@"关注" forState:UIControlStateNormal];
                
            }
            else if ([result objectForKey:@"error"])
            {
                [SVProgressHUD showErrorWithStatus:[result objectForKey:@"error"]];
            }
        }];
    }
}



#pragma mark - basic method

-(void)setAppearance
{
    [self.avatorImageView setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    [self.userNameLabel setDarkGreyLabelAppearance];
    [self.userDescriptionLabel setSmallReadOnlyLabelAppearance];
}

-(void)configWithUser:(User *)user style:(NSString *)style
{
    [self setAppearance];
    self.cellUser = user;
    self.userNameLabel.text = user.UserName;
    self.userDescriptionLabel.text = user.selfDescriptions;
    
    [self.avatorImageView sd_setImageWithURL:[NSURL URLWithString:user.avatarImageURLString]];
    [self.avatorImageView setRoundConerWithRadius:AVATARIMAGEWIDTH/2];
    
    UITapGestureRecognizer *avatarClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarClick:)];
    [self.avatorImageView setUserInteractionEnabled:YES];
    [self.avatorImageView addGestureRecognizer:avatarClick];
    if ([style isEqualToString:UserListStyle2 ]|| [style isEqualToString:UserListStyle3])
    {
        [self.followButton setNormalButtonAppearance];
        if (user.isFollowed)
        {
            [self.followButton setTitle:@"已关注" forState:UIControlStateNormal];
            [self.followButton setThemeBackGroundAppearance];
        }
        else
        {
            [self.followButton setTitle:@"关注" forState:UIControlStateNormal];
            [self.followButton setThemeFrameAppearence];
        }
    }
    if ([style isEqualToString:UserListStyle3])
        
    {
        if([user.photoList objectAtIndex:0])
        {
            [self.photo1 sd_setImageWithURL:user.photoList[0] placeholderImage:[UIImage imageNamed:@"空白图片"]];
        }
        if([user.photoList objectAtIndex:1])
        {
            [self.photo2 sd_setImageWithURL:user.photoList[1] placeholderImage:[UIImage imageNamed:@"空白图片"]];
        }
        if([user.photoList objectAtIndex:2])
        {
            [self.photo3 sd_setImageWithURL:user.photoList[2] placeholderImage:[UIImage imageNamed:@"空白图片"]];
        }
    }
    
}

@end
