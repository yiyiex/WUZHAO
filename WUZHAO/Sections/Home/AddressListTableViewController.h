//
//  AddressListTableViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/7/21.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PagerViewController.h"
#import "BasicTableViewController.h"

#import "User.h"
#import "AddressPhotos.h"

@interface AddressListTableViewController : BasicTableViewController <PagerViewControllerItem>

-(void)getLatestData;

@end




