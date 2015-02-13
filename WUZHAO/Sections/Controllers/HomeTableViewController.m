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

#import "WPAttributedStyleAction.h"
#import "NSString+WPAttributedMarkup.h"
#import "UIImageView+WebCache.h"

#import "CBStoreHouseRefreshControl.h"

#import "SVProgressHUD.h"

#import "AFHTTPAPIClient.h"
#import "macro.h"

@interface HomeTableViewController ()
@property (nonatomic ,strong) NSMutableArray *dataSource;
@property (nonatomic ,strong) User *currentUser;
@property (nonatomic)  BOOL shouldRefreshData;
@end

@implementation HomeTableViewController
static NSString *reuseIdentifier = @"HomeTableCell";
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 700.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.alwaysBounceVertical = YES;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.shouldRefreshData = true;
    
    
    self.QIUDAOYURefreshControl = [CBStoreHouseRefreshControl attachToScrollView:self.tableView target:self refreshAction:@selector(refreshTriggered:) plist:@"QIUDAOYU" color:[UIColor darkGrayColor] lineWidth:1.5 dropHeight:30 scale:1 horizontalRandomness:150 reverseLoadingAnimation:YES internalAnimationFactor:0.5];
    [self loadData];
   
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.navigationController.navigationBarHidden = NO;
    self.tabBarController.navigationItem.title = @"动态";
    self.tabBarController.navigationItem.hidesBackButton = YES;

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    float verticalContentOffset = self.tableView.contentOffset.y;
    [self.tableView setContentOffset:CGPointMake(0,verticalContentOffset) animated:YES];
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

-(void)loadData
{
    //self.dataSource = [[WhatsGoingOn newDataSource] mutableCopy];
    self.currentUser = [[AFHTTPAPIClient sharedInstance]currentUser];
    //获取最新data
    if (self.shouldRefreshData)
    {
        [self GetLatestDataList];
        
    }
}

- (void)configureCell:(PhotoTableViewCell *)cell forContent:(WhatsGoingOn *)content atIndexPath:(NSIndexPath *)indexPath
{
    //评论内容显示样式
    NSDictionary *nameStyle = @{@"userName":[WPAttributedStyleAction styledActionWithAction:^{
        
        //get personal info  and config the personal view
        //...userName 和 userId关联
        UIStoryboard *personalStoryboard= [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
        MineViewController *personalViewCon = [personalStoryboard instantiateViewControllerWithIdentifier:@"personalPage"];
        User *user = [[User alloc]init];
        user.UserID = 1;
        [personalViewCon setUserInfo:user];
        [self.navigationController pushViewController:personalViewCon animated:YES];
    }],
                                @"address":[WPAttributedStyleAction styledActionWithAction:^{
                                    NSLog(@"Go to the address page");
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
    [cell.homeCellAvatorImageView sd_setImageWithURL:[NSURL URLWithString:content.photoUser.avatarImageURLString] placeholderImage:[UIImage imageNamed:@"default"]];
    cell.postTimeLabel.text = content.postTime;
    cell.likeLabel.text = [NSString stringWithFormat:@"%lu 次赞", (long)content.likeCount];
    if (content.adddresMark)
    {
        cell.addressLabel.text = content.adddresMark;
    }
    else
    {
        [cell.addressLabel removeFromSuperview];
        //[cell.addIcon removeFromSuperview];
    }
    if (content.imageDescription)
    {
        cell.descriptionLabel.text = content.imageDescription;
    }
    else
    {
        [cell.descriptionLabel removeFromSuperview];
        //[cell.descIcon removeFromSuperview];
    }
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
    
    //配置评论内容以及样式、响应

    
    //配置cell被点击效果
    
    UITapGestureRecognizer *avatorClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatorclick:)];
    [cell.homeCellAvatorImageView addGestureRecognizer:avatorClick];
    //点击 ”赞“，添加”赞“数量
    UITapGestureRecognizer *zanViewClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zanViewClick:)];
    [cell.zanView addGestureRecognizer:zanViewClick];
    
    //点击评论，跳转评论页面
    UITapGestureRecognizer *commentViewClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentViewClick:)];
    
    [cell.commentView addGestureRecognizer:commentViewClick];
    
    //点击地址，跳转地址页面
    UITapGestureRecognizer *addressClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addressLabelClick:)];
    
    [cell.addressLabel addGestureRecognizer:addressClick];
    cell.backgroundColor = [UIColor clearColor];
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


- (PhotoTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[PhotoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        
    }
    // Configure the cell....
    WhatsGoingOn *item = self.dataSource[indexPath.row];
    [self configureCell:cell forContent:item atIndexPath:indexPath];
   // [cell setWhatsGoingOnItem:item];
    
    //各控件单击效果
    //点击头像，跳转个人主页
    return cell;
}

- (void)avatorclick:(UITapGestureRecognizer *)gesture
{
    //我们获取gesture关联的view,并将view的类名打印出来
    //NSString *className = NSStringFromClass([gesture.view class]);
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    WhatsGoingOn *item = [self.dataSource objectAtIndex:selectedIndexPath.row];
    
    User *showUserInfo = [[User alloc]init];
    showUserInfo.UserID = item.photoUser.UserID;
    
    UIStoryboard *personalStoryboard= [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
    MineViewController *personalViewCon = [personalStoryboard instantiateViewControllerWithIdentifier:@"personalPage"];

    [personalViewCon setUserInfo:showUserInfo];
    [self.navigationController pushViewController:personalViewCon animated:YES];
}

-(void)zanViewClick:(UITapGestureRecognizer *)gesture
{
    NSLog(@"click zan");
    

    
   // [[[UIAlertView alloc] initWithTitle:@"提示" message:@"赞了！！！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil] show];
   // [self.tableView reloadRowsAtIndexPaths:@[selectItemIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    PhotoTableViewCell * cell = (PhotoTableViewCell *) [[gesture.view superview]superview];
    NSIndexPath *selectItemIndexPath = [self.tableView indexPathForCell:cell];
    WhatsGoingOn *item = [self.dataSource objectAtIndex:selectItemIndexPath.row];
    if ([cell.zanClickLabel.text isEqualToString:@"赞"])
    {
        [self zanPhotoWithItem:item];
        item.likeCount += 1;
        cell.likeLabel.text = [NSString stringWithFormat:@"%lu 次赞",(long)item.likeCount];
        cell.zanClickLabel.text = @"赞了";
    }
    else if ([cell.zanClickLabel.text isEqualToString:@"赞了"])
    {
        [self cancelZanPhotoWithItem:item];
        item.likeCount -= 1;
        cell.likeLabel.text = [NSString stringWithFormat:@"%lu 次赞",(long)item.likeCount];
        cell.zanClickLabel.text = @"赞";
    }
    
}

-(void)commentViewClick:(UITapGestureRecognizer *)gesture
{
    
    WhatsGoingOn *item = [self.dataSource objectAtIndex:0];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"photoDetailAndComment" bundle:nil];
    CommentListViewController *detailAndCommentView = [storyboard instantiateViewControllerWithIdentifier:@"commentListView"];
    //[detailAndCommentView setWhatsGoingOnItem:item];
    [self.navigationController pushViewController:detailAndCommentView animated:YES];
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
    //NSLog(@"scroll view did scroll");
    self.shouldRefreshData = true;
    [self.QIUDAOYURefreshControl scrollViewDidScroll];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //NSLog(@"scroll view did end dragging");
    [self.QIUDAOYURefreshControl scrollViewDidEndDragging];
}

#pragma mark- Listen for the user to trigger a refresh
-(void)refreshTriggered:(id)sender
{
    [self GetLatestDataList];
    //另起线程 GetLatestDataList
    //...
    [self performSelector:@selector(finishRefreshControl) withObject:nil afterDelay:3    inModes:@[NSRunLoopCommonModes]];
}


-(void)finishRefreshControl
{
    [self.QIUDAOYURefreshControl finishingLoading];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark ----- control the model

-(void)GetLatestDataList
{
    self.shouldRefreshData = false;
    NSInteger userId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    [[AFHTTPAPIClient sharedInstance]GetWhatsGoingOnWithUserId:userId whenComplete:^(NSDictionary *result) {
        
        if ([result objectForKey:@"data"])
        {
            
            self.dataSource = [result objectForKey:@"data"];
            [self.tableView reloadData];
            
        }
        else if ([result objectForKey:@"error"])
        {
            [SVProgressHUD showErrorWithStatus:[result objectForKey:@"error"]];
        }
        
    }];
}

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

-(void)zanPhotoWithItem:(WhatsGoingOn *)item
{
   [[AFHTTPAPIClient sharedInstance]ZanPhotoWithUserId:self.currentUser.UserID postId:item.postId whenComplete:^(NSDictionary *result) {
        if (result)
        {
            // self.dataSource = [result mutableCopy];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"请求失败,请检查连接"];
            
        }
    } ];

}
-(void)cancelZanPhotoWithItem:(WhatsGoingOn *)item
{
    
}


-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
