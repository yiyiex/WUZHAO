//
//  UserListTableViewCell.h
//  WUZHAO
//
//  Created by yiyi on 15-1-5.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserListTableViewCell : UITableViewCell

@property (nonatomic ,strong) IBOutlet UIImageView *avatorImageView;
@property (nonatomic ,strong) IBOutlet UILabel *userNameLabel;
@property (nonatomic ,strong) IBOutlet UILabel *selfDescriptionLabel;


@end
