//
//  SegmentPagerViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/7/31.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//
#import "PagerViewController.h"
#import "SegmentPagerViewController.h"

#import "macro.h"

@interface SegmentPagerViewController()


@property (nonatomic) BOOL shouldUpdateSegmentedControl;

@end
@implementation SegmentPagerViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.shouldUpdateSegmentedControl = YES;
        self.isprogressiveIndicator = NO;
    }
    return self;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.shouldUpdateSegmentedControl = YES;
        self.isprogressiveIndicator = NO;
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.segmentedControl.superview)
    {
        [self.navigationItem setTitleView:self.segmentedControl];
    }
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
    [self reloadSegmentedControl];
}
-(HMSegmentedControl *)segmentedControl
{
    if (_segmentedControl) return _segmentedControl;
    //_segmentedControl = [[HMSegmentedControl alloc]init];
    _segmentedControl = [[HMSegmentedControl alloc]initWithFrame:CGRectMake(0, 0, WZ_APP_SIZE.width-100, 44)];
    [_segmentedControl setBackgroundColor:[UIColor clearColor]];
    _segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : THEME_COLOR_LIGHT_GREY,NSFontAttributeName:WZ_FONT_LARGE_SIZE};
    _segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : THEME_COLOR_DARK_GREY,NSFontAttributeName:WZ_FONT_LARGER_SIZE};
    [_segmentedControl setSelectionIndicatorColor:THEME_COLOR_DARK_GREY_BIT_PARENT];
    _segmentedControl.selectionIndicatorHeight = 2.50f;
    
    _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    return _segmentedControl;
}

-(void)reloadPagerView
{
    [super reloadPagerView];
    if ([self isViewLoaded])
    {
        [self reloadSegmentedControl];
    }
}


#pragma mark - Helpers

-(void)reloadSegmentedControl
{
    __block NSMutableArray *segmentTitle = [[NSMutableArray alloc]init];
    __block NSMutableArray *segmentImage = [[NSMutableArray alloc]init];
    [self.pagerChildViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSAssert([obj conformsToProtocol:@protocol(PagerViewControllerItem)], @"child view controller must conform to XLPagerTabStripChildItem");
        UIViewController<PagerViewControllerItem> * childViewController = (UIViewController<PagerViewControllerItem> *)obj;
        if ([childViewController respondsToSelector:@selector(imageForPagerViewController:)]){
            [segmentImage insertObject:[childViewController imageForPagerViewController:self] atIndex:idx];
        }
        else{
            if ([childViewController respondsToSelector:@selector(titleForPagerViewController:)])
            {
               [segmentTitle insertObject:[childViewController titleForPagerViewController:self] atIndex:idx];
            }
        }
        
    }];
    if (segmentTitle.count == 0)
    {
        segmentTitle = @[@"test1",@"test2"];
    }
    self.segmentedControl.sectionTitles = segmentTitle;
    self.segmentedControl.sectionImages = segmentImage;
    [self.segmentedControl setSelectedSegmentIndex:self.currentIndex animated:YES];
    //[self.segmentedControl setTintColor:[[self.pagerChildViewControllers objectAtIndex:self.currentIndex]colorForPagerViewController:self]];
}

#pragma mark - Events


-(void)segmentedControlChanged:(UISegmentedControl *)sender
{
    NSInteger index = [sender selectedSegmentIndex];
    [self pagerViewController:self updateIndicatorFromIndex:0 toIndex:index];
    self.shouldUpdateSegmentedControl = NO;
    [self moveToViewControllerAtIndex:index];
}


#pragma mark - XLPagerTabStripViewControllerDelegate

-(void)pagerViewController:(PagerViewController *)pagerViewController updateIndicatorFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex 
{
    if (self.shouldUpdateSegmentedControl){
        UIViewController<PagerViewControllerItem> * childViewController = (UIViewController<PagerViewControllerItem> *)[self.pagerChildViewControllers objectAtIndex:toIndex];
        [self.segmentedControl setSelectedSegmentIndex:[self.pagerChildViewControllers indexOfObject:childViewController] animated:YES];
    }
    
}


-(void)pagerViewController:(PagerViewController *)pagerViewController updateIndicatorFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex withProgressPercentage:(CGFloat)progressPercentage
{
    if (self.shouldUpdateSegmentedControl){
        NSInteger currentIndex = (progressPercentage > 0.5) ? toIndex : fromIndex;
        [self.segmentedControl setSelectedSegmentIndex:MIN(MAX(0, currentIndex), self.pagerChildViewControllers.count -1) animated:YES];
    }
}



#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.shouldUpdateSegmentedControl = YES;
    [super scrollViewDidScroll:scrollView];
   
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.shouldUpdateSegmentedControl = YES;
    [super scrollViewDidEndScrollingAnimation:scrollView];
   
   
}

@end
