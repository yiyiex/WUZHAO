//
//  HomeAddressListTableViewCell.h
//  WUZHAO
//
//  Created by yiyi on 15/8/1.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "POI.h"

@interface HomeAddressListTableViewCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UIImageView *avatorImageView;
@property (nonatomic,strong) IBOutlet UILabel *addressNameLabel;
@property (nonatomic,strong) IBOutlet UILabel *addressDescriptionLabel;

@property (nonatomic,strong) IBOutlet UIButton *enterButton;
@property (nonatomic, strong) NSArray *photoImageViews;

-(void)configWithPoi:(POI *)poi;
@end
