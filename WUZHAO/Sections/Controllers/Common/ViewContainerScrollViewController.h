//
//  ViewContainerScrollViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/5/19.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ViewContainerScrollViewDelegate;


@interface ViewContainerScrollViewController : UIViewController

@property (nonatomic, weak) id<ViewContainerScrollViewDelegate> dataSource;


@end

@protocol ViewContainerScrollViewDelegate <NSObject>

@required
-(NSInteger)numberOfViewsInViewContainerScrollView:(ViewContainerScrollViewController*)scrollview;

-(UIView *)ViewContainerScrollView:(ViewContainerScrollViewController*)scrollView viewAtIndex:(NSInteger)index;

@end
