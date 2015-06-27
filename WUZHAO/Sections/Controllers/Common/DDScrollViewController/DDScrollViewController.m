//
//  DDScrollViewController.m
//  
//
//  Created by Hirat on 13-11-8.
//
//

#import "DDScrollViewController.h"

@interface DDScrollViewController () <UIScrollViewDelegate>
@property UIScrollView *scrollView;
@property NSMutableArray *contents;
@property (nonatomic) CGFloat offsetRatio;
@property (nonatomic) NSInteger activeIndex;
@end

@implementation DDScrollViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initControl];
    
    [self reloadData];
}

- (void)initControl
{
    self.contents = [[NSMutableArray alloc] init];
    for (int i = 0; i < 3; i ++)
    {
        [self.contents addObject:[NSNull null]];
    }
    CGRect scrollviewFrame = self.view.frame;
    self.scrollView = [[UIScrollView alloc] initWithFrame: scrollviewFrame];
    self.scrollView.bounds = scrollviewFrame;
    NSLog(@"scrollview controller view frame %f %f %f %f",self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.width,self.view.frame.size.height);
   // self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame) * 3, FLT_MAX);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.backgroundColor  = [UIColor greenColor];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.scrollView setAlwaysBounceVertical:NO];
    [self.scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.scrollView setDirectionalLockEnabled:YES];
    self.scrollView.delegate = self;
    [self.view addSubview: self.scrollView];
}

#pragma mark -


- (void)reloadData
{
    for (UIView *view in self.scrollView.subviews)
    {
        if ([view isKindOfClass:[UITableView class]])
        {
            [view removeFromSuperview];
        }
    }
    if (self.numberOfControllers == 1)
    {
        [self.contents replaceObjectAtIndex:0 withObject:[self.dataSource ddScrollView:self contentViewControllerAtIndex:0]];
        [self.contents replaceObjectAtIndex:1 withObject:[NSNull null]];
        [self.contents replaceObjectAtIndex:2 withObject:[NSNull null]];
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), self.view.frame.size.height);
        UIViewController* viewController = [self.contents objectAtIndex:0];
        UITableView* view = (UITableView *)viewController.view;
        view.scrollEnabled = false;
        view.userInteractionEnabled = YES;
        view.frame = self.scrollView.frame;
        
        [self.scrollView addSubview: view];
        
        [self.scrollView setContentOffset:CGPointMake(0,  0)];
        return;
        
    }

    else if (self.numberOfControllers >= 2)
    {
        
        for (int i = 0; i < 3; i ++)
        {
            NSInteger thisPage = self.activeIndex -1 +i;
            if (thisPage == self.numberOfControllers)
            {
                [self.contents replaceObjectAtIndex:i withObject:[NSNull null]];

            }
            else if (thisPage == -1)
            {
                //到最前面了
                [self.contents replaceObjectAtIndex:i withObject:[NSNull null]];

            }        
            else
            {
                [self.contents replaceObjectAtIndex:i withObject:[self.dataSource ddScrollView:self contentViewControllerAtIndex:thisPage]];
            }
        }
    }
    //in the middle of the scrollview
    if ((NSNull *)[self.contents objectAtIndex:0 ]!= [NSNull null] && (NSNull *)[self.contents objectAtIndex:2]!= [NSNull null])
    {
        float contentSizeWidth = CGRectGetWidth(self.view.frame) * 3;
        self.scrollView.contentSize = CGSizeMake(contentSizeWidth, self.view.frame.size.height);
        for (int i = 0; i < 3; i++)
        {
            UIViewController* viewController = [self.contents objectAtIndex:i];
            UITableView* view = (UITableView *)viewController.view;
            view.scrollEnabled = false;
            view.userInteractionEnabled = YES;
            view.frame = self.scrollView.frame;
            view.frame = CGRectOffset(self.scrollView.frame, view.frame.size.width * i, 0);
            [self.scrollView addSubview: view];
        }
        
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width + self.scrollView.frame.size.width * self.offsetRatio,  64)];
    }
    //the left side of the scrollview when dataCount>=3
    else if ((NSNull *)[self.contents objectAtIndex:0] == [NSNull null])
    {
 
       self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame) * 2,  self.view.frame.size.height);
        for (int i = 0;i <2; i++)
        {
            UIViewController* viewController = [self.contents objectAtIndex:(i+1)];
            UITableView* view = (UITableView *)viewController.view;
            view.scrollEnabled = false;
            view.userInteractionEnabled = YES;
            view.frame = self.scrollView.frame;
            view.frame = CGRectOffset(self.scrollView.frame, view.frame.size.width * i, 0);
            [self.scrollView addSubview: view];
        }
        
        [self.scrollView setContentOffset:CGPointMake(0,  0)];
    }
    //the right side of the scrollview when dataCount>=3
    else if ((NSNull *)[self.contents objectAtIndex:2] == [NSNull null])
    {
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame) * 2, self.view.frame.size.height);
        for (int i = 0;i <2; i++)
        {
            UIViewController* viewController = [self.contents objectAtIndex:i];
            UITableView* view = (UITableView *) viewController.view;
            view.scrollEnabled = false;
            view.userInteractionEnabled = YES;
            view.frame = self.scrollView.frame;
            view.frame = CGRectOffset(self.scrollView.frame, view.frame.size.width * i, 0);
            [self.scrollView addSubview: view];
        }
        
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width, 0)];
    }

    
}

- (NSInteger)validIndexValue:(NSInteger)value
{
    //轮播
    if(value == -1)
    {
        value = 0;
    }
    
    if(value == self.numberOfControllers)
    {
        value = value-1;
    }
    
    return value;
}

- (void)setActiveIndex:(NSInteger)activeIndex
{
    if (_activeIndex != activeIndex)
    {
        _activeIndex = activeIndex;
        [self reloadData];
    }
}

- (NSInteger)numberOfControllers
{
    return [self.dataSource numberOfViewControllerInDDScrollView:self];
}

- (void)setOffsetRatio:(CGFloat)offsetRatio
{
    
    if (_offsetRatio != offsetRatio)
    {
        //_offsetRatio = offsetRatio;
        if (offsetRatio == 0)
        {
            return;
        }
        NSInteger numberOfViews = self.scrollView.contentSize.width/CGRectGetWidth(self.scrollView.frame);
        //[self.scrollView setContentOffset:CGPointMake((numberOfViews -2)*self.scrollView.frame.size.width + self.scrollView.frame.size.width * offsetRatio, 0)];

        
        if ((NSNull *)[self.contents objectAtIndex:0 ]!= [NSNull null] && (NSNull *)[self.contents objectAtIndex:2]!= [NSNull null])
        {
            if (offsetRatio > 0.5 )
            {
                _offsetRatio = offsetRatio - 1;
                //self.activeIndex = self.activeIndex +1;
                self.activeIndex = [self validIndexValue: (self.activeIndex + 1)];
                NSLog(@"active index:%ld",(long)self.activeIndex);
            }
            
            if (offsetRatio < -0.5)
            {
                _offsetRatio = offsetRatio + 1;
               // self.activeIndex = self.activeIndex-1;
                self.activeIndex = [self validIndexValue: (self.activeIndex - 1)];
                 NSLog(@"active index:%ld",(long)self.activeIndex);
            }
        }
        else if (numberOfViews == 2)
        {
            if(offsetRatio == 0 && ((NSNull *)[self.contents objectAtIndex:0] == [NSNull null]))
            {
                _offsetRatio = offsetRatio +1;
            }
            if (offsetRatio >0.5 && offsetRatio <=1   &&  ((NSNull *)[self.contents objectAtIndex:0] == [NSNull null]))
            {
                _offsetRatio = offsetRatio - 1;
                self.activeIndex = [self validIndexValue: (self.activeIndex + 1)];
                 NSLog(@"active index:%ld",(long)self.activeIndex);
                
            }
            else if (offsetRatio <0.5 && offsetRatio >=0 &&  ((NSNull *)[self.contents objectAtIndex:2] == [NSNull null]))
            {
                
                self.activeIndex = [self validIndexValue: (self.activeIndex - 1)];
                 NSLog(@"active index:%ld",(long)self.activeIndex);
                _offsetRatio = offsetRatio +1;
            }
        }
   
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.scrollView.contentOffset.x!=0 &self.scrollView.contentOffset.y !=0)
    {
        return;
    }

    if (scrollView.contentSize.width/scrollView.frame.size.width ==3)
    {
        self.offsetRatio = scrollView.contentOffset.x/CGRectGetWidth(scrollView.frame) - 1;
        return;
    }
    else if (scrollView.contentSize.width/scrollView.frame.size.width ==2)
    {
        self.offsetRatio = scrollView.contentOffset.x/CGRectGetWidth(scrollView.frame) ;
        return;
    }
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}
-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return false;
}




@end
