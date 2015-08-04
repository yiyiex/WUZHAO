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
#import "UIViewController+Basic.h"

#import "UILabel+ChangeAppearance.h"

#import "macro.h"

#import "PrivateLetter.h"
#import "QDYHTTPClient.h"
#import "SVProgressHUD.h"

@interface PrivateLetterViewController ()<PagerViewControllerItem>
@property (nonatomic, strong) UIView *infoView;

@end

@implementation PrivateLetterViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupRefreshControl];
    [self setBackItem];
    self.shouldRefreshData = YES;
    [self getLatestData];
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
            self.datasource = [returnData objectForKey:@"data"];
            if (self.datasource.count == 0)
            {
                if (![self.infoView superview])
                {
                    self.infoView = [[UIView alloc]initWithFrame:self.view.frame];
                    UILabel *infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, WZ_APP_SIZE.width-20, 30)];
                    infoLabel.text = @"当前无对话记录";
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
    return self.datasource.count;
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
    [cell configureData:self.datasource[indexPath.row]];
    
    //configure gesture
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarClick:)];
    [cell.userAvatorView addGestureRecognizer:avatarTap];
    [cell.userAvatorView setUserInteractionEnabled:YES];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Conversation *conversation = self.datasource[indexPath.row];
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
        Conversation *conversation = [self.datasource objectAtIndex:indexPath.row];
        [self deleteMessage:conversation];
        [tableView beginUpdates];
        [self.datasource removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [tableView endUpdates];
        
    }
}

#pragma mark - gesture and action
-(void)avatarClick:(UIGestureRecognizer *)gesture
{
    PrivateLetterTableViewCell *cell = (PrivateLetterTableViewCell *)gesture.view.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Conversation *conversation = self.datasource[indexPath.row];
    User *user = conversation.other;
    [self goToPersonalPageWithUserInfo:user];
}

#pragma mark - pageViewController Delegate
-(NSString *)titleForPagerViewController:(PagerViewController *)pagerViewController
{
    return @"私信";
}






@end
