//
//  NoticeViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/7/31.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "SegmentPagerViewController.h"

//childviewcontroller must adopted pagerViewControllerItem

@interface NoticeViewController : SegmentPagerViewController

-(void)getLatestData;

@end
