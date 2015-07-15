//
//  UserListTableViewCell.h
//  WUZHAO
//
//  Created by yiyi on 15-1-5.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
@interface UserListTableViewCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UIImageView *avatorImageView;
@property (nonatomic,strong) IBOutlet UILabel *userNameLabel;
@property (nonatomic,strong) IBOutlet NSLayoutConstraint *userNameLabelTopAlignment;
@property (nonatomic,strong) IBOutlet UILabel *userDescriptionLabel;

@property (nonatomic,strong) IBOutlet UIButton *followButton;
@property (nonatomic,strong) IBOutlet UIImageView *photo1;
@property (nonatomic,strong) IBOutlet UIImageView *photo2;
@property (nonatomic,strong) IBOutlet UIImageView *photo3;
@property (nonatomic,strong) IBOutlet UIImageView *photo4;
@property (nonatomic,strong) IBOutlet UIImageView *photo5;
@property (nonatomic,strong) IBOutlet UIImageView *photo6;
@property (nonatomic, strong) NSArray *photoImageViews;

- (IBAction)followButtonPressed:(UIButton *)sender;


-(void)configWithUser:(User *)user style:(NSString *)style;
@end
