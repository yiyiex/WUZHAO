//
//  AddressViewController.h
//  WUZHAO
//
//  Created by yiyi on 15-1-4.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressViewController : UIViewController <UITabBarDelegate>

@property (nonatomic) NSInteger poiId;
@property (nonatomic, strong) NSString *poiName;
@property (nonatomic, strong) NSArray *poiLocation;
@property (nonatomic) NSInteger recommendFirstPostId;
@property (nonatomic) NSInteger userId;


@property (nonatomic,strong) NSMutableArray *photoCollectionDatasource;

-(void)getLatestData;


@end
