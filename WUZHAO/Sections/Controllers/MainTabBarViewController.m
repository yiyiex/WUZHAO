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

//items of  viewcontrollers
#import "HomeTableViewController.h"
#import "SearchViewController.h"
#import "MineViewController.h"
#import "SCCaptureCameraController.h"
#import "RBStoryboardLink.h"

#import "macro.h"

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
    
    self.delegate = self;
    self.currentTabIndex =0;
   
    NSLog(@"%@",[[NSBundle mainBundle]bundleIdentifier]);

    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(activeCurrentTab) name:@"finishPostImage" object:Nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(uploadDataSuccess) name:@"uploadDataSuccess" object:nil];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];

    
}
- (void)viewDidAppear:(BOOL)animated
{
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@""])
    {
        
    }
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




#pragma mark =========controllers delegate============
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{

    if ([item.title isEqualToString:@"分享"])
    {
        UIStoryboard *shareStorybaord = [UIStoryboard storyboardWithName:@"Share" bundle:nil];
        SCCaptureCameraController *captureViewController = [shareStorybaord instantiateViewControllerWithIdentifier:@"cameraController"];
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
    if ([viewController isKindOfClass:[RBStoryboardLink class]])
    {
        RBStoryboardLink *linkViewController = (RBStoryboardLink *)viewController;
        UIViewController *destinationViewController = linkViewController.scene;
        if ([destinationViewController isKindOfClass:[MineViewController class]])
        {
            MineViewController *mineViewController = (MineViewController *)destinationViewController;
            [mineViewController getLatestData];
        }
        if ( [destinationViewController isKindOfClass:[HomeTableViewController class]])
        {
            HomeTableViewController *homeTableViewController = (HomeTableViewController *)destinationViewController;;
            [homeTableViewController GetLatestDataList];
            
        }
        
        
    }
}
-(void)activeCurrentTab
{
  
    self.selectedIndex = self.currentTabIndex;
    RBStoryboardLink *linkViewController = (RBStoryboardLink *)self.selectedViewController;
    UIViewController *destinationViewController = linkViewController.scene;
    switch (self.currentTabIndex)
    {
        case 0:
            break;
        case 1:
            break;
        case 2:
            break;
        case 3:
            break;
        default:
            break;
    }

}

-(void)uploadDataSuccess
{
    RBStoryboardLink *linkViewController = (RBStoryboardLink *)self.selectedViewController;
    UIViewController *destinationViewController = linkViewController.scene;
    switch (self.currentTabIndex)
    {
        case 0:
            if ([destinationViewController isKindOfClass:[HomeTableViewController class]])
            {
                HomeTableViewController *homeTableViewController = (HomeTableViewController *)destinationViewController;
                [homeTableViewController GetLatestDataList];
            }
            break;
        case 1:
            break;
        case 2:
            break;
        case 3:
            if ([destinationViewController isKindOfClass:[MineViewController class]])
            {
                MineViewController *mineViewController = (MineViewController *)destinationViewController;
                [mineViewController getLatestData];
            }
            break;
        default:
            break;
    }
}

-(void)hideTabBar
{
    //[self setTabBarHidden:YES animated:YES];
}

-(void)showTabBar
{
    //[self setTabBarHidden:NO animated:YES];
}




#pragma mar ------------------test appearence----------------

-(void)setNavigatorAppearance
{
    [[UINavigationBar appearance] setTintColor:THEME_COLOR_PARENT];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


@end
