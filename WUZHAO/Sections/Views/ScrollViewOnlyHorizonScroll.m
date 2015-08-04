//
//  ScrollViewOnlyHorizonScroll.m
//  WUZHAO
//
//  Created by yiyi on 15/8/3.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "ScrollViewOnlyHorizonScroll.h"

@implementation ScrollViewOnlyHorizonScroll

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self];
        if (fabs(velocity.y) * 2 < fabs(velocity.x)) {
            return YES;
        }
    }
    return NO;
}

@end
