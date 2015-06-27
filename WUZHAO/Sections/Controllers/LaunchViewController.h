//
//  LaunchViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/3/2.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^dismissBlock)(void);

@interface LaunchViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *QDYLabel;

@property (strong, nonatomic) IBOutlet UIButton *RegisterButton;
@property (strong, nonatomic) IBOutlet UIButton *LoginButton;

@property (nonatomic, strong) dismissBlock dismiss;

@end
