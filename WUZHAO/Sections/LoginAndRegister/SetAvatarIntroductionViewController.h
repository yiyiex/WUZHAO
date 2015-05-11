//
//  SetAvatarIntroductionViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/5/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceholderTextView.h"

@interface SetAvatarIntroductionViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *intruductionLabel;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UILabel *avatarLabel;
@property (nonatomic, weak) IBOutlet PlaceholderTextView *selfDescriptionTextView;
@property (nonatomic, weak) IBOutlet UIButton *nextButton;

-(IBAction)nextButtonClick:(id)sender;

@end
