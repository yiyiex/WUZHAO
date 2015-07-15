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

@interface UserListTableViewCell()
@property (nonatomic,strong) User *cellUser;
@end
@implementation UserListTableViewCell

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initView];
    }
    return self;
}
- (void)awakeFromNib {
    
    [self initView];
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
-(NSArray *)photoImageViews
{
    if (!_photoImageViews)
    {
        _photoImageViews = [[NSArray alloc]initWithObjects:_photo1,_photo2,_photo3,_photo4,_photo5,_photo6,nil];
    }
    return _photoImageViews;
}
-(void)initView
{
    [self.avatorImageView setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    [self.userNameLabel setDarkGreyLabelAppearance];
    [self.userNameLabel setFont:WZ_FONT_LARGE_SIZE];
    [self.userDescriptionLabel setSmallReadOnlyLabelAppearance];
    [self.userDescriptionLabel setFont:WZ_FONT_LARGE_SIZE];
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
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"updateUserInfo" object:nil];
                        
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
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateUserInfo" object:nil];
                    
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

-(void)setAppearance
{
    if ([self.userDescriptionLabel.text isEqualToString:@""])
    {
        [self.userNameLabelTopAlignment setConstant:16.0f];
    }
    else
    {
        [self.userNameLabelTopAlignment setConstant:2.0f];
    }
}

-(void)configWithUser:(User *)user style:(NSString *)style
{

    self.cellUser = user;
    self.userNameLabel.text = user.UserName;
    self.userDescriptionLabel.text = user.selfDescriptions;
    
    NSInteger myUserId =  [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    
    [self.avatorImageView sd_setImageWithURL:[NSURL URLWithString:user.avatarImageURLString]];
    [self.avatorImageView setRoundConerWithRadius:self.avatorImageView.frame.size.width/2];
    if ([style isEqualToString:UserListStyle2 ]|| [style isEqualToString:UserListStyle3])
    {
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

    }
    if ([style isEqualToString:UserListStyle3])
        
    {
        [self.photoImageViews enumerateObjectsUsingBlock:^(UIImageView *obj, NSUInteger idx, BOOL *stop) {
            [obj setImage:nil];
        }];
        if (user.photoList &&  user.photoList.count >0)
        {
            [user.photoList enumerateObjectsUsingBlock:^(WhatsGoingOn *item, NSUInteger idx, BOOL *stop) {
                [self.photoImageViews[idx] sd_setImageWithURL:[NSURL URLWithString:item.imageUrlString] placeholderImage:[UIImage imageNamed:@"空白图片"]];
                [self.photoImageViews[idx] setUserInteractionEnabled:YES];
            }];
        }
    }
    [self setAppearance];
}

@end
