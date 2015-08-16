//
//  PlaceNoticeTableViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/8/4.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "PlaceNoticeTableViewController.h"
#import "PlaceRecommendTableViewCell.h"
#import "QDYHTTPClient.h"
#import "Feeds.h"
#import "macro.h"
#import "UILabel+ChangeAppearance.h"
#import "HomeTableViewController.h"
#import "SVProgressHUD.h"
#import "PlaceRecommendTextView.h"

@interface PlaceNoticeTableViewController ()<PlaceRecommendTextViewDelegate>
@property (nonatomic,strong) UIView *infoView;

@end

@implementation PlaceNoticeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupRefreshControl];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clearUserInfo) name:@"deleteUserInfo" object:nil];
    
    [self getLatestDataAnimated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)getLatestData
{
    //getlatest data
    if (!self.shouldRefreshData)
    {
        return;
    }
    self.shouldRefreshData = NO;
    NSInteger userId = [[NSUserDefaults standardUserDefaults] integerForKey:@"userId"];
    //获取最新数据
    [[QDYHTTPClient sharedInstance]getSystemNoticeWithUserId:userId whenComplete:^(NSDictionary *returnData) {
        
        [self endRefreshing];
        self.shouldRefreshData = YES;
        [[QDYHTTPClient sharedInstance]getLatestNoticeNumber];
        if ([returnData objectForKey:@"data"])
        {
            self.datasource = [returnData objectForKey:@"data"];
            if (self.datasource.count == 0)
            {
                if (![self.infoView superview])
                {
                    self.infoView = [[UIView alloc]initWithFrame:self.view.frame];
                    UILabel *infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, WZ_APP_SIZE.width-20, 30)];
                    infoLabel.text = @"暂时没有通知";
                    infoLabel.textAlignment = NSTextAlignmentCenter;
                    [infoLabel setReadOnlyLabelAppearance];
                    [self.infoView addSubview:infoLabel];
                    [self.tableView addSubview:self.infoView];
                }
            }
            else
            {
                if (self.infoView)
                {
                    [self.infoView removeFromSuperview];
                }
                [self loadData];
            }
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
        }
        
    }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.datasource.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.datasource.count >0)
    {
        return 68;
    }
    else
    {
        return self.tableView.frame.size.height;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.datasource.count >0)
    {
        PlaceRecommendTableViewCell *cell = (PlaceRecommendTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"placeRecommend" forIndexPath:indexPath];
        [cell configureWithFeeds:self.datasource[indexPath.row] parentController:self];
        return cell;
    }
    else
    {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

#pragma mark- gesture action
-(void)feedsPhotoClick:(UIGestureRecognizer *)gesture
{
    UITableViewCell *cell = (UITableViewCell *)[[gesture.view superview]superview];
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:cell];
    Feeds *feeds = [self.datasource objectAtIndex:selectedIndexPath.row];
    
    UIStoryboard *whatsNew = [UIStoryboard storyboardWithName:@"WhatsNew" bundle:nil];
    HomeTableViewController *detailPhotoController  = [whatsNew instantiateViewControllerWithIdentifier:@"HomeTableViewController"];
    [detailPhotoController setDatasource:[NSMutableArray arrayWithObject:feeds.feedsPhoto]];
    [detailPhotoController setTableStyle:WZ_TABLEVIEWSTYLE_DETAIL];
    [detailPhotoController getLatestData];
    [self pushToViewController:detailPhotoController animated:YES hideBottomBar:YES];
    
}
-(void)avatarClick:(UIGestureRecognizer *)gesture
{
    UITableViewCell *cell = (UITableViewCell *)[[gesture.view superview]superview];
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:cell];
    Feeds *feeds = [self.datasource objectAtIndex:selectedIndexPath.row];
    
    [self goToPersonalPageWithUserInfo:feeds.feedsUser];
    
}


#pragma mark - notification selector
-(void)clearUserInfo
{
    self.datasource = [[NSMutableArray alloc]initWithArray:@[]];
    [self loadData];
}

#pragma mark - placeRecommendTextView delegate
-(void)PlaceRecommendTextView:(PlaceRecommendTextView *)placeRecommendTextView didClickPOI:(POI *)poi
{
    [self goToPOIPhotoListWithPoi:poi];
}

#pragma mark - pagerViewController Item delegate
-(NSString *)titleForPagerViewController:(PagerViewController *)pagerViewController
{
    return @"系统";
}

@end
