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

static NSInteger loginState = 1;
@interface MainTabBarViewController()
{
    NSMutableArray *firstEntryFlag;
}
@property (nonatomic) NSInteger currentTabIndex ;
@property (nonatomic) BOOL shoudlRefreshCon;

@property (nonatomic,strong) UINavigationController *homeNav;
@property (nonatomic,strong) UINavigationController *searchNav;
@property (nonatomic,strong) UINavigationController *noticeNav;
@property (nonatomic,strong) UINavigationController *mineNav;

@property (nonatomic, strong) HomeTableViewController *homeViewController;
@property (nonatomic, strong) SearchViewController *searchViewController;
@property (nonatomic, strong) NoticeViewController *noticeViewController;
@property (nonatomic, strong) MineViewController *mineViewController;

@property (nonatomic,strong) UIButton *cameraButton;
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
    loginState = 1;
    [super viewDidLoad];

    [self initViewControllers];
    [self initTabbars];
    
    //init first entry flag
    firstEntryFlag =[NSMutableArray arrayWithArray:@[@0,@0,@0,@0,@0]];
    
    self.delegate = self;
    
    self.currentTabIndex = WZ_HOME_TAB;
    [self setSelectedIndex:self.currentTabIndex];
    firstEntryFlag[0] = @1;
    
    
    //重绘拍照按钮
    [self initCameraButton];
    
    //从通知中心启动，进入指定页面
    if ([[NSUserDefaults standardUserDefaults]valueForKey:@"launchIndex"])
    {
        self.selectedIndex  = self.currentTabIndex = [[[NSUserDefaults standardUserDefaults]valueForKey:@"launchIndex"]integerValue];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"launchIndex"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self activeCurrentTab];
    
    //register notification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(beginUploadPhotos) name:@"beginUploadPhotos" object:Nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(activeTargetTab:) name:@"activeTargetTab" object:Nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cancelShare) name:@"cancelShare" object:Nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutCauseIllegalToken) name:@"tokenIllegal" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logOut) name:@"logOut" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateNoticeInfo:) name:@"updateNotificationNum" object:nil];
    
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideTabBar) name:@"hideTabBar" object:nil];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showTabBar) name:@"showTabBar" object:nil];
    
    /*
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarItem;
     */
    
}

-(void)initViewControllers
{
    UIStoryboard *homeStoryboard = [UIStoryboard storyboardWithName:@"WhatsNew" bundle:nil];
    self.homeViewController = [homeStoryboard instantiateViewControllerWithIdentifier:@"HomeTableViewController"];
    
    UIStoryboard *searchStoryboard = [UIStoryboard storyboardWithName:@"Search" bundle:nil];
    self.searchViewController = [searchStoryboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    
    UIStoryboard *noticeStoryboard = [UIStoryboard storyboardWithName:@"Feeds" bundle:nil];
    self.noticeViewController = [noticeStoryboard instantiateViewControllerWithIdentifier:@"NoticeViewController"];
    
    UIStoryboard *mineStoryboard = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
    self.mineViewController = [mineStoryboard instantiateViewControllerWithIdentifier:@"personalPage"];
    
    self.homeNav = [[UINavigationController alloc]initWithRootViewController:self.homeViewController];
    self.searchNav = [[UINavigationController alloc]initWithRootViewController:self.searchViewController];
    self.noticeNav = [[UINavigationController alloc]initWithRootViewController:self.noticeViewController];
    self.mineNav = [[UINavigationController alloc]initWithRootViewController:self.mineViewController];
    UIViewController *blankViewCon = [[UIViewController alloc]init];
    NSMutableArray *viewControllers = [[NSMutableArray alloc]initWithObjects:self.homeNav,self.searchNav,blankViewCon, self.noticeNav,self.mineNav, nil];
    
    self.viewControllers = viewControllers;
}

-(void)initTabbars
{
    UITabBarItem *homeItem = self.tabBar.items[0];
    homeItem.tag = WZ_HOME_TAB;
    homeItem.image = [UIImage imageNamed:@"home.png"];
    
    UITabBarItem *searchItem = self.tabBar.items[1];
    searchItem.tag = WZ_SEARCH_TAB;
    searchItem.image = [UIImage imageNamed:@"magnifying-glass.png"];
    
    UITabBarItem *noticeItem = self.tabBar.items[3];
    noticeItem.tag = WZ_NOTICE_TAB;
    noticeItem.image = [UIImage imageNamed:@"bell.png"];
    
    UITabBarItem *mineItem = self.tabBar.items[4];
    mineItem.tag = WZ_MINE_TAB;
    mineItem.image = [UIImage imageNamed:@"person.png"];
    
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
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


#pragma mark - cameraButton
-(void)initCameraButton
{
    CGRect tabbarFrame = self.tabBar.frame;
    float tabbarWidth = tabbarFrame.size.width;
    float tabbarItemWidth = tabbarWidth/5;
    float tabbarHeight = tabbarFrame.size.height;
    
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(tabbarItemWidth*2, 0, tabbarItemWidth, tabbarHeight)];
    [self.tabBar addSubview:backView];

    float buttonWidth = tabbarHeight - 4;
    _cameraButton = [[UIButton alloc]initWithFrame:CGRectMake((tabbarFrame.size.width - buttonWidth)/2,(tabbarHeight - buttonWidth)/2 , buttonWidth, buttonWidth)];
    [_cameraButton setBackgroundImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
      [_cameraButton setBackgroundImage:[UIImage imageNamed:@"camera_dark"] forState:UIControlStateHighlighted];
    [_cameraButton setBackgroundImage:[UIImage imageNamed:@"camera_dark"] forState:UIControlStateSelected];
    [_cameraButton addTarget:self action:@selector(cameraButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.tabBar addSubview:_cameraButton];
 
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
        if (self.currentTabIndex == item.tag || [firstEntryFlag[item.tag]integerValue] == 0)
        {
            self.shoudlRefreshCon = true;
            self.currentTabIndex = item.tag;
            firstEntryFlag[item.tag] = @1;
        
            return;
        }
        self.currentTabIndex = item.tag;
        self.shoudlRefreshCon = false;
    }
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"selected controller%@",viewController);
    viewController.navigationItem.hidesBackButton = YES;
    NSLog(@"rbstorybaord viewController frame %f %f %f %f ",viewController.view.frame.origin.x,viewController.view.frame.origin.y,viewController.view.frame.size.width,viewController.view.frame.size.height);
    if(self.currentTabIndex == WZ_NOTICE_TAB)
    {
        [self.noticeViewController getLatestData];
        /*
        [[self.tabBar.items objectAtIndex:3]setBadgeValue:nil];
        [ApplicationUtility setApplicationIconBadgeWithNum:0];*/
        
    }
    if (!self.shoudlRefreshCon)
    {
        return;
    }
    if (self.currentTabIndex == WZ_HOME_TAB)
    {
        
        [self.homeViewController setTableStyle:WZ_TABLEVIEWSTYLE_HOME];
        [self.homeViewController GetLatestDataList];
    }
    if (self.currentTabIndex == WZ_SEARCH_TAB)
    {
        
        [self.searchViewController getLatestData];
    }
    if (self.currentTabIndex == WZ_MINE_TAB)
    {
 
        self.mineViewController.shouldBackToTop = YES;
        [self.mineViewController getLatestData];
    }
}
#pragma mark - button action
-(void)cameraButtonClick:(UIButton *)sender
{
    UIStoryboard *shareStorybaord = [UIStoryboard storyboardWithName:@"Share" bundle:nil];
    SCCaptureCameraController *captureViewController = [shareStorybaord instantiateViewControllerWithIdentifier:@"cameraController"];
    captureViewController.isStatusBarHiddenBeforeShowCamera = NO;
    [self presentViewController:captureViewController animated:YES completion:^{
        NSLog(@"show camera controller");
        
    }];
}

#pragma mark - tabbar method
-(void)hideTabBar
{
    //self.tabBar.hidden = YES;
    [self setTabBarHidden:YES animated:YES];
}

-(void)showTabBar
{
   // self.tabBar.hidden = NO;
    [self setTabBarHidden:NO animated:YES];
}


-(void)beginUploadPhotos
{
    [self dismissViewControllerAnimated:YES completion:^{
        self.selectedIndex = self.currentTabIndex = WZ_HOME_TAB;
        [self activeCurrentTab];
    }];
}

-(void)activeCurrentTab
{
    if (self.selectedIndex != self.currentTabIndex )
    {
        self.selectedIndex = self.currentTabIndex;
    }
    else
    {
        [self refreshTabContent];
    }

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
        /*
        if (index == WZ_NOTICE_TAB)
        {
            [[self.tabBar.items objectAtIndex:3]setBadgeValue:nil];
            [ApplicationUtility setApplicationIconBadgeWithNum:0];
        }*/
        
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
    switch (self.currentTabIndex)
    {
        case WZ_HOME_TAB:
            [self.homeViewController setTableStyle:WZ_TABLEVIEWSTYLE_HOME];
            [self.homeViewController GetLatestDataList];
            break;
        case WZ_SEARCH_TAB:
            break;
        case WZ_SHARE_TAB:
            break;
        case WZ_MINE_TAB:
            self.mineViewController.shouldBackToTop = YES;
            [self.mineViewController getLatestData];
            break;
        case WZ_NOTICE_TAB:
            [self.noticeViewController getLatestData];
           // [[self.tabBar.items objectAtIndex:3]setBadgeValue:nil];
           // [ApplicationUtility setApplicationIconBadgeWithNum:0];
            break;
        default:
            break;
    }
}

#pragma mark - badge and notice

-(void)updateNoticeInfo:(NSNotification *)notification
{
    NSNumber *index =(NSNumber *) [[notification userInfo]objectForKey:@"notificationNum"];
    if (index.integerValue >0)
    {
        [self setTabarBadgeWithData:index.stringValue atIndex:3];
    }
    else
    {
        [self setTabarBadgeWithData:nil atIndex:3];
    }
}

-(void)setTabarBadgeWithData:(NSString *)data atIndex:(NSInteger)tabBarItemIndex
{
    [[self.tabBar.items objectAtIndex:tabBarItemIndex] setBadgeValue:data];
    
}


#pragma mark - logout
- (void)logoutCauseIllegalToken
{
    if (loginState == 1)
    {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"userId"];
        [defaults removeObjectForKey:@"userName"];
        [defaults removeObjectForKey:@"token"];
        [defaults removeObjectForKey:@"avatarUrl"];
        [defaults synchronize];
        
        //reset entry flag
        firstEntryFlag =[NSMutableArray arrayWithArray:@[@0,@0,@0,@0,@0]];
        self.selectedIndex = self.currentTabIndex =  WZ_HOME_TAB;
        firstEntryFlag[0] = @1;
        UIStoryboard *launchStoryboard = [UIStoryboard storyboardWithName:@"Launch" bundle:nil];
        LaunchViewController *launch = [launchStoryboard instantiateViewControllerWithIdentifier:@"launchView"];
       // [self.navigationController popToRootViewControllerAnimated:YES];
        NSLog(@"logout cause illegal token");
        WEAKSELF_WZ
        launch.dismiss = ^(void)
        {
            weakSelf_WZ.selectedIndex = weakSelf_WZ.currentTabIndex = WZ_HOME_TAB;
            [weakSelf_WZ refreshTabContent];
        };
        [self presentViewController:launch animated:YES completion:^{
            loginState = 0;
            // [SVProgressHUD showInfoWithStatus:@"登录态失效，请重新登录"];
        }];
       
    }

    
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
    
    //reset entry flag
    firstEntryFlag =[NSMutableArray arrayWithArray:@[@0,@0,@0,@0,@0]];
    self.selectedIndex = self.currentTabIndex = WZ_HOME_TAB;
    firstEntryFlag[0] = @1;
    UIStoryboard *launchStoryboard = [UIStoryboard storyboardWithName:@"Launch" bundle:nil];
    LaunchViewController *launch = [launchStoryboard instantiateViewControllerWithIdentifier:@"launchView"];
    WEAKSELF_WZ
    launch.dismiss = ^(void)
    {
        weakSelf_WZ.selectedIndex = weakSelf_WZ.currentTabIndex = WZ_HOME_TAB;
        [weakSelf_WZ activeCurrentTab];

        NSLog(@"test");
    };
    [self presentViewController:launch animated:YES completion:^{
        loginState = 0;
    }];
   // [self.navigationController popToRootViewControllerAnimated:YES];
    
}




@end
