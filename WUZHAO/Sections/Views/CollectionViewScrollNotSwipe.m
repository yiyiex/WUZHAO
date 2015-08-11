//
//  CollectionViewScrollNotSwipe.m
//  WUZHAO
//
//  Created by yiyi on 15/8/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "CollectionViewScrollNotSwipe.h"

@implementation CollectionViewScrollNotSwipe
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIPanGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        return NO;
    }
    return YES;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self];
        
        if (fabs(velocity.x)*2 <= fabs(velocity.y)) {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    return YES;
}

@end
