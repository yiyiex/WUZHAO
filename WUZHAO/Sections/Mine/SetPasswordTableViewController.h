//
//  SetPasswordTableViewController.h
//  WUZHAO
//
//  Created by yiyi on 15-1-21.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetPasswordTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableViewCell *myOldPwdCell;
@property (strong, nonatomic) UITextField *myOldPwdTextField;
@property (strong, nonatomic) IBOutlet UITableViewCell *myNewPwdCell;
@property (strong, nonatomic) UITextField *myNewPwdTextField;
@property (strong, nonatomic) IBOutlet UITableViewCell *comfirmPwdCell;
@property (strong, nonatomic) UITextField *comfirmPwdTextField;
@end
