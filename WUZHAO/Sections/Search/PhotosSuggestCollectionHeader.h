//
//  PhotosSuggestCollectionHeader.h
//  WUZHAO
//
//  Created by yiyi on 15/8/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScrollViewNotSimultaneously.h"
@interface PhotosSuggestCollectionHeader : UICollectionReusableView
@property (nonatomic, strong) IBOutlet ScrollViewNotSimultaneously *bannerScrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *bannerPageControl;


@end
