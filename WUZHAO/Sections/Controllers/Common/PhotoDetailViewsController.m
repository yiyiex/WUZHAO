//
//  ViewContainerController.m
//  WUZHAO
//
//  Created by yiyi on 15/5/21.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "PhotoDetailViewsController.h"
#import "SVProgressHUD.h"

@interface PrivateTransitionContext : NSObject <UIViewControllerContextTransitioning>
- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController goingRight:(BOOL)goingRight; /// Designated initializer.
@property (nonatomic, copy) void (^completionBlock)(BOOL didComplete); /// A block of code we can set to execute after having received the completeTransition: message.
@property (nonatomic, assign, getter=isAnimated) BOOL animated; /// Private setter for the animated property.
@property (nonatomic, assign, getter=isInteractive) BOOL interactive; /// Private setter for the interactive property.
@end

/** Instances of this private class perform the default transition animation which is to slide child views horizontally.
 @note The class only supports UIViewControllerAnimatedTransitioning at this point. Not UIViewControllerInteractiveTransitioning.
 */
@interface PrivateAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning>
@end

typedef NS_ENUM(NSInteger, SWIPEDIRECTION)
{
    SWIPEDIRECTION_LEFT = 0,
    SWIPEDIRECTION_RIGHT = 1
};

@interface PhotoDetailViewsController ()
{
    SWIPEDIRECTION swipeDeirection;
    NSSet *touchStartPoint;
    NSSet *touchEndPoint;
}
@property (nonatomic, strong) UIView *privateContainerView;
@property (nonatomic,strong) NSArray *detailViewControllers;
@property (nonatomic,weak) HomeTableViewController *currentPhotoDetailController;
@property (nonatomic, weak) HomeTableViewController *toPhtoDetailController;

@end

@implementation PhotoDetailViewsController

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initView];
    }
    return self;
}
-(instancetype)initWithDataSource:(id<PhotoDetailViewsControllerDataSource> )dataSource
{
    
    self = [super init];
    if (self)
    {
        [self initView];
        self.dataSource = dataSource;
    }
    return self;
}

-(void)initView
{
    UIStoryboard *whatsNewStoryboard = [UIStoryboard storyboardWithName:@"WhatsNew" bundle:nil];
    HomeTableViewController *detailView1 = [whatsNewStoryboard instantiateViewControllerWithIdentifier:@"HomeTableViewController"];
    detailView1.tableStyle = WZ_TABLEVIEWSTYLE_DETAIL;
    HomeTableViewController *detailView2 = [whatsNewStoryboard instantiateViewControllerWithIdentifier:@"HomeTableViewController"];
    detailView2.tableStyle = WZ_TABLEVIEWSTYLE_DETAIL;
    detailView2.dataSource = [[NSMutableArray alloc]init];
    self.detailViewControllers = [[NSArray alloc]initWithObjects:detailView1, detailView2, nil];
}

-(void)loadView
{
    
    // Add  container and buttons views.
    
    UIView *rootView = [[UIView alloc] init];
    rootView.backgroundColor = [UIColor blackColor];
    rootView.opaque = YES;
    rootView.autoresizingMask = UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleWidth;
    [rootView setUserInteractionEnabled:YES];
    
    self.privateContainerView = [[UIView alloc] init];
    self.privateContainerView.backgroundColor = [UIColor blackColor];
    self.privateContainerView.opaque = YES;
    
    [self.privateContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [rootView addSubview:self.privateContainerView];
    
    // Container view fills out entire root view.
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateContainerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateContainerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateContainerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateContainerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];

    
    self.view = rootView;
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPhotoIndex = self.currentPhotoIndex?:0;
    self.currentPhotoDetailController = self.currentPhotoDetailController?:_detailViewControllers[0];
    
   // [self.privateContainerView setUserInteractionEnabled:YES];
    /*
    //gesture
    UISwipeGestureRecognizer *swipeToleft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeToLeft:)];
    [swipeToleft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.privateContainerView addGestureRecognizer:swipeToleft];
    UISwipeGestureRecognizer *swipeToRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeToRight:)];
    [swipeToRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.privateContainerView addGestureRecognizer:swipeToRight];
    [self.privateContainerView setUserInteractionEnabled:YES];
     */
    
    // Do any additional setup after loading the view.
}
-(void)setCurrentPhotoDetailController:(HomeTableViewController *)currentPhotoDetailController
{
    NSParameterAssert(currentPhotoDetailController);
    if([self.dataSource respondsToSelector:@selector(photoDetailViewsController:dataAtIndex:)])
    {
        WhatsGoingOn *dataItem = [self.dataSource photoDetailViewsController:self dataAtIndex:self.currentPhotoIndex];
        if (dataItem)
        {
            
            
            _currentPhotoDetailController = currentPhotoDetailController;
            _currentPhotoDetailController.dataSource =[NSMutableArray arrayWithArray : @[dataItem]];
            [self.currentPhotoDetailController GetLatestDataList];
            [self _transitionToChildViewController:currentPhotoDetailController direction:swipeDeirection];
            NSLog(@"currentView  frame origin %f %f %f %f",_currentPhotoDetailController.view.frame.origin.x,_currentPhotoDetailController.view.frame.origin.y,_currentPhotoDetailController.view.frame.size.width,_currentPhotoDetailController.view.frame.size.height);
              NSLog(@"private container  frame origin %f %f %f %f",_privateContainerView.frame.origin.x,_privateContainerView.frame.origin.y,_privateContainerView.frame.size.width,_privateContainerView.frame.size.height);
           
            
        }
        else
        {
            [SVProgressHUD showInfoWithStatus:@"没有更多数据了"];
            self.currentPhotoIndex = swipeDeirection == SWIPEDIRECTION_LEFT? self.currentPhotoIndex+1:self.currentPhotoIndex-1;
        }
    }

    
}

-(void)setToPhtoDetailController:(HomeTableViewController *)toPhtoDetailController
{
    NSParameterAssert(currentPhotoDetailController);
    if([self.dataSource respondsToSelector:@selector(photoDetailViewsController:dataAtIndex:)])
    {
        WhatsGoingOn *dataItem = [self.dataSource photoDetailViewsController:self dataAtIndex:self.currentPhotoIndex];
        if (dataItem)
        {

            _toPhtoDetailController = toPhtoDetailController;
            _toPhtoDetailController.dataSource = [NSMutableArray arrayWithArray:@[dataItem]];
             [self.toPhtoDetailController GetLatestDataList];
            [self _transitionToChildViewController:_toPhtoDetailController direction:swipeDeirection];
        }
        else
        {
            [SVProgressHUD showInfoWithStatus:@"没有更多数据了"];
            self.currentPhotoIndex = swipeDeirection == SWIPEDIRECTION_LEFT? self.currentPhotoIndex+1:self.currentPhotoIndex-1;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - gestrue
-(void)swipeToLeft:(UISwipeGestureRecognizer *)gesture
{
    /*
    swipeDeirection = SWIPEDIRECTION_RIGHT;
    self.currentPhotoIndex ++;
    [self switchViewController];
     */
}
-(void)swipeToRight:(UISwipeGestureRecognizer *)gesture
{
    /*
    swipeDeirection = SWIPEDIRECTION_LEFT;
    self.currentPhotoIndex --;
    [self switchViewController];
     */
}

-(void)touchesMoveToRight
{
    
}

-(void)touchesMoveToLeft
{
    
}

#pragma mark - touches
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    touchStartPoint = touches;
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint movePoint = [touches.allObjects.lastObject locationInView:self.view];
    CGPoint beganPoint = [touchStartPoint.allObjects.lastObject locationInView:self.view];
    if (movePoint.x > beganPoint.x)
    {
        //swipe to right
    }
    if (movePoint.x < beganPoint.x)
    {
        //swipe to left
    }
    [super touchesMoved:touches withEvent:event];
    
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   // CGPoint endPoint = [touches.allObjects.lastObject locationInView:self.view];
   // CGPoint beganPoint = [touchStartPoint.allObjects.lastObject locationInView:self.view];
    
    //check if to finish the animation
    
    
    [super touchesMoved:touches withEvent:event];
}

#pragma mark - private method

-(void)switchViewController
{
    [self.detailViewControllers enumerateObjectsUsingBlock:^(HomeTableViewController *detailView, NSUInteger index, BOOL *stop) {
        if (detailView == self.currentPhotoDetailController)
        {
           
            HomeTableViewController *toViewController = self.detailViewControllers[(index +1)%2];
            self.currentPhotoDetailController = toViewController;
        }
    }];
}
-(void)_transitionToChildViewController:(HomeTableViewController *)toViewController direction:(SWIPEDIRECTION)direction
{
    NSLog(@"%@   %ld",self.childViewControllers,(long) self.childViewControllers.count);
    HomeTableViewController *fromViewController =  ([self.childViewControllers count] > 0 ? self.childViewControllers[0] : nil);
    if ( ![self isViewLoaded] || fromViewController == toViewController )
    {
        return;
    }
    
    UIView *toView = toViewController.view;
   // [toView setTranslatesAutoresizingMaskIntoConstraints:YES];
   // toView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    toView.frame = self.privateContainerView.bounds;
    
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    
    
    //init the view
    if(!fromViewController)
    {
        [self.privateContainerView addSubview:toViewController.view];
        [toViewController didMoveToParentViewController:self];
        return;
    }
    
    id<UIViewControllerAnimatedTransitioning>animator = nil;
    animator = [[PrivateAnimatedTransition alloc]init];
    
    PrivateTransitionContext *context = [[PrivateTransitionContext alloc]initWithFromViewController:fromViewController toViewController:toViewController goingRight:(direction == SWIPEDIRECTION_RIGHT)];
    context.animated = YES;
    context.interactive = YES;
    context.completionBlock = ^(BOOL didComplete)
    {
        [fromViewController.view removeFromSuperview];
        [fromViewController removeFromParentViewController];
        [toViewController didMoveToParentViewController:self];
        if ([animator respondsToSelector:@selector(animationEnded:)])
        {
            [animator animationEnded:didComplete];
           // [self _updateViewContent];
        }
        
    };
    
    //action the animator
    [animator animateTransition:context];
    
    
    
}

-(void)_updateViewContent
{
    [self.currentPhotoDetailController GetLatestDataList];
}

#pragma mark - Private Transitioning Classes

@end

@interface PrivateTransitionContext ()
@property (nonatomic, strong) NSDictionary *privateViewControllers;
@property (nonatomic, assign) CGRect privateDisappearingFromRect;
@property (nonatomic, assign) CGRect privateAppearingFromRect;
@property (nonatomic, assign) CGRect privateDisappearingToRect;
@property (nonatomic, assign) CGRect privateAppearingToRect;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, assign) UIModalPresentationStyle presentationStyle;
@end

@implementation PrivateTransitionContext

- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController goingRight:(BOOL)goingRight {
    NSAssert ([fromViewController isViewLoaded] && fromViewController.view.superview, @"The fromViewController view must reside in the container view upon initializing the transition context.");
    
    if ((self = [super init])) {
        self.presentationStyle = UIModalPresentationCustom;
        self.containerView = fromViewController.view.superview;
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

- (BOOL)transitionWasCancelled { return NO; } // Our non-interactive transition can't be cancelled (it could be interrupted, though)

// Supress warnings by implementing empty interaction methods for the remainder of the protocol:

- (void)updateInteractiveTransition:(CGFloat)percentComplete {}
- (void)finishInteractiveTransition {}
- (void)cancelInteractiveTransition {}

@end

@implementation PrivateAnimatedTransition

static CGFloat const kChildViewPadding = 0;
static CGFloat const kDamping = 1.0;
static CGFloat const kInitialSpringVelocity = 0.5;

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.8;
}

/// Slide views horizontally, with a bit of space between, while fading out and in.
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    // When sliding the views horizontally in and out, figure out whether we are going left or right.
    BOOL goingRight = ([transitionContext initialFrameForViewController:toViewController].origin.x < [transitionContext finalFrameForViewController:toViewController].origin.x);
    CGFloat travelDistance = [transitionContext containerView].bounds.size.width + kChildViewPadding;
    CGAffineTransform travel = CGAffineTransformMakeTranslation (goingRight ? travelDistance : -travelDistance, 0);
    
    [[transitionContext containerView] addSubview:toViewController.view];
    toViewController.view.alpha = 0;
    toViewController.view.transform = CGAffineTransformInvert (travel);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:kDamping initialSpringVelocity:kInitialSpringVelocity options:0x00 animations:^{
        fromViewController.view.transform = travel;
       
        toViewController.view.transform = CGAffineTransformIdentity;
        toViewController.view.alpha = 1;
    } completion:^(BOOL finished) {
         fromViewController.view.alpha = 0;
        fromViewController.view.transform = CGAffineTransformIdentity;
        NSLog(@"to View frame origin %f %f",toViewController.view.frame.origin.x,toViewController.view.frame.origin.y);
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end

