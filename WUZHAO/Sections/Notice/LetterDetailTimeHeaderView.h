//
//  LetterDetailTimeHeaderView.h
//  WUZHAO
//
//  Created by yiyi on 15/7/26.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LetterDetailTimeHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) UILabel *timeLabel;

-(void)setTime:(NSString *)time;

@end
