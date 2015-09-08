//
//  SubjectItemFooter.h
//  WUZHAO
//
//  Created by yiyi on 15/8/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Subject.h"

@interface SubjectItemFooter : UITableViewHeaderFooterView
@property (nonatomic, strong) UITextView *summaryLabel;
@property (nonatomic, strong) NSDictionary *summaryTextAttributes;
-(void)configureFooterWithSubject:(Subject *)subject;
@end
