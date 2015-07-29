//
//  PrivateLetterViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/7/25.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "PrivateLetterViewController.h"
#import "PrivateLetterTableViewCell.h"
#import "PrivateLetterDetailViewController.h"
#import "MineViewController.h"
#import "UIViewController+HideBottomBar.h"

#import "UILabel+ChangeAppearance.h"

#import "macro.h"

#import "PrivateLetter.h"
#import "QDYHTTPClient.h"
#import "SVProgressHUD.h"

@interface PrivateLetterViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *letterListTableView;

@property (nonatomic, strong) UIView *infoView;

@property (nonatomic, strong) UIRefreshControl *refreshControl;




@end

@implementation PrivateLetterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    self.shouldRefreshData = YES;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)initView
{
    [self.letterListTableView setDirectionalLockEnabled:YES];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refreshByPullingTable:) forControlEvents:UIControlEventValueChanged];
    [self.letterListTableView addSubview:self.refreshControl];
    [self.refreshControl setHidden:YES];
}

-(void)loadData
{
    if (!self.shouldRefreshData)
    {
        return;
    }
    [self.letterListTableView reloadData];
    [self.letterListTableView setContentOffset:CGPointMake(0, 0) animated:YES];
    if ([self.refreshControl isRefreshing])
    {
        [self.refreshControl endRefreshing];
    }
}

-(void)getLatestData
{
    if (!self.shouldRefreshData)
    {
        return;
    }
    self.shouldRefreshData = NO;
    [[QDYHTTPClient sharedInstance]getLetterListWithUserId:[[NSUserDefaults standardUserDefaults] integerForKey:@"userId"] whenComplete:^(NSDictionary *returnData) {
        if ([self.refreshControl isRefreshing])
        {
            [self.refreshControl endRefreshing];
        }
        self.shouldRefreshData = YES;
        if ([returnData objectForKey:@"data"])
        {
            self.letterListData = [returnData objectForKey:@"data"];
            if (self.letterListData.count == 0)
            {
                if (![self.infoView superview])
                {
                    self.infoView = [[UIView alloc]initWithFrame:self.view.frame];
                    UILabel *infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, WZ_APP_SIZE.width-20, 30)];
                    infoLabel.text = @"当前无对话记录";
                    infoLabel.textAlignment = NSTextAlignmentCenter;
                    [infoLabel setReadOnlyLabelAppearance];
                    [self.infoView addSubview:infoLabel];
                    [self.letterListTableView addSubview:self.infoView];
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
-(void)deleteMessage:(Conversation *)conversation
{
    NSInteger myId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    [[QDYHTTPClient sharedInstance]deleteMessageWithMyUserId:myId toUserId:conversation.other.UserID whenComplete:^(NSDictionary *returnData) {
        [[QDYHTTPClient sharedInstance]getLatestNoticeNumber];
        if ([returnData objectForKey:@"data"])
        {
            //[self.letterListTableView reloadData];
            NSLog(@"删除成功");
        }
        else
        {
            [self loadData];
            NSLog(@"删除失败");
        }
    }];
}

#pragma mark - tableview delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.letterListData.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PrivateLetterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"privateLetterCell" forIndexPath:indexPath];
    if (!cell)
    {
        cell = [[PrivateLetterTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"privateLetterCell"];
    }
    [cell configureData:self.letterListData[indexPath.row]];
    
    //configure gesture
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarClick:)];
    [cell.userAvatorView addGestureRecognizer:avatarTap];
    [cell.userAvatorView setUserInteractionEnabled:YES];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Conversation *conversation = self.letterListData[indexPath.row];
    conversation.newMessageCount = 0;
    conversation.me.UserID = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    PrivateLetterTableViewCell *cell = (PrivateLetterTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell.badge setHidden:YES];
    UIStoryboard *feedStoryboard = [UIStoryboard storyboardWithName:@"Feeds" bundle:nil];
    PrivateLetterDetailViewController *conversationPage = [feedStoryboard instantiateViewControllerWithIdentifier:@"conversationView"];
    conversationPage.conversation = conversation;
    
    [self pushToViewController:conversationPage animated:YES hideBottomBar:YES];
   
    //go to conversation detail page
    
}


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return YES;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Conversation *conversation = [self.letterListData objectAtIndex:indexPath.row];
        [self deleteMessage:conversation];
        [tableView beginUpdates];
        [self.letterListData removeObjectAtIndex:indexPath.row];
        [self.letterListTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [tableView endUpdates];
        
    }
}

#pragma mark - gesture and action
-(void)avatarClick:(UIGestureRecognizer *)gesture
{
    PrivateLetterTableViewCell *cell = (PrivateLetterTableViewCell *)gesture.view.superview.superview;
    NSIndexPath *indexPath = [self.letterListTableView indexPathForCell:cell];
    Conversation *conversation = self.letterListData[indexPath.row];
    User *user = conversation.other;
    [self gotoPersonalPageWithUserInfo:user];
}

-(void)gotoPersonalPageWithUserInfo:(User *)user
{
    UIStoryboard *personalStoryboard= [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
    MineViewController *personalViewCon = [personalStoryboard instantiateViewControllerWithIdentifier:@"personalPage"];
    [personalViewCon setUserInfo:user];
    [self pushToViewController:personalViewCon animated:YES hideBottomBar:YES];
}

-(void)refreshByPullingTable:(id)sender
{
    if (self.shouldRefreshData)
    {
        [self getLatestData];
    }
    else
    {
        if ([self.refreshControl isRefreshing])
        {
            [self.refreshControl endRefreshing];
        }
    }
}




@end
