//
//  ProgressIndicatorView.h
//  WUZHAO
//
//  Created by yiyi on 15/8/25.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ProgressIndicatorView : UIView
@property (weak, nonatomic) id delegate;
@property (strong, nonatomic) UIColor *progressBarColor;
@property (strong, nonatomic) UIColor *wrapperColor;
@property (assign, nonatomic) CGFloat progressBarShadowOpacity;
@property (assign, nonatomic) CGFloat progressBarArcWidth;
@property (assign, nonatomic) CGFloat wrapperArcWidth;
@property (assign, nonatomic) CFTimeInterval duration;
@property (assign, nonatomic) CGFloat currentProgress;

- (void)run:(CGFloat)progress;
- (void)pause;
- (void)reset;

@end
