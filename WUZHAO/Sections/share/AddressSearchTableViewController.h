//
//  AddressSearchTableViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/4/12.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "POI.h"

@protocol AddressSearchTableViewControllerDelegate <NSObject>
-(void)finishSelectAddress:(POI *)addressInfo;
@end
@interface AddressSearchTableViewController : UIViewController
@property (strong, nonatomic) POI *poiInfo;
@property (strong, nonatomic) CLLocation* location;
@property (weak, nonatomic) id<AddressSearchTableViewControllerDelegate> delegate;
@end
