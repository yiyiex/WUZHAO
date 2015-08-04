//
//  PagerViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/7/31.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "PagerViewController.h"
#import "ScrollViewOnlyHorizonScroll.h"

@interface PagerViewController ()<UIGestureRecognizerDelegate,UIScrollViewDelegate>

@property (nonatomic) NSUInteger currentIndex;

@end

@implementation PagerViewController
{
    NSUInteger _lastPageNum;
    CGFloat _lastContentOffset;
    NSUInteger _pageBeforeRotate;
    NSArray *_originalPagerChildViewControllers;
    CGSize _lastSize;
}
@synthesize currentIndex = _currentIndex;

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self pagerViewControllerInit];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self pagerViewControllerInit];
    }
    return self;
}

-(void)dealloc
{
    self.containerView.delegate = nil;
}

-(void)pagerViewControllerInit
{
    _currentIndex = 0;
    _delegate = self;
    _dataSource = self;
    _lastContentOffset = 0.0f;
    _isElasticIndicatorLimit = NO;
    _skipIntermediateViewControllers = YES;
    _isprogressiveIndicator = NO;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.containerView)
    {
        self.containerView = [[ScrollViewOnlyHorizonScroll alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
        self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.containerView];
    }
    self.containerView.bounces = NO;
    [self.containerView setAlwaysBounceHorizontal:NO];
    [self.containerView setAlwaysBounceVertical:NO];
    self.containerView.scrollsToTop = NO;
    self.containerView.delegate = self;
    self.containerView.showsVerticalScrollIndicator = YES;
    self.containerView.showsHorizontalScrollIndicator = YES;
    self.containerView.pagingEnabled = YES;
    self.containerView.backgroundColor = [UIColor lightGrayColor];
    self.containerView.autoresizesSubviews = NO;
    
    self.containerView.panGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self.containerView;
    if (self.dataSource)
    {
        _pagerChildViewControllers = [self.dataSource childViewControllersForPagerViewController:self];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _lastSize = self.containerView.bounds.size;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateIfNeeded];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self updateIfNeeded];
    if  ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending){
        // SYSTEM_VERSION_LESS_THAN 8.0
        [self.view layoutSubviews];
    }
}

-(void)disableUserInteractive
{
    for (UIViewController *childController in self.childViewControllers)
    {
         [childController.view.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
             [self.containerView.panGestureRecognizer requireGestureRecognizerToFail:(UIGestureRecognizer *)obj];
         }];
    }
}

#pragma mark - move to another view controller

-(void)moveToViewControllerAtIndex:(NSUInteger)index
{
    [self moveToViewControllerAtIndex:index animated:YES];
}

-(void)moveToViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    if (![self isViewLoaded])
    {
        self.currentIndex = index;
    }
    else
    {
        if (self.skipIntermediateViewControllers && ABS(self.currentIndex - index)>1)
        {
            NSArray *originalPagerChildViewControllers = self.pagerChildViewControllers;
            NSMutableArray *tempChildViewControllers = [NSMutableArray arrayWithArray:originalPagerChildViewControllers];
            
            //对调toPage的前一page 与fromPage 位置
            UIViewController *currentChildVC = [originalPagerChildViewControllers objectAtIndex:self.currentIndex];
            NSUInteger fromIndex = (self.currentIndex<index)? index - 1: index + 1;
            [tempChildViewControllers setObject:[originalPagerChildViewControllers objectAtIndex:fromIndex] atIndexedSubscript:self.currentIndex];
            [tempChildViewControllers setObject:currentChildVC atIndexedSubscript:fromIndex];
            _pagerChildViewControllers = tempChildViewControllers;
            [self.containerView setContentOffset:CGPointMake([self pageOffsetForChildIndex:fromIndex], 0) animated:NO];
            if (self.navigationController)
            {
                self.navigationController.view.userInteractionEnabled = NO;
            }
            else
            {
                self.view.userInteractionEnabled = NO;
            }
            _originalPagerChildViewControllers = originalPagerChildViewControllers;
            [self.containerView setContentOffset:CGPointMake([self pageOffsetForChildIndex:index], 0)animated:YES];
        }
        else
        {
            [self.containerView setContentOffset:CGPointMake([self pageOffsetForChildIndex:index], 0) animated:animated];
        }
    }
}

-(void)moveToViewController:(UIViewController *)viewController
{
    [self moveToViewControllerAtIndex:[self.pagerChildViewControllers indexOfObject:viewController]];
}

-(void)moveToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self moveToViewControllerAtIndex:[self.pagerChildViewControllers indexOfObject:viewController] animated:animated];
}

#pragma mark - PagerViewControllerDelegate
-(void)pagerViewController:(PagerViewController *)pagerViewController updateIndicatorFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    
}
-(void)pagerViewController:(PagerViewController *)pagerViewController updateIndicatorFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex withProgressPercentage:(CGFloat)progressPercentage
{
    
}
#pragma mark - PagerViewControllerDataSource

-(NSArray *)childViewControllersForPagerViewController:(PagerViewController *)pagerViewController
{
    return self.pagerChildViewControllers;
}

#pragma mark - helpers
-(void)updateIfNeeded
{
    if (!CGSizeEqualToSize(_lastSize, self.containerView.bounds.size))
    {
        [self updateContent];
    }
}


-(PagerDirection)scrollDirection
{
    if (self.containerView.contentOffset.x > _lastContentOffset){
        return PagerDirectionLeft;
    }
    else if (self.containerView.contentOffset.x < _lastContentOffset){
        return PagerDirectionRight;
    }
    return PagerDirectionNone;
}

-(BOOL)canMoveToIndex:(NSUInteger)index
{
    return (self.currentIndex != index && self.pagerChildViewControllers.count > index);
}

-(CGFloat)pageOffsetForChildIndex:(NSUInteger)index
{
    return (index * CGRectGetWidth(self.containerView.bounds));
}

-(CGFloat)offsetForChildIndex:(NSUInteger)index
{
    return (index * CGRectGetWidth(self.containerView.bounds) + ((CGRectGetWidth(self.containerView.bounds) - CGRectGetWidth(self.view.bounds)) * 0.5));
}

-(CGFloat)offsetForChildViewController:(UIViewController *)viewController
{
    NSInteger index = [self.pagerChildViewControllers indexOfObject:viewController];
    if (index == NSNotFound){
        @throw [NSException exceptionWithName:NSRangeException reason:nil userInfo:nil];
    }
    return [self offsetForChildIndex:index];
}

-(NSUInteger)pageForContentOffset:(CGFloat)contentOffset
{
    NSInteger result = [self virtualPageForContentOffset:contentOffset];
    return [self pageForVirtualPage:result];
}

-(NSInteger)virtualPageForContentOffset:(CGFloat)contentOffset
{
    NSInteger result = (contentOffset + (1.5f * [self pageWidth])) / [self pageWidth];
    return result - 1;
}

-(NSUInteger)pageForVirtualPage:(NSInteger)virtualPage
{
    if (virtualPage < 0){
        return 0;
    }
    if (virtualPage > self.pagerChildViewControllers.count - 1){
        return self.pagerChildViewControllers.count - 1;
    }
    return virtualPage;
}

-(CGFloat)pageWidth
{
    return CGRectGetWidth(self.containerView.bounds);
}

-(CGFloat)scrollPercentage
{
    if ([self scrollDirection] == PagerDirectionLeft || [self scrollDirection] == PagerDirectionNone){
        return fmodf(self.containerView.contentOffset.x, [self pageWidth]) / [self pageWidth];
    }
    return 1 - fmodf(self.containerView.contentOffset.x >= 0 ? self.containerView.contentOffset.x : [self pageWidth] + self.containerView.contentOffset.x, [self pageWidth]) / [self pageWidth];
}

-(void)updateContent
{
    
    if (!CGSizeEqualToSize(_lastSize, self.containerView.bounds.size)){
        _lastSize = self.containerView.bounds.size;
        [self.containerView setContentOffset:CGPointMake([self pageOffsetForChildIndex:self.currentIndex], 0) animated:NO];
    }
    NSArray * childViewControllers = self.pagerChildViewControllers;
    self.containerView.contentSize = CGSizeMake(CGRectGetWidth(self.containerView.bounds) * childViewControllers.count, CGRectGetHeight(self.containerView.bounds));
    
    [childViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIViewController * childController = (UIViewController *)obj;
        CGFloat pageOffsetForChild = [self pageOffsetForChildIndex:idx];
        if (fabs(self.containerView.contentOffset.x - pageOffsetForChild) < CGRectGetWidth(self.containerView.bounds)) {
            if (![childController parentViewController]) { // Add child
                [childController beginAppearanceTransition:YES animated:NO];
                [self addChildViewController:childController];
                
                CGFloat childPosition = [self offsetForChildIndex:idx];
                [childController.view setFrame:CGRectMake(childPosition, 0, CGRectGetWidth(self.containerView.bounds), CGRectGetHeight(self.containerView.bounds))];
                childController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                /*
                [childController.view.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if([obj isKindOfClass:[UIPanGestureRecognizer class]])
                    {
                        [self.containerView.panGestureRecognizer requireGestureRecognizerToFail:(UIGestureRecognizer *)obj];
                    }
                }];*/
                [self.containerView addSubview:childController.view];
                [childController didMoveToParentViewController:self];
                [childController endAppearanceTransition];
            } else {
                CGFloat childPosition = [self offsetForChildIndex:idx];
                [childController.view setFrame:CGRectMake(childPosition, 0, CGRectGetWidth(self.containerView.bounds), CGRectGetHeight(self.containerView.bounds))];
                childController.view.autoresizingMask =  UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
            }
        } else {
            if ([childController parentViewController]) { // Remove child
                [childController willMoveToParentViewController:nil];
                [childController beginAppearanceTransition:NO animated:NO];
                [childController.view removeFromSuperview];
                [childController removeFromParentViewController];
                [childController endAppearanceTransition];
            }
        }
    }];
    
    NSUInteger oldCurrentIndex = self.currentIndex;
    NSInteger virtualPage = [self virtualPageForContentOffset:self.containerView.contentOffset.x];
    NSUInteger newCurrentIndex = [self pageForVirtualPage:virtualPage];
    self.currentIndex = newCurrentIndex;
    if (self.isprogressiveIndicator){
        if ([self.delegate respondsToSelector:@selector(pagerViewController:updateIndicatorFromIndex:toIndex:withProgressPercentage:)]){
            CGFloat scrollPercentage = [self scrollPercentage];
            if (scrollPercentage > 0) {
                NSInteger fromIndex = self.currentIndex;
                NSInteger toIndex = self.currentIndex;
                PagerDirection scrollDirection = [self scrollDirection];
                if (scrollDirection == PagerDirectionLeft){
                    if (virtualPage > self.pagerChildViewControllers.count - 1){
                        fromIndex = self.pagerChildViewControllers.count - 1;
                        toIndex = self.pagerChildViewControllers.count;
                    }
                    else{
                        if (scrollPercentage > 0.5f){
                            fromIndex = MAX(toIndex - 1, 0);
                        }
                        else{
                            toIndex = fromIndex + 1;
                        }
                    }
                }
                else if (scrollDirection == PagerDirectionRight) {
                    if (virtualPage < 0){
                        fromIndex = 0;
                        toIndex = -1;
                    }
                    else{
                        if (scrollPercentage > 0.5f){
                            fromIndex = MIN(toIndex + 1, self.pagerChildViewControllers.count - 1);
                        }
                        else{
                            toIndex = fromIndex - 1;
                        }
                    }
                }
                [self.delegate pagerViewController:self updateIndicatorFromIndex:fromIndex toIndex:toIndex withProgressPercentage:(self.isElasticIndicatorLimit ? scrollPercentage : ( toIndex < 0 || toIndex >= self.pagerChildViewControllers.count ? 0 : scrollPercentage ))];
            }
        }
    }
    else{
        if ([self.delegate respondsToSelector:@selector(pagerViewController:updateIndicatorFromIndex:toIndex:)] && oldCurrentIndex != newCurrentIndex){
            [self.delegate pagerViewController:self updateIndicatorFromIndex:MIN(oldCurrentIndex, self.pagerChildViewControllers.count -1)  toIndex:newCurrentIndex];
        }
    }
}


-(void)reloadPagerView
{
    if ([self isViewLoaded]){
        [self.pagerChildViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIViewController * childController = (UIViewController *)obj;
            if ([childController parentViewController]){
                [childController.view removeFromSuperview];
                [childController willMoveToParentViewController:nil];
                [childController removeFromParentViewController];
            }
        }];
        _pagerChildViewControllers = self.dataSource ? [self.dataSource childViewControllersForPagerViewController:self] : @[];
        self.containerView.contentSize = CGSizeMake(CGRectGetWidth(self.containerView.bounds) * _pagerChildViewControllers.count,CGRectGetHeight(self.containerView.bounds));
        if (self.currentIndex >= _pagerChildViewControllers.count){
            self.currentIndex = _pagerChildViewControllers.count - 1;
        }
        [self.containerView setContentOffset:CGPointMake([self pageOffsetForChildIndex:self.currentIndex], 0)  animated:NO];
        [self updateContent];
    }
}

#pragma mark - UIScrollViewDelegte

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.containerView == scrollView){
        [self updateContent];
    }
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.containerView == scrollView){
        _lastPageNum = [self pageForContentOffset:scrollView.contentOffset.x];
        _lastContentOffset = scrollView.contentOffset.x;
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.containerView == scrollView && _originalPagerChildViewControllers){
        _pagerChildViewControllers = _originalPagerChildViewControllers;
        _originalPagerChildViewControllers = nil;
        if (self.navigationController){
            self.navigationController.view.userInteractionEnabled = YES;
        }
        else{
            self.view.userInteractionEnabled = YES;
        }
        [self updateContent];
    }
}

#pragma mark - Orientation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    _pageBeforeRotate = self.currentIndex;
    __typeof__(self) __weak weakSelf = self;
    
    UIInterfaceOrientation fromOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    [coordinator animateAlongsideTransition:nil
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                     [weakSelf didRotateFromInterfaceOrientation:fromOrientation];
                                 }];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    _pageBeforeRotate = self.currentIndex;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.currentIndex = _pageBeforeRotate;
    [self updateIfNeeded];
}


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // Determine if the touch is inside the custom subview
    if ([touch view] == self.containerView){
        // If it is, prevent all of the delegate's gesture recognizers
        // from receiving the touch
        return NO;
    }
    return YES;
}

@end
