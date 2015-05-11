//
//  AddressTableViewCell.h
//  WUZHAO
//
//  Created by yiyi on 4/25/15.
//  Copyright (c) 2015 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressTableViewCell : UITableViewCell
@property (nonatomic,strong) IBOutlet UILabel *addressLabel;
@property (nonatomic,strong) IBOutlet UILabel *detailAddressLabel;
-(void)setAppearance;
@end
