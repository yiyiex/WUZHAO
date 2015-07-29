//
//  PrivateLetterViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/7/25.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrivateLetterViewController : UIViewController
@property (nonatomic, strong) NSMutableArray *letterListData;

@property (nonatomic) BOOL shouldRefreshData;

-(void)getLatestData;
-(void)loadData;

@end
