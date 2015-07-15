//
//  AddressSuggestPOITableViewCell.h
//  WUZHAO
//
//  Created by yiyi on 15/7/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuggestAddress.h"

@interface AddressSuggestPOITableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *poiImageView;
@property (nonatomic, strong) IBOutlet UILabel *poiNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *poiInfoLabel;
@property (nonatomic, strong) IBOutlet UIImageView *poiInfoImageView;
@property (nonatomic, strong) IBOutlet UIImageView *poiUserAvatarImageView;
@property (nonatomic, strong) IBOutlet UILabel *poiUserNameLabel;

@property (nonatomic, strong) UIView *maskView;

-(void)configureWithData:(SuggestAddress *)data;
@end
