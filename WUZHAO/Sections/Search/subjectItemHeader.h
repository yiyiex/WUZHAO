//
//  subjectItemHeaderOrFooter.h
//  WUZHAO
//
//  Created by yiyi on 15/8/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Subject.h"

@interface subjectItemHeader: UITableViewHeaderFooterView
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *subtitle;
@property (nonatomic, strong) UITextView *subjectDescription;
@property (nonatomic, strong) NSDictionary *subjectDescriptionAttributes;

-(void)configureHeaderWithSubject:(Subject *)subject;
@end
