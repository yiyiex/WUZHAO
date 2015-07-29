//
//  FootPrintCollectionViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/7/21.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressPhotos.h"
#import "User.h"

@interface FootPrintCollectionViewController : UICollectionViewController
@property (nonatomic, strong) User *currentUser;
@property (nonatomic,strong) NSArray *datasource;
-(void)loadData;

@end
