//
//  NoticeViewController.m
//  WUZHAO
//
//  Created by yiyi on 15-1-14.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "NoticeViewController.h"
#import "FeedsFollowTableViewCell.h"
#import "FeedsZanAndCommentTableViewCell.h"
#import "HomeTableViewController.h"
#import "MineViewController.h"
#import "SVProgressHUD.h"

#import "NoticeContentTextView.h"

#import "UILabel+ChangeAppearance.h"
#import "UIImageView+WebCache.h"
#import "Feeds.h"

#import "QDYHTTPClient.h"
#import "macro.h"


@interface NoticeViewController ()<NoticeContentTextViewDelegate>

@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) UIView *infoView;

@end

@implementation NoticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavigationItem];
    
    [self getLatestData];
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
-(void)initNavigationItem
{
    self.navigationItem.title = @"通 知";
    self.tabBarController.navigationController.navigationBarHidden = NO;
    self.tabBarController.navigationItem.title = @"通知";
    self.tabBarController.navigationItem.hidesBackButton = YES;
}

#pragma mark - tableview delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Feeds *feeds = [self.dataSource objectAtIndex:indexPath.row];
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
    return self.dataSource.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(float)caculateProtoCellHeightWithData:(Feeds *)feeds
{
    float height;
    if (feeds.type == WZ_FEEDSTYPE_ZAN)
    {
        height =  64;
    }
    else if (feeds.type == WZ_FEEDSTYPE_COMMENT)
    {
       FeedsZanAndCommentTableViewCell * cell = (FeedsZanAndCommentTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"zanAndCommentCell" ];
        if (!cell)
        {
            cell = [[FeedsZanAndCommentTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"zanAndCommentCell"];
        }
        [self configureCommentCell:(FeedsZanAndCommentTableViewCell *)cell WithFeeds:feeds];
        height = cell.contentTextView.frame.size.height >60?cell.contentTextView.frame.size.height:64;
        
    }
    else if (feeds.type == WZ_FEEDSTYPE_REPLYCOMMENT)
    {
        FeedsZanAndCommentTableViewCell * cell = (FeedsZanAndCommentTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"zanAndCommentCell" ];
        if (!cell)
        {
            cell = [[FeedsZanAndCommentTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"zanAndCommentCell"];
        }
        [self configureReplyCommentCell:(FeedsZanAndCommentTableViewCell *)cell WithFeeds:feeds];
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
    return[ self caculateProtoCellHeightWithData:self.dataSource[indexPath.row]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self caculateProtoCellHeightWithData:self.dataSource[indexPath.row]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
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
    NSInteger userId = [[NSUserDefaults standardUserDefaults] integerForKey:@"userId"];
    //获取最新数据
    [[QDYHTTPClient sharedInstance]getNoticeWithUserId:userId whenComplete:^(NSDictionary *returnData) {
        if ([returnData objectForKey:@"data"])
        {
            self.dataSource = [returnData objectForKey:@"data"];
            if (self.dataSource.count == 0)
            {
                if (![self.infoView superview])
                {
                    self.infoView = [[UIView alloc]initWithFrame:self.view.frame];
                    UILabel *infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, WZ_APP_SIZE.width-20, 30)];
                    infoLabel.text = @"暂时没有通知";
                    infoLabel.textAlignment = NSTextAlignmentCenter;
                    [infoLabel setReadOnlyLabelAppearance];
                    [self.infoView addSubview:infoLabel];                    
                    [self.view addSubview:self.infoView];
                }
            }
            else
            {
                if (self.infoView)
                {
                    [self.infoView removeFromSuperview];
                }
                [self.tableView reloadData];
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
    Feeds *feeds = [self.dataSource objectAtIndex:selectedIndexPath.row];

    UIStoryboard *whatsNew = [UIStoryboard storyboardWithName:@"WhatsNew" bundle:nil];
    HomeTableViewController *detailPhotoController  = [whatsNew instantiateViewControllerWithIdentifier:@"HomeTableViewController"];
    [detailPhotoController setDataSource:[NSMutableArray arrayWithObject:feeds.feedsPhoto]];
    [detailPhotoController setTableStyle:WZ_TABLEVIEWSTYLEDETAIL];
    [detailPhotoController GetLatestDataList];
    [self.navigationController pushViewController:detailPhotoController animated:YES];
    
}
-(void)avatarClick:(UIGestureRecognizer *)gesture
{
    UITableViewCell *cell = (UITableViewCell *)[[gesture.view superview]superview];
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:cell];
    Feeds *feeds = [self.dataSource objectAtIndex:selectedIndexPath.row];
    
    [self goToUserPageWithUserInfo:feeds.feedsUser];
    
}
-(void)feedsUserClick:(UIGestureRecognizer *)gesture
{
    UITableViewCell *cell = (UITableViewCell *)[[gesture.view superview]superview];
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:cell];
    Feeds *feeds = [self.dataSource objectAtIndex:selectedIndexPath.row];
    [self goToUserPageWithUserInfo:feeds.feedsUser];
    
}
-(void)goToUserPageWithUserInfo:(User *)user
{
    UIStoryboard *personalStoryboard= [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
    MineViewController *personalViewCon = [personalStoryboard instantiateViewControllerWithIdentifier:@"personalPage"];
    [personalViewCon setUserInfo:user];
    [personalViewCon.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:personalViewCon animated:YES];
}
/*
-(void)followButtonClick:(UIGestureRecognizer *)gesture
{
    
}*/


#pragma mark - noticeTextViewDelegate
-(void)noticeContentTextView:(NoticeContentTextView *)noticeContentTextView didClickLinkUser:(User *)user
{
    [self goToUserPageWithUserInfo:user];
}
@end
