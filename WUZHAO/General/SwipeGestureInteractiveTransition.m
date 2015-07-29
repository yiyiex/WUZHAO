//
//  SwapGestureInteractiveTransition.m
//  WUZHAO
//
//  Created by yiyi on 15/7/23.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "SwipeGestureInteractiveTransition.h"

@implementation SwipeGestureInteractiveTransition
{
    BOOL _leftToRightTransition;
}

- (id)initWithGestureRecognizerInView:(UIView *)view recognizedBlock:(void (^)(UISwipeGestureRecognizer *recognizer))gestureRecognizedBlock {
    
    self = [super init];
    if (self) {
        _gestureRecognizedBlock = [gestureRecognizedBlock copy];
        _leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToRight:)];
        _leftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [view addGestureRecognizer:_leftRecognizer];
        //_leftRecognizer.delegate = self;
        
        _rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToLeft:)];
        _rightRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [view addGestureRecognizer:_rightRecognizer];
        //_rightRecognizer.delegate = self;
    }
    return self;
}

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    [super startInteractiveTransition:transitionContext];
    
}

- (void)swipeToRight:(UISwipeGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _leftToRightTransition = YES;
        self.gestureRecognizedBlock(recognizer);
      
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
            [self finishInteractiveTransition];
        
    }
    else if (recognizer.state == UIGestureRecognizerStateCancelled)
    {
            [self cancelInteractiveTransition];
    }
}

- (void)swipeToLeft:(UISwipeGestureRecognizer*)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
         _leftToRightTransition = NO;
        self.gestureRecognizedBlock(recognizer);
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self finishInteractiveTransition];
        
    }
    else if (recognizer.state == UIGestureRecognizerStateCancelled)
    {
        [self cancelInteractiveTransition];
    }
}
@end

