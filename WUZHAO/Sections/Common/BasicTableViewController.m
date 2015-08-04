//
//  BasicTableViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/8/2.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "BasicTableViewController.h"
#import "AddressViewController.h"
#import "macro.h"

@interface BasicTableViewController ()

@end

@implementation BasicTableViewController
@dynamic refreshControl;
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
    self.shouldRefreshData = YES;
    //默认分页
    self.shouldLoadMore = NO;
    
    //导航栏
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarItem;
    
    //
}

-(void)setDatasource:(NSMutableArray *)datasource
{
    _datasource = datasource;
}

#pragma mark - refreshControl;
-(void)setupRefreshControl
{
    //refresh control
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refreshByPullingTable:) forControlEvents:UIControlEventValueChanged];
}


-(void)refreshByPullingTable:(id)sender
{
    if (self.shouldRefreshData)
    {
        if (self.getLatestDataBlock)
        {
            self.getLatestDataBlock();
        }
        else
        {
            NSLog(@"get latest data list when pull to refresh");
            [self getLatestData];
        }
    }
    else if ([self.refreshControl isRefreshing])
    {
        [self.refreshControl endRefreshing];
    }
}

-(void)getLatestData;
{
    [self.tableView setContentOffset:CGPointMake(0, 0)];
    if ([self.refreshControl isRefreshing])
    {
        [self.refreshControl endRefreshing];
    }
    return;
}


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

//load more
-(void)setupLoadMore
{
    if (!_loadMoreButton && self.shouldLoadMore)
    {
        NSString *footButonTitle = @"加载更多" ;
        UIView *tableFooterView = [[UIView alloc]init];
        tableFooterView.frame = CGRectMake(0, 0, WZ_APP_SIZE.width, 44);
        self.tableView.tableFooterView = tableFooterView;
        
        _loadMoreButton = [[UIButton alloc]init];
        _loadMoreButton.frame = CGRectMake(0, 0, WZ_APP_SIZE.width, 44);
        [_loadMoreButton setTitle:footButonTitle forState:UIControlStateNormal];
        [_loadMoreButton.titleLabel setFont:WZ_FONT_SMALL_READONLY];
        [_loadMoreButton setTitleColor:THEME_COLOR_LIGHT_GREY forState:UIControlStateNormal];
        [_loadMoreButton addTarget:self action:@selector(loadMore) forControlEvents:UIControlEventTouchUpInside];
        [self.tableView.tableFooterView addSubview:_loadMoreButton];
        
        _loadMoreAiv = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _loadMoreAiv.center = _loadMoreButton.center;
        [self.tableView.tableFooterView addSubview:_loadMoreAiv];
    }
}

-(void)loadMore
{
    [self.loadMoreButton setTitle:@"没有更多数据了" forState:UIControlStateNormal];
    [self.loadMoreAiv stopAnimating];
    [self.loadMoreButton setHidden:NO];
    return;
}

#pragma mark - control the model
-(void)loadData
{
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointMake(0, 0)];
    if (self.refreshControl.isRefreshing)
    {
        double delayInseconds = 0.2;
        dispatch_time_t popTime =  dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInseconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
        });
    }
}

#pragma mark - scrollview delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //NSLog(@"scroll view did end dragging");
    
}


-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    //loadmore
    if (self.shouldLoadMore)
    {
        CGPoint loadMorePoint = CGPointMake(0, self.tableView.contentSize.height);
        CGPoint targetPoint = *targetContentOffset;
        float almostToBottomOffset = 0.0f;
        if (targetPoint.y > loadMorePoint.y - WZ_APP_SIZE.height + almostToBottomOffset)
        {
            if (self.loadMoreDataBlock)
            {
                self.loadMoreDataBlock();
            }
            else
            {
                [self performSelectorOnMainThread:@selector(loadMore) withObject:self waitUntilDone:NO];
            }
        }
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _datasource.count;
}


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
#pragma mark - transition
-(void)goToPOIPhotoListWithPoi:(POI *)poi
{
    UIStoryboard *addressStoryboard = [UIStoryboard storyboardWithName:@"Address" bundle:nil];
    AddressViewController *addressViewCon = [addressStoryboard instantiateViewControllerWithIdentifier:@"addressPage"];
    addressViewCon.poiId = poi.poiId;
    addressViewCon.poiName = poi.name;
    addressViewCon.poiLocation = poi.locationArray;
    [self pushToViewController:addressViewCon animated:YES hideBottomBar:YES];
}

@end
