//
//  AddressMarkViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/7/6.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "User.h"

@interface AddressMarkViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) User *userInfo;
-(void)addAnnotations;

@end
