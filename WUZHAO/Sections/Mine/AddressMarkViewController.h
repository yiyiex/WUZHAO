//
//  AddressMarkViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/7/6.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>

@interface AddressMarkViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *locations;

-(void)addAnnotations;

@end
