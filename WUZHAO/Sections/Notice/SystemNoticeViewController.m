//
//  NoticeViewController.m
//  WUZHAO
//
//  Created by yiyi on 15-1-14.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "SystemNoticeViewController.h"
#import "FeedsFollowTableViewCell.h"
#import "FeedsZanAndCommentTableViewCell.h"
#import "HomeTableViewController.h"
#import "MineViewController.h"
#import "SVProgressHUD.h"

#import "NoticeContentTextView.h"

#import "PagerViewController.h"

#import "UIViewController+Basic.h"
#import "UILabel+ChangeAppearance.h"
#import "UIImageView+WebCache.h"
#import "Feeds.h"

#import "QDYHTTPClient.h"
#import "macro.h"


@interface SystemNoticeViewController ()<NoticeContentTextViewDelegate,PagerViewControllerItem>


@property (nonatomic,strong) UIView *infoView;

@property (nonatomic, strong) FeedsZanAndCommentTableViewCell *zanAndCommentPrototypeCell;
@property (nonatomic, strong) FeedsFollowTableViewCell *followPrototypeCell;



@end

@implementation SystemNoticeViewController
@dynamic refreshControl;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clearUserInfo) name:@"deleteUserInfo" object:nil];
    self.shouldRefreshData = YES;
    [self getLatestDataAnimated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initNavigationItem];
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
-(void)setupView
{
    [self setBackItem];
    [self setupRefreshControl];
    [self initNavigationItem];
}
-(void)initNavigationItem
{
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
}


-(FeedsZanAndCommentTableViewCell *)zanAndCommentPrototypeCell
{
    if (!_zanAndCommentPrototypeCell) {
        _zanAndCommentPrototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"zanAndCommentCell"];
        if (!_zanAndCommentPrototypeCell)
        {
            _zanAndCommentPrototypeCell = [[FeedsZanAndCommentTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"zanAndCommentCell"];
        }
    }
    return _zanAndCommentPrototypeCell;
}

-(FeedsFollowTableViewCell *)followPrototypeCell
{
    if (!_followPrototypeCell) {
        _followPrototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"followCell"];
    }
    return _followPrototypeCell;
}


#pragma mark - tableview delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Feeds *feeds = [self.datasource objectAtIndex:indexPath.row];
    UITableViewCell *cell;
    if (feeds.type == WZ_FEEDSTYPE_ZAN)
    {
        cell = (FeedsZanAndCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"zanAndCommentCell" forIndexPath:indexPath];
        if (!cell)
        {
            cell = [[FeedsZanAndCommentTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"zanAndCommentCell"];
        }
        [self configureZanCell:(FeedsZanAndCommentTableViewCell *)cell WithFeeds:feeds];
        
        
    }
    else if (feeds.type == WZ_FEEDSTYPE_COMMENT)
    {
        cell = (FeedsZanAndCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"zanAndCommentCell" forIndexPath:indexPath];
        if (!cell)
        {
            cell = [[FeedsZanAndCommentTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"zanAndCommentCell"];
        }
        [self configureCommentCell:(FeedsZanAndCommentTableViewCell *)cell WithFeeds:feeds];
    }
    else if (feeds.type == WZ_FEEDSTYPE_REPLYCOMMENT)
    {
        cell = (FeedsZanAndCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"zanAndCommentCell" forIndexPath:indexPath];
        if (!cell)
        {
            cell = [[FeedsZanAndCommentTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"zanAndCommentCell"];
        }
        [self configureReplyCommentCell:(FeedsZanAndCommentTableViewCell *)cell WithFeeds:feeds];
    }
    else if (feeds.type == WZ_FEEDSTYPE_FOLLOW)
    {
        cell = (FeedsFollowTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"followCell" forIndexPath:indexPath];
        if (!cell)
        {
            cell = [[FeedsFollowTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"followCell"];
        }
        [self configureFollowCell:(FeedsFollowTableViewCell *)cell WithFeeds:feeds];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(float)caculateProtoCellHeightWithData:(Feeds *)feeds
{
    float height = 60;
    if (feeds.type == WZ_FEEDSTYPE_ZAN)
    {
        height =  64;
    }
    else if (feeds.type == WZ_FEEDSTYPE_COMMENT)
    {
        FeedsZanAndCommentTableViewCell * cell = self.zanAndCommentPrototypeCell;
 
        [self configureCommentCell:cell WithFeeds:feeds];
        height = cell.contentTextView.frame.size.height >60?cell.contentTextView.frame.size.height:64;
        
    }
    else if (feeds.type == WZ_FEEDSTYPE_REPLYCOMMENT)
    {
        FeedsZanAndCommentTableViewCell * cell = self.zanAndCommentPrototypeCell;
        [self configureReplyCommentCell:cell WithFeeds:feeds];
         height = cell.contentTextView.frame.size.height >60?cell.contentTextView.frame.size.height:64;
    }
    else if (feeds.type == WZ_FEEDSTYPE_FOLLOW)
    {
        height = 64;
    }
    return height;
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return[ self caculateProtoCellHeightWithData:self.datasource[indexPath.row]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self caculateProtoCellHeightWithData:self.datasource[indexPath.row]];
}

-(void)configureZanCell:(FeedsZanAndCommentTableViewCell *)cell WithFeeds:(Feeds *)feeds
{
    [cell configureZanWithFeeds:feeds parentController:self];
}
-(void)configureCommentCell:(FeedsZanAndCommentTableViewCell *)cell WithFeeds:(Feeds *)feeds
{
    [cell configureCommentWithFeeds:feeds parentController:self];
}
-(void)configureReplyCommentCell:(FeedsZanAndCommentTableViewCell *)cell WithFeeds:(Feeds *)feeds
{
    [cell configureReplyCommentWithFeeds:feeds parentController:self];
}
-(void)configureFollowCell:(FeedsFollowTableViewCell *)cell WithFeeds:(Feeds *)feeds
{
    [cell configureFollowWithFeeds:feeds parentController:self];
}

-(void)getLatestData
{
    if (!self.shouldRefreshData)
    {
        return;
    }
    self.shouldRefreshData = NO;
    NSInteger userId = [[NSUserDefaults standardUserDefaults] integerForKey:@"userId"];
    //获取最新数据
    [[QDYHTTPClient sharedInstance]getNoticeWithUserId:userId whenComplete:^(NSDictionary *returnData) {
        
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
    //self.dataSource = [[Feeds getLatestFeeds]mutableCopy];;
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
-(void)feedsUserClick:(UIGestureRecognizer *)gesture
{
    UITableViewCell *cell = (UITableViewCell *)[[gesture.view superview]superview];
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:cell];
    Feeds *feeds = [self.datasource objectAtIndex:selectedIndexPath.row];
    [self goToPersonalPageWithUserInfo:feeds.feedsUser];
    
}



#pragma mark - noticeTextViewDelegate
-(void)noticeContentTextView:(NoticeContentTextView *)noticeContentTextView didClickLinkUser:(User *)user
{
    [self goToPersonalPageWithUserInfo:user];
}

#pragma mark - notification selector
-(void)clearUserInfo
{
    self.datasource = nil;
    [self loadData];
}

#pragma mark - pagerViewController Delegate
-(NSString *)titleForPagerViewController:(PagerViewController *)pagerViewController
{
    return @"通知";
}

@end
