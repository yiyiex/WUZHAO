//
//  BlankTableViewCell.h
//  WUZHAO
//
//  Created by yiyi on 15/8/5.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlankTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *blankMessageLabel;

-(void)setBlankMessageText:(NSString *)text;

@end
