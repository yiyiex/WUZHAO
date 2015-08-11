//
//  PhotosSuggestViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/8/9.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PagerViewController.h"

@interface PhotosSuggestViewController : UIViewController<PagerViewControllerItem>
-(void)getLatestData;

-(void)getLatestSubjects;

-(void)getLatestSuggestPhotos;

@end
