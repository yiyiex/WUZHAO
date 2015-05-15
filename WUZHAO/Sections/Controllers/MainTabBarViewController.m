//
//  MainTabBarViewController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-19.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "HomeTableViewController.h"
#import "UITabBarController+HideTabBar.h"
#import "LaunchViewController.h"

//items of  viewcontrollers
#import "HomeTableViewController.h"
#import "SearchViewController.h"
#import "MineViewController.h"
#import "NoticeViewController.h"
#import "SCCaptureCameraController.h"
#import "RBStoryboardLink.h"
#import "SVProgressHUD.h"

#import "QDYHTTPClient.h"

#import "ApplicationUtility.h"

#import "macro.h"

typedef NS_ENUM(NSInteger, WZ_TABTAG) {
    WZ_HOME_TAB   = 0,
    WZ_SEARCH_TAB = 1,
    WZ_SHARE_TAB  = 2,
    WZ_NOTICE_TAB = 3,
    WZ_MINE_TAB   = 4

};

@interface MainTabBarViewController()
@property (nonatomic) NSInteger currentTabIndex ;

@property (nonatomic,strong) HomeTableViewController *homeTableViewCon;
@property (nonatomic,strong) SearchViewController *searchViewCon;
@property (nonatomic,strong) MineViewController *mineViewCon;
@property (nonatomic,strong) SCCaptureCameraController *photoShareViewCon;
@end

@implementation MainTabBarViewController 

- (instancetype) init
{
    self = [super init];   
    self.delegate = self;
    return  self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (SYSTEM_VERSION_EQUAL_TO(@"7"))
    {
        self.navigationController.navigationBar.translucent = NO;
    }
    
    self.delegate = self;
    self.currentTabIndex =0;
    [self activeCurrentTab];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(activeCurrentTab) name:@"finishPostImage" object:Nil];
      [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(activeTargetTab:) name:@"activeTargetTab" object:Nil];
      [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cancelShare) name:@"cancelShare" object:Nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshTabContent) name:@"uploadDataSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutCauseIllegalToken) name:@"tokenIllegal" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logOut) name:@"logOut" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateNoticeInfo:) name:@"updateNotificationNum" object:nil];
    
    
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarItem;
    
   // [[QDYHTTPClient sharedInstance]updateLocalUserInfo];
    //[self getNoticeNumber];
   // [self performSelectorInBackground:@selector(updateNoticeInfo) withObject:nil];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [self getNoticeNumber];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@""])
    {
        
    }
}
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
   // [self showNavBarAnimated:YES];
    
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}




#pragma mark =controllers delegate
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{

    if (item.tag == WZ_SHARE_TAB)
    {
        UIStoryboard *shareStorybaord = [UIStoryboard storyboardWithName:@"Share" bundle:nil];
        SCCaptureCameraController *captureViewController = [shareStorybaord instantiateViewControllerWithIdentifier:@"cameraController"];
        captureViewController.isStatusBarHiddenBeforeShowCamera = NO;
        [self presentViewController:captureViewController animated:YES completion:^{
            NSLog(@"show camera controller");
            
        }];
        
    }
    else
    {
        self.currentTabIndex = item.tag;
    }
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"selected controller%@",viewController);
    viewController.navigationItem.hidesBackButton = YES;
    NSLog(@"rbstorybaord viewController frame %f %f %f %f ",viewController.view.frame.origin.x,viewController.view.frame.origin.y,viewController.view.frame.size.width,viewController.view.frame.size.height);
    if ([viewController isKindOfClass:[RBStoryboardLink class]])
    {
        RBStoryboardLink *linkViewController = (RBStoryboardLink *)viewController;
        UIViewController *destinationViewController = linkViewController.scene;
        if ([destinationViewController isKindOfClass:[MineViewController class]])
        {
            MineViewController *mineViewController = (MineViewController *)destinationViewController;
            NSLog(@"mine viewController frame %f %f %f %f ",mineViewController.view.frame.origin.x,mineViewController.view.frame.origin.y,mineViewController.view.frame.size.width,mineViewController.view.frame.size.height);
            mineViewController.shouldBackToTop = YES;
            [mineViewController getLatestData];
        }
        if ( [destinationViewController isKindOfClass:[HomeTableViewController class]])
        {
            HomeTableViewController *homeTableViewController = (HomeTableViewController *)destinationViewController;
            [homeTableViewController setTableStyle:WZ_TABLEVIEWSTYLEHOME];
            [homeTableViewController GetLatestDataList];
            [homeTableViewController.tableView setContentOffset:CGPointMake(0,0) animated:YES];
            
            
        }
        if ( [destinationViewController isKindOfClass:[SearchViewController class]])
        {
            SearchViewController *searchViewController = (SearchViewController *)destinationViewController;
            [searchViewController getLatestData];            
        }
        if ([destinationViewController isKindOfClass:[NoticeViewController class]])
        {
            NoticeViewController *noticeViewController = (NoticeViewController *)destinationViewController;
            [noticeViewController getLatestData];
            //清空提示数量
            //给服务器发送已读信息
            //TO DO
            [[self.tabBar.items objectAtIndex:3]setBadgeValue:nil];
            [ApplicationUtility setApplicationIconBadgeWithNum:0];
        }
        
        
    }
}
-(void)activeCurrentTab
{
  
    self.selectedIndex = self.currentTabIndex;
    [self refreshTabContent];

}
-(void)activeTargetTab:(NSNotification *)notification
{
    NSNumber *index =(NSNumber *) [[notification userInfo]objectForKey:@"index"];
    [self activeTabbarAtIndex:[index integerValue]];
}
-(void)activeTabbarAtIndex:(NSInteger)index
{
    if (index != WZ_SHARE_TAB)
    {
        self.currentTabIndex = index;
        [self activeCurrentTab];
    }
    else
    {
        UIStoryboard *shareStorybaord = [UIStoryboard storyboardWithName:@"Share" bundle:nil];
        SCCaptureCameraController *captureViewController = [shareStorybaord instantiateViewControllerWithIdentifier:@"cameraController"];
        [self presentViewController:captureViewController animated:YES completion:^{
            NSLog(@"show camera controller");
        }];
    }
   
}

-(void)cancelShare
{
    self.selectedIndex = self.currentTabIndex;
}

-(void)refreshTabContent
{
    if (![self.selectedViewController isKindOfClass:[RBStoryboardLink class]])
    {
        return;
    }
    RBStoryboardLink *linkViewController = (RBStoryboardLink *)self.selectedViewController;
    UIViewController *destinationViewController = linkViewController.scene;
    switch (self.currentTabIndex)
    {
        case WZ_HOME_TAB:
            if ([destinationViewController isKindOfClass:[HomeTableViewController class]])
            {
                HomeTableViewController *homeTableViewController = (HomeTableViewController *)destinationViewController;
                [homeTableViewController setTableStyle:WZ_TABLEVIEWSTYLEHOME];
                [homeTableViewController GetLatestDataList];
                [homeTableViewController.tableView setContentOffset:CGPointMake(0,0) animated:YES];
            }
            break;
        case WZ_SEARCH_TAB:
            break;
        case WZ_SHARE_TAB:
            break;
        case WZ_MINE_TAB:
            if ([destinationViewController isKindOfClass:[MineViewController class]])
            {
                MineViewController *mineViewController = (MineViewController *)destinationViewController;
                mineViewController.shouldBackToTop = YES;
                [mineViewController getLatestData];
            }
            break;
        case WZ_NOTICE_TAB:
            if ([destinationViewController isKindOfClass:[NoticeViewController class]])
            {
                NoticeViewController *noticeViewController = (NoticeViewController *)destinationViewController;
                [noticeViewController getLatestData];
                //清空 提示数量
                //TO DO
                [[self.tabBar.items objectAtIndex:3]setBadgeValue:nil];
                [ApplicationUtility setApplicationIconBadgeWithNum:0];
                
            }
            break;
        default:
            break;
    }
}


-(void)getNoticeNumber
{
    //向服务器请求新通知数量
    //TO DO

}
-(void)updateNoticeInfo:(NSNotification *)notification
{
    NSNumber *index =(NSNumber *) [[notification userInfo]objectForKey:@"notificationNum"];
    [self setTabarBadgeWithData:index.stringValue atIndex:3];
}

-(void)setTabarBadgeWithData:(NSString *)data atIndex:(NSInteger)tabBarItemIndex
{
    [[self.tabBar.items objectAtIndex:tabBarItemIndex] setBadgeValue:data];
    
}



- (void)logoutCauseIllegalToken
{
    //[SVProgressHUD showInfoWithStatus:@"登录态失效，请重新登录"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"userId"];
    [defaults removeObjectForKey:@"userName"];
    [defaults removeObjectForKey:@"token"];
    [defaults removeObjectForKey:@"avatarUrl"];
    [defaults synchronize];
    [self.navigationController popToRootViewControllerAnimated:YES];

    
}
- (void)logOut
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger userId = [defaults integerForKey:@"userId"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[QDYHTTPClient sharedInstance]logOutWithUserId:userId whenComplete:^(NSDictionary *returnData) {
            if ([returnData objectForKey:@"data"])
            {
                NSLog(@"注销成功");
            }
            else
            {
                NSLog(@"注销失败");
            }
        }];
    });
    [defaults removeObjectForKey:@"userId"];
    [defaults removeObjectForKey:@"userName"];
    [defaults removeObjectForKey:@"token"];
    [defaults removeObjectForKey:@"avatarUrl"];
    [defaults synchronize];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}



@end
