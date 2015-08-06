//
//  BasicViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/8/2.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "BasicViewController.h"

@interface BasicViewController ()

@end

@implementation BasicViewController

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initView];
    }
    return self;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self initView];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView
{
    //导航栏
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarItem;
    
    //
}

#pragma mark - navigation
-(void)setTransparentNav
{
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

#pragma mark - refresh control

//navigation right refresh aiv
-(void)setupRightBarRefreshAiv
{
    _refreshaiv = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc]initWithCustomView:_refreshaiv];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}
-(void)starRightBartAiv
{
    [_refreshaiv startAnimating];
}
-(void)stopRightBarAiv
{
    if (_refreshaiv)
    {
        if ([_refreshaiv isAnimating])
        {
            [_refreshaiv stopAnimating];
        }
    }
}
#pragma mark - keyboard

#pragma mark - basic transition
-(void)pushToViewController:(UIViewController *)viewController animated:(BOOL)animated hideBottomBar:(BOOL)hidden
{
    if (hidden)
    {
        //[[NSNotificationCenter defaultCenter ]postNotificationName:@"hideTabBar" object:nil];
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [self.navigationController pushViewController:viewController animated:animated];
}

-(void)goToPersonalPageWithUserInfo:(User *)user
{
    UIStoryboard *personalStoryboard= [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
    MineViewController *personalViewCon = [personalStoryboard instantiateViewControllerWithIdentifier:@"personalPage"];
    [personalViewCon setUserInfo:user];
    [self pushToViewController:personalViewCon animated:YES hideBottomBar:YES];
}
-(void)goToPOIPhotoListWithPoi:(POI *)poi
{
    UIStoryboard *addressStoryboard = [UIStoryboard storyboardWithName:@"Address" bundle:nil];
    AddressViewController *addressViewCon = [addressStoryboard instantiateViewControllerWithIdentifier:@"addressPage"];
    addressViewCon.poiId = poi.poiId;
    addressViewCon.poiName = poi.name;
    addressViewCon.poiLocation = poi.locationArray;
    addressViewCon.recommendFirstPostId = 0;
    [self pushToViewController:addressViewCon animated:YES hideBottomBar:YES];
}

@end
