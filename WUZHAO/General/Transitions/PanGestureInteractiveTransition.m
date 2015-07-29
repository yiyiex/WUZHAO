//
//  PanGestureInteractiveTransition.m
//  Container Transitions
//
//  Created by Alek Astrom on 2014-05-11.
//
//

#import "PanGestureInteractiveTransition.h"

@interface PanGestureInteractiveTransition()<UIGestureRecognizerDelegate>

@end
static BOOL canMoveView = YES;

@implementation PanGestureInteractiveTransition {
    BOOL _leftToRightTransition;
}

- (id)initWithGestureRecognizerInView:(UIView *)view recognizedBlock:(void (^)(UIPanGestureRecognizer *recognizer))gestureRecognizedBlock {
    
    self = [super init];
    if (self) {
        _gestureRecognizedBlock = [gestureRecognizedBlock copy];
        _recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [view addGestureRecognizer:_recognizer];
        _recognizer.delegate = self;
    }
    return self;
}

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    [super startInteractiveTransition:transitionContext];
    _leftToRightTransition = [_recognizer velocityInView:_recognizer.view].x > 0;
}

- (void)pan:(UIPanGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if ([recognizer translationInView:recognizer.view].y !=0)
        {
            canMoveView = NO;
            return;
        }
        self.gestureRecognizedBlock(recognizer);
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        if (!canMoveView)
        {
            return;
        }
        CGPoint translation = [recognizer translationInView:recognizer.view];
        CGFloat d = translation.x / CGRectGetWidth(recognizer.view.bounds);
        if (!_leftToRightTransition) d *= -1;
        [self updateInteractiveTransition:d*0.8];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:recognizer.view];
        CGFloat xVelocity = velocity.x;
        if (!_leftToRightTransition)
        {
            xVelocity *=-1;
        }
        if (xVelocity >=[[UIScreen mainScreen] applicationFrame].size.width)
        {
            [self finishInteractiveTransition];
        }
        else if (self.percentComplete > 0.4) {
            [self finishInteractiveTransition];
        } else {
            [self cancelInteractiveTransition];
        }
         canMoveView = YES;
       
    }
    else if (recognizer.state == UIGestureRecognizerStateCancelled)
    {
        if (!canMoveView)
        {
            return;
        }
        if (self.percentComplete > 0.4) {
            [self finishInteractiveTransition];
        } else {
            [self cancelInteractiveTransition];
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    if ([panGestureRecognizer translationInView:panGestureRecognizer.view].y!=0)
    {
        return NO;
    }
    return YES;
}

@end
