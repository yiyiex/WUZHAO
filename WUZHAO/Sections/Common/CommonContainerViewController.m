//  
//  CommonContainerViewController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-15.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "CommonContainerViewController.h"

@interface PrivateAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@end

@interface TransitionContext : NSObject <UIViewControllerContextTransitioning>
- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController goingRight:(BOOL)goingRight; /// Designated initializer.
@property (nonatomic, copy) void (^completionBlock)(BOOL didComplete); /// A block of code we can set to execute after having received the completeTransition: message.
@property (nonatomic, assign, getter=isAnimated) BOOL animated; /// Private setter for the animated property.
@property (nonatomic, assign, getter=isInteractive) BOOL interactive; /// Private setter for the interactive property.
@end
@interface CommonContainerViewController ()

@property (nonatomic) BOOL transitionInProgress;
@property (nonatomic, strong) NSString *destinationSegueIdentifier;
@property (nonatomic, strong) Animator *animator;
@property (nonatomic, strong) PanGestureInteractiveTransition *defaultInteractionController;
@end

@implementation CommonContainerViewController
- (instancetype)initWithChildren:(NSArray *)childrenName
{
    self = [super init];
    if (self)
    {
       [self setChildrenName:childrenName];
    }
    self.currentSegueIdentifier = [self.ChildrenName firstObject];
    return  self;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self performSegueWithIdentifier:self.currentSegueIdentifier sender:self];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setIsInteractive:(BOOL)isInteractive
{
    _isInteractive = isInteractive;
    if (isInteractive)
    {
         [self initDefaultInteractionController];
    }
    else
    {
        self.defaultInteractionController = nil;
    }
}

-(void)initDefaultInteractionController
{
    __weak typeof(self) wself = self;
    if(!_defaultInteractionController)
    {
        _defaultInteractionController = [[PanGestureInteractiveTransition alloc] initWithGestureRecognizerInView:self.view recognizedBlock:^(UIPanGestureRecognizer *recognizer) {
            BOOL leftToRight = [recognizer velocityInView:recognizer.view].x > 0;
            
            NSInteger currentIdenfitierIndex = [wself.ChildrenName indexOfObject:wself.currentSegueIdentifier];
            NSInteger toSegueIdentifierIndex;
            
            if (currentIdenfitierIndex == 0 && leftToRight == YES)
            {
                return ;
            }
            if (currentIdenfitierIndex == wself.ChildrenName.count-1 && leftToRight == NO)
            {
                return ;
            }
            toSegueIdentifierIndex = leftToRight?currentIdenfitierIndex - 1: currentIdenfitierIndex +1;
            [wself performSegueWithIdentifier:wself.ChildrenName[toSegueIdentifierIndex] sender:nil];
        }];
    }
   
}
-(UIGestureRecognizer *)interactiveTransitionGestureRecognizer
{
    return self.defaultInteractionController.recognizer;
}


-(NSArray *)ChildrenName
{
    if (!_ChildrenName)
    {
        _ChildrenName = @[];
    }
    return _ChildrenName;
}

-(NSString *)currentSegueIdentifier
{
    if (!_currentSegueIdentifier)
    {
        if (self.ChildrenName.count >0)
        {
            _currentSegueIdentifier = [self.ChildrenName objectAtIndex:0];
        }
        else
        {
            _currentSegueIdentifier = nil;
        }
    }
    return _currentSegueIdentifier;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.destinationSegueIdentifier  = segue.identifier;
    BOOL goingRight = [self.ChildrenName indexOfObject:segue.identifier]> [self.ChildrenName indexOfObject:self.currentSegueIdentifier];
    if([segue.identifier isEqualToString:[self.ChildrenName objectAtIndex:0]])
    {
        if (self.childViewControllers.count > 0)
        {
            [self swapFromViewController:self.currentViewController toViewController:segue.destinationViewController goingRight:goingRight];
        
        }
        else
        {
            [self addChildViewController:segue.destinationViewController];
            UIView *destView = ((UIViewController *)segue.destinationViewController).view;
            destView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            [self.view addSubview:destView];
            [segue.destinationViewController didMoveToParentViewController:self];
            self.currentSegueIdentifier = self.destinationSegueIdentifier;
            self.destinationSegueIdentifier = nil;
            self.currentViewController = segue.destinationViewController;
            if ([_delegate respondsToSelector:@selector(finishLoadChildController:)])
            {
                [_delegate finishLoadChildController:segue.destinationViewController];
            }
       
            
        }
    }
    else{
        [self swapFromViewController:self.currentViewController toViewController:segue.destinationViewController goingRight:goingRight];
    }
    if ([self.delegate respondsToSelector:@selector(beginLoadChildController:)])
    {
        [self.delegate beginLoadChildController:segue.destinationViewController];
    }

}
-(void)swapFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController goingRight:(BOOL)goingRight
{
    toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];;
    id<UIViewControllerAnimatedTransitioning>animator;
    if (self.isInteractive)
    {
       animator = [[Animator alloc]init];
    }
    else
    {
        animator = [[PrivateAnimator alloc]init];
    }
    
    TransitionContext *transitionContext = [[TransitionContext alloc]initWithFromViewController:fromViewController toViewController:toViewController goingRight:goingRight];
    id<UIViewControllerInteractiveTransitioning> interactionController = [self _interactionControllerForAnimator:animator];
    
    transitionContext.animated = YES;
    transitionContext.interactive = (interactionController==nil)?NO:YES;
    transitionContext.completionBlock = ^(BOOL didComplete)
    {
        if (didComplete) {
            [fromViewController.view removeFromSuperview];
            [fromViewController removeFromParentViewController];
            [toViewController didMoveToParentViewController:self];
            self.currentViewController = toViewController;
            self.currentSegueIdentifier = self.destinationSegueIdentifier;
            self.destinationSegueIdentifier = nil;
            if ([_delegate respondsToSelector:@selector(finishLoadChildController:)])
            {
                [_delegate finishLoadChildController:self.currentViewController];
            }
            
        } else {
            [toViewController.view removeFromSuperview];
            if ([_delegate respondsToSelector:@selector(finishLoadChildController:)])
            {
                [_delegate finishLoadChildController:self.currentViewController];
            }
            
        }
        if ([animator respondsToSelector:@selector (animationEnded:)]) {
            [animator animationEnded:didComplete];
        }
        self.transitionInProgress = NO;
    
   
     
    };
    if ([transitionContext isInteractive]) {
        [interactionController startInteractiveTransition:transitionContext];
    } else {
        [animator animateTransition:transitionContext];
    }
    /*
    [self transitionFromViewController:fromViewController toViewController:toViewController duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:UIViewAnimationTransitionNone completion:^(BOOL finished){
        if (finished)
        {
            [fromViewController removeFromParentViewController];
            [toViewController didMoveToParentViewController:self];
            self.transitionInProgress = NO;
        }
    }];*/
}
-(void)swapViewControllersWithIdentifier:(NSString *)identifier
{
    if (self.transitionInProgress)
    {
        return;
    }
   
    if ([self.currentSegueIdentifier isEqualToString:identifier])
    {
        return;
    }
    else
    {
        self.transitionInProgress = YES;
        [self performSegueWithIdentifier:identifier sender:nil];

    }

}

- (id<UIViewControllerInteractiveTransitioning>)_interactionControllerForAnimator:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if (!self.isInteractive)
    {
        return nil;
    }
    else if (self.defaultInteractionController.recognizer.state == UIGestureRecognizerStateBegan) {
        self.defaultInteractionController.animator = animationController;
        return self.defaultInteractionController;
    }
    return nil;
    
}

@end


@interface TransitionContext ()
@property (nonatomic, strong) NSDictionary *privateViewControllers;
@property (nonatomic, assign) CGRect privateDisappearingFromRect;
@property (nonatomic, assign) CGRect privateAppearingFromRect;
@property (nonatomic, assign) CGRect privateDisappearingToRect;
@property (nonatomic, assign) CGRect privateAppearingToRect;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, assign) UIModalPresentationStyle presentationStyle;
@property (nonatomic, assign) BOOL transitionWasCancelled;
@end

@implementation TransitionContext

- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController goingRight:(BOOL)goingRight {
    NSAssert ([fromViewController isViewLoaded] && fromViewController.view.superview, @"The fromViewController view must reside in the container view upon initializing the transition context.");
    
    if ((self = [super init])) {
        self.presentationStyle = UIModalPresentationCustom;
        self.containerView = fromViewController.view.superview;
         _transitionWasCancelled = NO;
        self.privateViewControllers = @{
                                        UITransitionContextFromViewControllerKey:fromViewController,
                                        UITransitionContextToViewControllerKey:toViewController,
                                        };
        
        // Set the view frame properties which make sense in our specialized ContainerViewController context. Views appear from and disappear to the sides, corresponding to where the icon buttons are positioned. So tapping a button to the right of the currently selected, makes the view disappear to the left and the new view appear from the right. The animator object can choose to use this to determine whether the transition should be going left to right, or right to left, for example.
        CGFloat travelDistance = (goingRight ? -self.containerView.bounds.size.width : self.containerView.bounds.size.width);
        self.privateDisappearingFromRect = self.privateAppearingToRect = self.containerView.bounds;
        self.privateDisappearingToRect = CGRectOffset (self.containerView.bounds, travelDistance, 0);
        self.privateAppearingFromRect = CGRectOffset (self.containerView.bounds, -travelDistance, 0);
    }
    
    return self;
}

- (CGRect)initialFrameForViewController:(UIViewController *)viewController {
    if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey]) {
        return self.privateDisappearingFromRect;
    } else {
        return self.privateAppearingFromRect;
    }
}

- (CGRect)finalFrameForViewController:(UIViewController *)viewController {
    if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey]) {
        return self.privateDisappearingToRect;
    } else {
        return self.privateAppearingToRect;
    }
}

- (UIViewController *)viewControllerForKey:(NSString *)key {
    return self.privateViewControllers[key];
}

- (void)completeTransition:(BOOL)didComplete {
    if (self.completionBlock) {
        self.completionBlock (didComplete);
    }
}
// Supress warnings by implementing empty interaction methods for the remainder of the protocol:

- (void)updateInteractiveTransition:(CGFloat)percentComplete {}
- (void)finishInteractiveTransition {self.transitionWasCancelled = NO;}
- (void)cancelInteractiveTransition {self.transitionWasCancelled = YES;}
@end


@implementation PrivateAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [[transitionContext containerView] addSubview:toViewController.view];
    toViewController.view.alpha = 0;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        //fromViewController.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
        
        toViewController.view.alpha = 1;
    } completion:^(BOOL finished) {
        fromViewController.view.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        
    }];
}

@end
