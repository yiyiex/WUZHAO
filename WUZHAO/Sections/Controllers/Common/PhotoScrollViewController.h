//
//  PhotoScrollViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/5/18.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDScrollViewController.h"

@interface PhotoScrollViewController : DDScrollViewController<DDScrollViewDataSource>
@property (nonatomic, strong) NSMutableArray *allPhotos;
-(instancetype)initWithDatas:(NSMutableArray *)datas;
@end
