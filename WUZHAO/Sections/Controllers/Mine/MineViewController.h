//
//  MineViewController.h
//  WUZHAO
//
//  Created by yiyi on 14-12-17.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonContainerViewController.h"
@interface MineViewController : UIViewController <UITabBarDelegate, UICollectionViewDataSource,UICollectionViewDelegate>

@property (strong,nonatomic)IBOutlet UICollectionView *photosCollectionView;
@end
