//
//  SubjectViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/8/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "BasicViewController.h"
#import "Subject.h"

@interface SubjectViewController : BasicViewController

@property (nonatomic, strong) Subject *subject;

-(void)getLatestData;

@end
