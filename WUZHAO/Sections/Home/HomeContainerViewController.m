//
//  HomeContainerViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/8/1.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "HomeContainerViewController.h"
#import "macro.h"

typedef NS_ENUM(NSInteger, ChildViewIndex)
{
    ChildViewIndexSuggest,
    ChildViewIndexHome,
    ChildViewAddress
};
@interface HomeContainerViewController ()

@property (nonatomic, strong) HomeTableViewController *homeTableViewController;
@property (nonatomic, strong) AddressListTableViewController *addressListController;
@property (nonatomic, strong) HomeTableViewController *suggestTableViewController;
@end

@implementation HomeContainerViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.containerView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self initView];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(beginUploadPhotos) name:@"beginUploadPhotos" object:Nil];
    //self.containerView.userInteractionEnabled = NO;
    // Do any additional setup after loading the view.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - pagerViewController DataSource
-(NSArray *)childViewControllersForPagerViewController:(PagerViewController *)pagerViewController
{
    UIStoryboard *homeStoryboard = [UIStoryboard storyboardWithName:@"WhatsNew" bundle:nil];
    self.homeTableViewController = [homeStoryboard instantiateViewControllerWithIdentifier:@"HomeTableViewController"];
    self.homeTableViewController.tableStyle = WZ_TABLEVIEWSTYLE_HOME;
    self.addressListController = [homeStoryboard instantiateViewControllerWithIdentifier:@"addressListView"];
    self.suggestTableViewController = [homeStoryboard instantiateViewControllerWithIdentifier:@"HomeTableViewController"];
    self.suggestTableViewController.tableStyle = WZ_TABLEVIEWSTYLE_SUGGEST;
    return @[self.suggestTableViewController,self.homeTableViewController,self.addressListController];
}

-(void)initView
{
    [self setTitle:@"主 页"];
    [self setBackItem];
}
-(void)getLatestData
{
    if (!self.containerView || !self.homeTableViewController || !self.addressListController)
        return;
    if (self.currentIndex == ChildViewIndexSuggest)
    {
        [self.suggestTableViewController getLatestData];
    }
    else if (self.currentIndex == ChildViewIndexHome)
    {
        [self.homeTableViewController getLatestData];
    }
    else if (self.currentIndex == ChildViewAddress)
    {
        [self.addressListController getLatestData];
    }
}

-(void)beginUploadPhotos
{
    [self moveToViewControllerAtIndex:ChildViewIndexHome];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
