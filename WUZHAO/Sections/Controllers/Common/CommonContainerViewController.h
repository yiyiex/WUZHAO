//
//  CommonContainerViewController.h
//  WUZHAO
//
//  Created by yiyi on 14-12-15.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonContainerViewController : UIViewController
@property (strong ,nonatomic) NSArray *ChildrenName;

-(instancetype)initWithChildren:(NSArray *)childrenName;
-(void)swapViewControllersWithIdentifier:(NSString *)identifier;
@end
