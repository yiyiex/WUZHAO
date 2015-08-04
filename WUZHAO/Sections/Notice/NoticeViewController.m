//
//  NoticeViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/7/31.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "NoticeViewController.h"
#import "SystemNoticeViewController.h"
#import "PrivateLetterViewController.h"
#import "PlaceNoticeTableViewController.h"
#import "UIViewController+Basic.h"

#import "macro.h"


typedef NS_ENUM(NSInteger, ChildViewIndex)
{
    ChildViewIndexSystemNotice,
    ChildViewIndexPrivateLetter
};
@interface NoticeViewController()
@property (nonatomic, strong) SystemNoticeViewController * systemNoticeViewController;
@property (nonatomic, strong) PrivateLetterViewController *privateLetterViewController;
@property (nonatomic, strong) PlaceNoticeTableViewController *placeNoticeViewController;

@property (nonatomic, strong) UIView *LetterIndicator;
@property (nonatomic, strong) UIView *NoticeIndicator;
@property (nonatomic, strong) UIView *PlaceNoticeIndicator;

@end
@implementation NoticeViewController
{
    BOOL _isReload;
}
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setTitle:@"通 知"];
    }
    return self;
}
-(instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setTitle:@"通 知"];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setTitle:@"通 知"];
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateNoticeInfo:) name:@"updateNotificationNum" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updatePageContent:) name:@"updateNoticePage" object:nil];
    [self addSegmentIndicator];
    [self setBackItem];
    [self disableUserInteractive];
    
   // [self.containerView setContentInset:UIEdgeInsetsMake(64, 0, 44, 0)];
}

-(void)addSegmentIndicator
{
    float indicatorWidth = 8;
    float indicatorOffset;
    if (isIPHONE_4s || isIPHONE_5)
    {
        indicatorOffset = self.segmentedControl.frame.size.width/8-5;
    }
    else if (isIPHONE_6)
    {
        indicatorOffset = self.segmentedControl.frame.size.width/8-3;
    }
    else if (isIPHONE_6P)
    {
        indicatorOffset = self.segmentedControl.frame.size.width/8-1;
    }
    
    _NoticeIndicator = [[UIView alloc]initWithFrame:CGRectMake(self.segmentedControl.frame.size.width/3-indicatorOffset, 12, indicatorWidth, indicatorWidth)];
    _NoticeIndicator.layer.cornerRadius = indicatorWidth/2;
    _NoticeIndicator.layer.masksToBounds = YES;
    _NoticeIndicator.backgroundColor = THEME_COLOR_DARK;
    
    _LetterIndicator = [[UIView alloc]initWithFrame:CGRectMake(self.segmentedControl.frame.size.width/3*2-indicatorOffset, 12, indicatorWidth, indicatorWidth)];
    _LetterIndicator.layer.cornerRadius = indicatorWidth/2;
    _LetterIndicator.layer.masksToBounds = YES;
    _LetterIndicator.backgroundColor = THEME_COLOR_DARK;
    
    _PlaceNoticeIndicator = [[UIView alloc]initWithFrame:CGRectMake(self.segmentedControl.frame.size.width-indicatorOffset, 12, indicatorWidth, indicatorWidth)];
    _PlaceNoticeIndicator.layer.cornerRadius = indicatorWidth/2;
    _PlaceNoticeIndicator.layer.masksToBounds = YES;
    _PlaceNoticeIndicator.backgroundColor = THEME_COLOR_DARK;
    
    [self.segmentedControl addSubview:_NoticeIndicator];
    [self.segmentedControl addSubview:_LetterIndicator];
    [self.segmentedControl addSubview:_PlaceNoticeIndicator];
    [_NoticeIndicator setHidden:YES];
    [_LetterIndicator setHidden:YES];
    [_PlaceNoticeIndicator setHidden:YES];
    
}
#pragma mark - pagerViewController dataSource

-(NSArray *)childViewControllersForPagerViewController:(PagerViewController *)pagerViewController
{
    UIStoryboard *feedStory = [UIStoryboard storyboardWithName:@"Feeds" bundle:nil];
    
    SystemNoticeViewController *systemNoticeViewController = [feedStory instantiateViewControllerWithIdentifier:@"SystemNoticeViewController"];
    self.systemNoticeViewController = systemNoticeViewController;
    
    PrivateLetterViewController *privateLetterViewController = [feedStory instantiateViewControllerWithIdentifier:@"privateLetterViewController"];
    self.privateLetterViewController = privateLetterViewController;
    
    PlaceNoticeTableViewController *placeNoticeViewController = [feedStory instantiateViewControllerWithIdentifier:@"placeNoticeViewController"];
    self.placeNoticeViewController = placeNoticeViewController;
    return @[systemNoticeViewController,placeNoticeViewController,privateLetterViewController];
}

#pragma mark - control the model
-(void)getLatestData
{
    
    NSLog(@"%f",self.systemNoticeViewController.view.bounds.size.height);
    if (self.currentIndex == ChildViewIndexSystemNotice)
    {
        [self.systemNoticeViewController getLatestData];
    }
    else if (self.currentIndex == ChildViewIndexPrivateLetter)
    {
        [self.privateLetterViewController getLatestData];
    }
    
}

-(void)updatePageContent:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if ([[userInfo objectForKey:@"type"] isEqualToString:@"message"] )
    {
        [self.privateLetterViewController getLatestData];
    }
}

-(void)updateNoticeInfo:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if ([(NSNumber *)[userInfo objectForKey:@"messageNum"]integerValue]>0)
    {
        [self.LetterIndicator setHidden:NO];
    }
    else
    {
        [self.LetterIndicator setHidden:YES];
    }
    if ([(NSNumber *)[userInfo objectForKey:@"noticeNum"]integerValue]>0)
    {
        [self.NoticeIndicator setHidden:NO];
    }
    else
    {
        [self.NoticeIndicator setHidden:YES];
    }
    //TO DO
    //show place notice indicator
}
@end
