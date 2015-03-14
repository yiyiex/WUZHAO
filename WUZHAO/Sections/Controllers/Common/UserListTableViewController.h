//
//  UserListTableViewController.h
//  WUZHAO
//
//  Created by yiyi on 15-1-5.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserListTableViewController : UITableViewController
@property (nonatomic,strong) NSString *userListStyle;
@property (nonatomic,strong) NSArray *datasource;
@end
