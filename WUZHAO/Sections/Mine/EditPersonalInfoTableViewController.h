//
//  EditPersonalInfoTableViewController.h
//  WUZHAO
//
//  Created by yiyi on 15-1-19.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"



@interface EditPersonalInfoTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableViewCell *avatorInfoCell;

@property (strong, nonatomic) IBOutlet UITableViewCell *nickNameCell;
@property (strong, nonatomic) IBOutlet UITextField *nickNameTextField;
@property (strong, nonatomic) IBOutlet UITableViewCell *webSiteCell;
@property (strong, nonatomic) IBOutlet UITextField *webSiteTextField;
@property (strong, nonatomic) IBOutlet UITableViewCell *selfDescriptionCell;
@property (strong, nonatomic) IBOutlet UITextField *selfDescriptionTextField;

@property (strong, nonatomic) IBOutlet UITableViewCell *changePwdCell;

@property (strong, nonatomic) IBOutlet UITableViewCell *emailCell;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITableViewCell *phoneNumCell;
@property (strong, nonatomic) IBOutlet UITextField *phoneNumTextField;

@property (strong, nonatomic) IBOutlet UITableViewCell *sexCell;

@property (nonatomic, strong) User *userInfo;

@end
