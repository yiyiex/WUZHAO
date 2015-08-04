//
//  TableViewScrollNotSwipe.m
//  WUZHAO
//
//  Created by yiyi on 15/8/3.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "TableViewScrollNotSwipe.h"

@implementation TableViewScrollNotSwipe

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

- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIPanGestureRecognizer *)otherGestureRecognizer
{
     return self.isDecelerating || self.contentOffset.y < 0 || self.contentOffset.y > MAX(0, self.contentSize.height - self.bounds.size.height);
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self];
        
        if (fabs(velocity.x)*2  <= fabs(velocity.y)) {
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