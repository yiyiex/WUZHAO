//
//  AddressPhotosCollectionViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/8/5.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicCollectionViewController.h"
#import "HomeTableViewController.h"
#import "POI.h"

@interface AddressPhotosCollectionViewController : BasicCollectionViewController

@property (nonatomic, strong) POI *poi;
@property (nonatomic) NSInteger recommendFirstPostId;
@property (nonatomic, strong) NSMutableArray *recommendPhotos;
@property (nonatomic, strong) NSMutableArray *addressPhotos;
@property (nonatomic) NSInteger userId;

@end
