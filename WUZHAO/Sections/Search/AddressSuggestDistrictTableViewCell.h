//
//  AddressSuggestDistrictTableViewCell.h
//  WUZHAO
//
//  Created by yiyi on 15/7/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuggestAddress.h"

@interface AddressSuggestDistrictTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *districtImageView;
@property (nonatomic, strong) IBOutlet UILabel *districtNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *districtInfoLabel;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *districtNameLabelVerticalSpacingToSuperView;

-(void)configureWithData:(SuggestAddress *)data;

@end
