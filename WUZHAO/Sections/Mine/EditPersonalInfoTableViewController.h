//
//  EditPersonalInfoTableViewController.h
//  WUZHAO
//
//  Created by yiyi on 15-1-19.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

#import "PlaceholderTextView.h"

@interface EditPersonalInfoTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableViewCell *avatarInfoCell;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (strong, nonatomic) IBOutlet UITableViewCell *nickNameCell;
@property (strong, nonatomic)  UITextField *nickNameTextField;
@property (strong, nonatomic)  PlaceholderTextView *nickNameTextView;
@property (strong, nonatomic) IBOutlet UITableViewCell *webSiteCell;
@property (strong, nonatomic)  UITextField *webSiteTextField;
@property (strong, nonatomic) IBOutlet UITableViewCell *selfDescriptionCell;
@property (strong, nonatomic)  UITextField *selfDescriptionTextField;
@property (strong, nonatomic)  PlaceholderTextView *selfDescriptionTextView;
@property (strong, nonatomic) IBOutlet UITableViewCell *feedBackCell;

@property (strong, nonatomic) IBOutlet UITableViewCell *changePwdCell;
/*
@property (strong, nonatomic) IBOutlet UITableViewCell *emailCell;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITableViewCell *phoneNumCell;
@property (strong, nonatomic) IBOutlet UITextField *phoneNumTextField;
*/


@property (nonatomic, strong) User *userInfo;


@property (nonatomic, strong) IBOutlet UITableViewCell *logoutCell;





@end
