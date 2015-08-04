//
//  HomeContainerViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/8/1.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SegmentPagerViewController.h"
#import "HomeTableViewController.h"
#import "AddressListTableViewController.h"
#import "UIViewController+Basic.h"

@interface HomeContainerViewController : SegmentPagerViewController<PagerViewControllerDataSource,PagerViewControllerDelegate>

-(void)getLatestData;

@end
