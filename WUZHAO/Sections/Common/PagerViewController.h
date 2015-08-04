//
//  PagerViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/7/31.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UITableViewController.h>
@class PagerViewController;

@protocol PagerViewControllerItem <NSObject>

@required

-(NSString *)titleForPagerViewController:(PagerViewController *) pagerViewController;

@optional

-(UIImage *)imageForPagerViewController:(PagerViewController *)pagerViewController;
-(UIColor *)colorForPagerViewController:(PagerViewController *)pagerViewController;

@end

typedef NS_ENUM(NSUInteger, PagerDirection)
{
    PagerDirectionLeft,
    PagerDirectionRight,
    PagerDirectionNone
};

@protocol PagerViewControllerDelegate <NSObject>

@optional

-(void)pagerViewController:(PagerViewController *)pagerViewController updateIndicatorFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

-(void)pagerViewController:(PagerViewController *)pagerViewController updateIndicatorFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex withProgressPercentage:(CGFloat)progressPercentage;

@end

@protocol PagerViewControllerDataSource <NSObject>

@required

-(NSArray *)childViewControllersForPagerViewController:(PagerViewController *)pagerViewController;

@end

@interface PagerViewController : UIViewController<PagerViewControllerDelegate,PagerViewControllerDataSource,UIScrollViewDelegate>

@property (readonly) NSArray *pagerChildViewControllers;
@property (nonatomic,retain) IBOutlet UIScrollView *containerView;
@property (nonatomic,assign) IBOutlet id<PagerViewControllerDelegate> delegate;
@property (nonatomic,assign) IBOutlet id<PagerViewControllerDataSource> dataSource;

@property (readonly) NSUInteger currentIndex;
@property BOOL skipIntermediateViewControllers;
@property BOOL isprogressiveIndicator;
@property BOOL isElasticIndicatorLimit;

-(void)disableUserInteractive;
-(void)moveToViewControllerAtIndex:(NSUInteger)index;
-(void)moveToViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated;
-(void)moveToViewController:(UIViewController *)viewController;
-(void)moveToViewController:(UIViewController *)viewController animated:(BOOL)animated;
-(void)reloadPagerView;

@end
