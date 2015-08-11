//
//  BasicCollectionViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/8/4.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "BasicCollectionViewController.h"
#import "macro.h"

@interface BasicCollectionViewController ()
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation BasicCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
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
    [self.collectionView addSubview:self.refreshControl];
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
    [self endRefreshing];
}

-(void)endRefreshing
{
    if (self.refreshControl.isRefreshing)
    {
        double delayInseconds = 0.2;
        dispatch_time_t popTime =  dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInseconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
        });
    }
}

-(void)getLatestData
{
    //set the latest data and reload data
    [self loadData];
}

//load more
-(void)setupLoadMore
{
    if (!_loadMoreButton && self.shouldLoadMore)
    {
        NSString *footButonTitle = @"加载更多" ;
        UIView *collectionFooterView = [[UIView alloc]init];
        UIEdgeInsets edgeInsets = self.collectionView.contentInset;
        edgeInsets.bottom += 44;
        self.collectionView.contentInset = edgeInsets;
        collectionFooterView.frame = CGRectMake(0, self.collectionView.bounds.size.height - 44, self.collectionView.bounds.size.width, 44);
        [self.collectionView addSubview:collectionFooterView];
        
        _loadMoreButton = [[UIButton alloc]init];
        _loadMoreButton.frame = CGRectMake(0, 0,self.collectionView.bounds.size.width, 44);
        [_loadMoreButton setTitle:footButonTitle forState:UIControlStateNormal];
        [_loadMoreButton.titleLabel setFont:WZ_FONT_SMALL_READONLY];
        [_loadMoreButton setTitleColor:THEME_COLOR_LIGHT_GREY forState:UIControlStateNormal];
        [_loadMoreButton addTarget:self action:@selector(loadMore) forControlEvents:UIControlEventTouchUpInside];
        [collectionFooterView addSubview:_loadMoreButton];
        
        _loadMoreAiv = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _loadMoreAiv.center = _loadMoreButton.center;
        [collectionFooterView addSubview:_loadMoreAiv];
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
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointMake(0, 0)];
    if (self.collectionView.contentSize.height <self.collectionView.frame.size.height)
    {
        [self.collectionView setContentSize:CGSizeMake(self.collectionView.contentSize.width, self.collectionView.frame.size.height +10)];
    }
    [self endRefreshing];
}

-(void)getLatestDataAnimated
{
    [self.collectionView setContentOffset:CGPointMake(0, -80) animated:YES];
    [self.refreshControl beginRefreshing];
    [self getLatestData];
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
        CGPoint loadMorePoint = CGPointMake(0, self.collectionView.contentSize.height);
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

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 0;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    UICollectionViewCell *cell = [[UICollectionViewCell alloc]init];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

#pragma mark - transition
-(void)pushToViewController:(UIViewController *)viewController animated:(BOOL)animated hideBottomBar:(BOOL)hidden
{
    if (hidden)
    {
        //[[NSNotificationCenter defaultCenter ]postNotificationName:@"hideTabBar" object:nil];
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [self.navigationController pushViewController:viewController animated:animated];
}




@end
