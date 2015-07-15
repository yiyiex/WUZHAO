//
//  FootPrintTableViewCell.h
//  WUZHAO
//
//  Created by yiyi on 15/7/6.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FootPrintTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *addressNameLabel;
@property (nonatomic, strong) UILabel *photoNumLabel;

-(void)setAppearance;
@end
