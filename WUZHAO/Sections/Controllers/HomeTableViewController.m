//
//  HomeTableViewController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-15.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "HomeTableViewController.h"

#import "PhotoDetailViewController.h"
#import "MineViewController.h"
#import "AddressViewController.h"
#import "PhotoDetailViewController.h"
#import "CommentListViewController.h"
#import "UserListTableViewController.h"

#import "WPAttributedStyleAction.h"
#import "NSString+WPAttributedMarkup.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+ChangeAppearance.h"
#import "UILabel+ChangeAppearance.h"


#import "CBStoreHouseRefreshControl.h"

#import "SVProgressHUD.h"

#import "QDYHTTPClient.h"
#import "macro.h"

#define ONEPAGEITEMS 10
@interface HomeTableViewController ()
@property (nonatomic ,strong) NSMutableArray *dataSource;
@property (nonatomic ,strong) User *currentUser;

@property (atomic)  BOOL shouldRefreshData;
@property (nonatomic,strong) UIRefreshControl *refreshControl;
//current page
@property (nonatomic,assign) NSInteger currentPage;

@property (nonatomic) float tableViewOffset;
@end

@implementation HomeTableViewController
@synthesize currentPage = _currentPage;
static NSString *reuseIdentifier = @"HomeTableCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 700.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.alwaysBounceVertical = YES;

    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refreshByPullingTable:) forControlEvents:UIControlEventValueChanged];
    
    self.shouldRefreshData = true;
    self.tableViewOffset = 0.0;
    [self loadData];
}



-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"offset to show :%f",self.tableViewOffset);
    NSLog(@"offset accturaly :%f",self.tableView.contentOffset.y);
    [super viewWillAppear:animated];
    self.tabBarController.navigationController.navigationBarHidden = NO;
    self.tabBarController.navigationItem.title = @"Place";
    self.tabBarController.navigationItem.hidesBackButton = YES;
    [self.tableView setContentOffset:CGPointMake(0,self.tableViewOffset) animated:YES];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"offset set %f",self.tableViewOffset);
    NSLog(@"tableViewContent Offset:%f",self.tableView.contentOffset.y);
   // self.tableViewOffset = self.tableView.contentOffset.y;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSMutableArray *)dataSource
{
    if (!_dataSource)
    {
        _dataSource = [[NSMutableArray alloc]init];
    }
    return _dataSource;
}

-(User *)currentUser
{
    if (!_currentUser)
    {
        _currentUser = [[User alloc]init];
        _currentUser.UserID = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    }
    return _currentUser;
}

-(void)loadData
{
    
    //self.currentUser.UserID = [[NSUserDefaults standardUserDefaults] integerForKey:@"userId"];
    //获取最新data
    if (self.shouldRefreshData)
    {
        [self GetLatestDataList];
        //to do  got the page count
    }
}

-(void)loadMore
{
    //TO DO
    //get the new page data
    
    NSMutableArray *nextPageData = [[NSMutableArray alloc]init];
    [self.dataSource addObjectsFromArray:nextPageData];
    self.currentPage ++;
    
}

- (void)configureCell:(PhotoTableViewCell *)cell forContent:(WhatsGoingOn *)content atIndexPath:(NSIndexPath *)indexPath
{
    //评论内容显示样式
    
    NSDictionary *nameStyle = @{@"userName":[WPAttributedStyleAction styledActionWithAction:^{
        
        //get personal info  and config the personal view
        //...userName 和 userId关联
        UIStoryboard *personalStoryboard= [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
        MineViewController *personalViewCon = [personalStoryboard instantiateViewControllerWithIdentifier:@"personalPage"];
        [personalViewCon setUserInfo:content.photoUser];
        [self.navigationController pushViewController:personalViewCon animated:YES];
    }],
                                @"address":[WPAttributedStyleAction styledActionWithAction:^{
                                    UIStoryboard *personalStoryboard= [UIStoryboard storyboardWithName:@"Address" bundle:nil];
                                    AddressViewController *addressViewCon = [personalStoryboard instantiateViewControllerWithIdentifier:@"addressPage"];
                                    //get the addressView info and config it
                                    //....
                                    
                                    [self.navigationController pushViewController:addressViewCon animated:YES];
                                }],
                                @"seeMore":[WPAttributedStyleAction styledActionWithAction:^{
                                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"photoDetailAndComment" bundle:nil];
                                    CommentListViewController *commentListView = [storyboard instantiateViewControllerWithIdentifier:@"commentListView"];
                                    [commentListView setCommentList:content.commentList];
                                    [self.navigationController pushViewController:commentListView animated:YES];
                                }],
                                @"link": THEME_COLOR_DARK};
    content.attributedComment = [content.comment attributedStringWithStyleBook:nameStyle];
    
    
    //配置图片相关基本信息
    cell.postTimeLabel.text = content.postTime;
    
    cell.postUserName.text = content.photoUser.UserName;
    

    cell.postUserSelfDescription.text = [content.photoUser.selfDescriptions stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    
    [cell.homeCellAvatorImageView sd_setImageWithURL:[NSURL URLWithString:content.photoUser.avatarImageURLString] placeholderImage:[UIImage imageNamed:@"default"]];
    
    if (content.likeCount >0)
    {
        cell.likeLabel.text = [NSString stringWithFormat:@"%lu 次赞", (long)content.likeCount];
    }
    else
    {
        cell.likeLabel.text = @"";
    }
    cell.addressLabel.text = content.poiName;

    cell.descriptionLabel.text = content.imageDescription;
    
    if (content.attributedComment)
    {
        cell.commentLabel.attributedText = content.attributedComment;
        
    }
    else
    {
        cell.commentLabel.attributedText = [cell.commentLabel filterLinkWithContent:content.comment];
    }
    
    [cell.homeCellImageView sd_setImageWithURL:[NSURL URLWithString:content.imageUrlString]
                              placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cell.homeCellImageView.backgroundColor = [UIColor blackColor];
    
    if (content.isLike)
    {
        [cell.zanClickButton setTitle:@"已赞" forState:UIControlStateNormal];
    }
    else
    {
        [cell.zanClickButton setTitle:@"赞" forState:UIControlStateNormal];
    }
    //配置评论内容以及样式、响应

    
    //配置cell被点击效果
    
    UITapGestureRecognizer *avatarClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarClick:)];
    [cell.homeCellAvatorImageView addGestureRecognizer:avatarClick];
    //点击 “赞的数量” 跳转赞的用户列表
    UITapGestureRecognizer *likeLabelClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(likeLabelClick:)];
    [cell.likeLabel addGestureRecognizer:likeLabelClick];
    //点击 ”赞“，添加”赞“数量
    [cell.zanClickButton addTarget:self action:@selector(zanButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    //点击评论，跳转评论页面
    [cell.commentClickButton addTarget:self action:@selector(commentButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.moreButton addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    //点击地址，跳转地址页面
    UITapGestureRecognizer *addressClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addressLabelClick:)];
    
    [cell.addressLabel addGestureRecognizer:addressClick];
    
    [cell setAppearance];
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.dataSource count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotoTableViewCell *cell;
    WhatsGoingOn *item = self.dataSource[indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[PhotoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }

    //各控件单击效果
    //点击头像，跳转个人主页
    [self configureCell:cell forContent:item atIndexPath:indexPath];
    [cell setAppearance];
    return cell;
}


#pragma mark - gesture action
- (void)avatarClick:(UITapGestureRecognizer *)gesture
{
    //我们获取gesture关联的view,并将view的类名打印出来
    //NSString *className = NSStringFromClass([gesture.view class]);
    self.tableViewOffset = self.tableView.contentOffset.y;
    PhotoTableViewCell * cell = (PhotoTableViewCell *)[[[gesture.view superview]superview]superview];
    NSIndexPath *selectItemIndexPath = [self.tableView indexPathForCell:cell];


    WhatsGoingOn *item = [self.dataSource objectAtIndex:selectItemIndexPath.row];
    
    UIStoryboard *personalStoryboard= [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
    MineViewController *personalViewCon = [personalStoryboard instantiateViewControllerWithIdentifier:@"personalPage"];

    [personalViewCon setUserInfo:item.photoUser];
    [personalViewCon.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:personalViewCon animated:YES];
}


-(void)moreButtonClick:(UIButton *)sender
{
    //NSInteger userId = [[NSUserDefaults standardUserDefaults] integerForKey:@"userId"];
    PhotoTableViewCell *cell = (PhotoTableViewCell *)[[sender superview]superview];
    NSIndexPath *selectItemIndexPath = [self.tableView indexPathForCell:cell];
    WhatsGoingOn *item = [self.dataSource objectAtIndex:selectItemIndexPath.row];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alertController addAction:cancelAction];
    
    if (self.currentUser.UserID == item.photoUser.UserID)
    {
        UIAlertAction *delectAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            //TO DO
            //删除该条记录
            [self.dataSource removeObjectAtIndex:selectItemIndexPath.row];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject: selectItemIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }];
        [alertController addAction:delectAction];
    }
    else
    {
        UIAlertAction *delectAction = [UIAlertAction actionWithTitle:@"举报不良内容" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        }];
        [alertController addAction:delectAction];
    }
    /*
    UIAlertAction *shareAction = [UIAlertAction actionWithTitle:@"复制共享网址" style:nil handler:^(UIAlertAction *action) {
        NSLog(@"share pressed");
    }];
    [alertController addAction:shareAction];
     */
    [self presentViewController:alertController animated:YES completion:^{
        
        
    }];
    

}
-(void)zanButtonClick:(id)sender
{
    PhotoTableViewCell *cell = (PhotoTableViewCell *)[[sender superview]superview];
    NSIndexPath *selectItemIndexPath = [self.tableView indexPathForCell:cell];
    
    WhatsGoingOn *item = [self.dataSource objectAtIndex:selectItemIndexPath.row];
    if (!item.isLike)
    {
        [[QDYHTTPClient sharedInstance]ZanPhotoWithUserId:self.currentUser.UserID postId:item.postId whenComplete:^(NSDictionary *returnData) {
            if ([returnData objectForKey:@"data"])
            {
                if ([cell.zanClickButton.currentTitle isEqualToString:@"赞"])
                {
                    item.likeCount += 1;
                    [cell.likeIcon setHidden:NO];
                    cell.likeLabel.text = [NSString stringWithFormat:@"%lu 次赞",(long)item.likeCount];
                    [cell.zanClickButton setTitle:@"已赞" forState:UIControlStateNormal];
                    [cell setAppearance];
                    [cell layoutIfNeeded];
                }
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
            }
        }];
        
    }
    else
    {
        [[QDYHTTPClient sharedInstance]CancelZanPhotoWithUserId:self.currentUser.UserID postId:item.postId whenComplete:^(NSDictionary *returnData) {
            if ([returnData objectForKey:@"data"])
            {
                if ([cell.zanClickButton.currentTitle isEqualToString:@"已赞"])
                {
                    item.likeCount -= 1;
                    if (item.likeCount == 0)
                    {
                        [cell.likeIcon setHidden:YES];
                        cell.likeLabel.text = @"";
                    }
                    else
                    {
                        [cell.likeIcon setHidden:NO];
                        cell.likeLabel.text = [NSString stringWithFormat:@"%lu 次赞",(long)item.likeCount];
                    }
                    [cell.zanClickButton setTitle:@"赞" forState:UIControlStateNormal];
                    [cell setAppearance];
                    [cell layoutIfNeeded];
                }
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
            }
        }];
    }

}

-(void)commentButtonClick:(id)sender
{
    self.tableViewOffset = self.tableView.contentOffset.y;
    PhotoTableViewCell *cell = (PhotoTableViewCell *)[[sender superview]superview];
    NSIndexPath *selectItemIndexPath = [self.tableView indexPathForCell:cell];
    WhatsGoingOn *item = [self.dataSource objectAtIndex:selectItemIndexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"photoDetailAndComment" bundle:nil];
    CommentListViewController *detailAndCommentView = [storyboard instantiateViewControllerWithIdentifier:@"commentListView"];
    detailAndCommentView.poiItem = item;
    [self.navigationController pushViewController:detailAndCommentView animated:YES];
}

-(void)likeLabelClick:(UITapGestureRecognizer *)gesture
{
    PhotoTableViewCell *cell = (PhotoTableViewCell *)[[[gesture.view superview]superview]superview];
    NSIndexPath *selectIndexPath = [self.tableView indexPathForCell:cell];
    WhatsGoingOn *item = [self.dataSource objectAtIndex:selectIndexPath.row];
    [[QDYHTTPClient sharedInstance]GetPhotoZanUserListWithPostId:item.postId whenComplete:^(NSDictionary *returnData) {
        if ([returnData objectForKey:@"data"])
        {
            
            UIStoryboard *userListStoryBoard = [UIStoryboard storyboardWithName:@"UserList" bundle:nil];
            UserListTableViewController *followsList = [userListStoryBoard instantiateViewControllerWithIdentifier:@"userListTableView"];
            [followsList setUserListStyle:UserListStyle1];
            [followsList setDatasource:[returnData objectForKey:@"data"]];
            [followsList setTitle:@"点赞的用户"];
            [self.navigationController showViewController:followsList sender:self];
            
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
        }
    }];
}

-(void)addressLabelClick:(UITapGestureRecognizer *)gesture
{
    UIStoryboard *addressStoryboard = [UIStoryboard storyboardWithName:@"Address" bundle:nil];
    AddressViewController *addressViewCon = [addressStoryboard instantiateViewControllerWithIdentifier:@"addressPage"];
    //[self hidesBottomBarWhenPushed];
    
    [self.navigationController pushViewController:addressViewCon animated:YES];
}

#pragma mark - Notifying refresh control of scrolling

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //NSLog(@"scroll view did end dragging");

}

#pragma mark- Listen for the user to trigger a refresh

-(void)refreshByPullingTable:(id)sender
{
    
    if (self.shouldRefreshData)
    {
        [self.refreshControl beginRefreshing];
        [self GetLatestDataList];
    }
    /*
    double delayInseconds = 2.0;
    dispatch_time_t popTime =  dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInseconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
    });
     */
}



#pragma mark - control the model

-(void)GetLatestDataList
{
    if(self.shouldRefreshData)
    {
        
        [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        self.tableViewOffset = 0.0;
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
        self.shouldRefreshData = false;
        [[QDYHTTPClient sharedInstance]GetWhatsGoingOnWithUserId:self.currentUser.UserID whenComplete:^(NSDictionary *result) {
            
            if ([result objectForKey:@"data"])
            {
                
                self.dataSource = [result objectForKey:@"data"];
                [self.tableView reloadData];
                self.currentPage = 1;
                
                if (self.refreshControl.isRefreshing)
                {
                    double delayInseconds = 0.2;
                    dispatch_time_t popTime =  dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInseconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^{
                    [self.refreshControl endRefreshing];
                    });
                }
                
                
                
            }
            else if ([result objectForKey:@"error"])
            {
                [SVProgressHUD showErrorWithStatus:[result objectForKey:@"error"]];
            }
            
            self.shouldRefreshData = true;
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
            
        }];
    }
}

-(void)GetNewPageData
{
    
}


#pragma mark - http request

-(void)CommentPhotoWithItem:(WhatsGoingOn *)item
{
    /*
    [[AFHTTPAPIClient sharedInstance]CommentPhotoWithUserId:self.currentUser.UserID postId:item.postId complete:^(NSDictionary *result, NSError *error) {
        if (result)
        {
            //self.dataSource = [result mutableCopy];
        }
        else if (error)
        {
            [SVProgressHUD showErrorWithStatus:@"请求失败,请检查连接"];
            
        }
    }];*/
    
}


-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
