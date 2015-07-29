//
//  SwapGestureInteractiveTransition.h
//  WUZHAO
//
//  Created by yiyi on 15/7/23.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "AWPercentDrivenInteractiveTransition.h"

@interface SwipeGestureInteractiveTransition : AWPercentDrivenInteractiveTransition


- (id)initWithGestureRecognizerInView:(UIView *)view recognizedBlock:(void (^)(UISwipeGestureRecognizer *recognizer))gestureRecognizedBlock;

@property (nonatomic, readonly) UISwipeGestureRecognizer *leftRecognizer;
@property (nonatomic, readonly) UISwipeGestureRecognizer *rightRecognizer;

/// This block gets run when the gesture recognizer start recognizing a swipe Inside, the start of a transition can be triggered.
@property (nonatomic, copy) void (^gestureRecognizedBlock)(UISwipeGestureRecognizer *recognizer);

@end
