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

#import "macro.h"

@interface MainTabBarViewController()
@property (nonatomic) NSInteger tabIndex ;

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
    self.tabIndex =0;
    NSLog(@"%@",[[NSBundle mainBundle]bundleIdentifier]);
    
   // [self activeCurrentTab];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(activeCurrentTab) name:@"finishPostImage" object:Nil];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@""])
    {
        
    }
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

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"selected controller%@",viewController);
    viewController.navigationItem.hidesBackButton = YES;
}
-(void)activeCurrentTab
{
   /* UILabel *l = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 40)];
    l.text = @"testLable";
    self.selectedIndex = self.tabIndex ;
    
    switch (self.tabIndex) {
        case 0:
            self.selectedViewController.navigationController.navigationBar.topItem.titleView =l;
            for (UIView *i in self.selectedViewController.navigationController.navigationBar.items )
            {
                NSLog(@"item :%@",i);
            }
            self.selectedViewController.navigationItem.title = @"test33333";
            break;
        case 1:
            self.navigationController.navigationBarHidden = YES;
            break;
        case 2:
            self.navigationController.navigationBarHidden = NO;
            self.navigationItem.hidesBackButton = YES;
            
            break;
        case 3:
            self.navigationController.navigationBarHidden = NO;
            self.navigationItem.hidesBackButton = YES;
            self.navigationController.title = @"个人主页";
        default:
            self.navigationController.navigationBarHidden = NO;
            self.navigationItem.hidesBackButton = YES;
            self.navigationController.title = @"动态";
            break;
    }
    [self setTabBarHidden:NO animated:YES];
    */
    self.selectedIndex = self.tabIndex;
    [self setTabBarHidden:NO animated:YES];
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
