//
//  UIReadOnlyLabel.h
//  WUZHAO
//
//  Created by yiyi on 14-12-25.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIReadOnlyLabel : UILabel

@property (nonatomic,weak) UIColor *labelTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic,weak) UIFont *labelFont UI_APPEARANCE_SELECTOR;

@end
