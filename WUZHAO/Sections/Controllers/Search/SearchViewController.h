//
//  SearchViewController.h
//  WUZHAO
//
//  Created by yiyi on 14-12-15.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMSegmentedControl.h"



@interface SearchViewController : UIViewController 
@property (nonatomic,strong) IBOutlet HMSegmentedControl *segmentControl;



- (void)segmentValueChanged;


@end
