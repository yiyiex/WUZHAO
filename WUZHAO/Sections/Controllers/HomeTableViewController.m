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
@property (nonatomic,strong) UIButton *loadMoreButton;
@property (nonatomic,strong) UIActivityIndicatorView *aiv;
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

    //refresh control
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

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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

-(void)addFooterLoadMore
{
    UIView *tableFooterView = [[UIView alloc]init];
    tableFooterView.frame = CGRectMake(0, 0, WZ_APP_SIZE.width, 44);
    self.tableView.tableFooterView = tableFooterView;
    
    _loadMoreButton = [[UIButton alloc]init];
    _loadMoreButton.frame = CGRectMake(0, 0, WZ_APP_SIZE.width, 44);
    [_loadMoreButton setTitle:@"加载更多" forState:UIControlStateNormal];
    [_loadMoreButton.titleLabel setFont:WZ_FONT_SMALL_READONLY];
    [_loadMoreButton setTitleColor:THEME_COLOR_LIGHT_GREY forState:UIControlStateNormal];
    [_loadMoreButton addTarget:self action:@selector(loadMore:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView.tableFooterView addSubview:_loadMoreButton];
    
    _aiv = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _aiv.center = _loadMoreButton.center;
    [self.tableView.tableFooterView addSubview:_aiv];
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

-(void)loadMore:(id)sender
{
    //TO DO
    //get the new page data
    [_aiv startAnimating];
    [sender setHidden:YES];
   // dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[QDYHTTPClient sharedInstance]GetWhatsGoingOnWithUserId:self.currentUser.UserID page:self.currentPage+1 whenComplete:^(NSDictionary *result) {
            //sleep(5);
            if ([result objectForKey:@"data"])
            {
                NSMutableArray *newData = [result objectForKey:@"data"];
                if (newData.count ==0)
                {
                    [self.loadMoreButton setTitle:@"没有更多数据了" forState:UIControlStateNormal];
                }
                else
                {
                    [self.dataSource addObjectsFromArray:newData];
                    [self.tableView reloadData];
                    self.currentPage +=1;
                }
                
            }
            else if ([result objectForKey:@"error"])
            {
                [self.loadMoreButton setTitle:@"加载失败" forState:UIControlStateNormal];
            }
            [_aiv stopAnimating];
            [sender setHidden:NO];
        }];
   // });
    
    
}

#pragma mark - tableview delegate

- (void)configureCell:(PhotoTableViewCell *)cell forContent:(WhatsGoingOn *)content atIndexPath:(NSIndexPath *)indexPath
{
  
    //配置评论样式
    [self configureCommentViewOf:cell with:content];
    //配置图片相关基本信息
    [self configureBasicInfoOf:cell with:content];
    //配置点赞内容
    [self configureLikeLabelViewOf:cell with:content];
    //配置cell被点击效果
    [self configureGestureOf:cell];
    
    [cell setAppearance];
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
}
-(void)configureCommentViewOf :(PhotoTableViewCell *)cell with:(WhatsGoingOn *)content
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
}
-(void)configureLikeLabelViewOf :(PhotoTableViewCell*)cell with:(WhatsGoingOn *)content
{
    
    //点赞用户头像展示区
    for (UIView *likeViewSub in cell.likeLabelView.subviews)
    {
        if( [likeViewSub isKindOfClass:[UIImageView class]])
        {
            [likeViewSub removeFromSuperview];
        }
    }
    if (content.likeCount >0)
    {
        
        NSInteger avatorNum = 0;
        BOOL isLikeCountShow = true;
        NSInteger likeUserCount = content.likeUserList.count;
        if (isIPHONE_6P)
        {
            avatorNum = likeUserCount>11?11:likeUserCount;
            isLikeCountShow = likeUserCount>11?true:false;
        }
        if (isIPHONE_6)
        {
            avatorNum = likeUserCount>10?10:likeUserCount;
            isLikeCountShow = likeUserCount>10?true:false;
        }
        if (isIPHONE_5)
        {
            avatorNum = likeUserCount>8?8:likeUserCount;
            isLikeCountShow = likeUserCount>8?true:false;
        }
        //[cell.likeLabel setHidden:NO];
        //cell.likeLabel.text = [NSString stringWithFormat:@"%lu赞", (long)content.likeCount];
        if (isLikeCountShow)
        {
            cell.likeLabel.text = [NSString stringWithFormat:@"%lu赞", (long)content.likeCount];
        }
        else
        {
            [cell.likeLabel setHidden:YES];
        }
        for (NSInteger i = 0 ; i< avatorNum ; i++)
        {
            UIImageView *zanAvatar = [[UIImageView alloc]init];
            [zanAvatar setFrame:CGRectMake( 8 + 34*i +2 , 2, 30, 30)];
            [zanAvatar setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
            [zanAvatar setOpaque:YES];
            [zanAvatar setRoundConerWithRadius:15];
            User *userInfo = [content.likeUserList objectAtIndex:i];
            
            [zanAvatar sd_setImageWithURL:[NSURL URLWithString:userInfo.avatarImageURLString]];
            [cell.likeLabelView addSubview:zanAvatar];
            
            UITapGestureRecognizer *zanUserAvatarClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zanUserAvatarClick:)];
            [zanAvatar setUserInteractionEnabled:YES];
            [zanAvatar addGestureRecognizer:zanUserAvatarClick];
            [cell.likeLabelHeightConstraint setConstant:34];
        }
      
    }
    else
    {
        cell.likeLabel.text = @"";
        [cell.likeLabelHeightConstraint setConstant:0];
    }

}
-(void)configureBasicInfoOf:(PhotoTableViewCell *)cell with:(WhatsGoingOn *)content
{
    cell.postTimeLabel.text = content.postTime;
    cell.postUserName.text = content.photoUser.UserName;
    cell.postUserSelfDescription.text = [content.photoUser.selfDescriptions stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    [cell.homeCellAvatorImageView sd_setImageWithURL:[NSURL URLWithString:content.photoUser.avatarImageURLString]];
    
    
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
}
-(void)configureGestureOf:(PhotoTableViewCell *)cell
{
    UITapGestureRecognizer *avatarClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarClick:)];
    [cell.homeCellAvatorImageView addGestureRecognizer:avatarClick];
    //点击照片描述，跳转照片详情页面
    UITapGestureRecognizer *thoughtClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(thoughtClick:)];
    [cell.descriptionLabel setUserInteractionEnabled:YES];
    [cell.descriptionLabel addGestureRecognizer:thoughtClick];
    
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

-(void)zanUserAvatarClick:(UITapGestureRecognizer *)gesture
{
    self.tableViewOffset = self.tableView.contentOffset.y;
    UIView *likeView = (UIView *)[gesture.view superview];
    NSInteger likeUserIndex = 0;
    for (NSInteger i = 1;i <likeView.subviews.count;i++)
    {
        if ([gesture.view isEqual:likeView.subviews[i]])
        {
            likeUserIndex = i-1;
            break;
        }
            
    }
    PhotoTableViewCell * cell = (PhotoTableViewCell *)[[[gesture.view superview]superview]superview];
    NSIndexPath *selectItemIndexPath = [self.tableView indexPathForCell:cell];
    WhatsGoingOn *item = [self.dataSource objectAtIndex:selectItemIndexPath.row];
    
    UIStoryboard *personalStoryboard= [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
    MineViewController *personalViewCon = [personalStoryboard instantiateViewControllerWithIdentifier:@"personalPage"];
    
    [personalViewCon setUserInfo:item.likeUserList[likeUserIndex]];
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
        UIAlertAction *delectAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action)
            {
            //TO DO
            //删除该条记录
                UIAlertController *deleteWarningController = [UIAlertController alertControllerWithTitle:@"提醒" message:@"确定删除照片？" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                
                }];
                UIAlertAction *comfirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [[QDYHTTPClient sharedInstance]deletePhotoWithUserId:self.currentUser.UserID postId:item
                     .postId whenComplete:^(NSDictionary *returnData)
                    {
                        [self.dataSource removeObjectAtIndex:selectItemIndexPath.row];
                        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject: selectItemIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
                     }];
                }];
                [deleteWarningController addAction:cancelAction];
                [deleteWarningController addAction:comfirmAction];
                [self presentViewController:deleteWarningController animated:YES completion:nil];

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

-(void)thoughtClick:(UITapGestureRecognizer *)gesture
{
    PhotoTableViewCell *cell = (PhotoTableViewCell *)[[[gesture.view superview]superview]superview];
    NSIndexPath *selectIndexPath = [self.tableView indexPathForCell:cell];
    WhatsGoingOn *item = [self.dataSource objectAtIndex:selectIndexPath.row];
    
    UIStoryboard *detailStoryBoard = [UIStoryboard storyboardWithName:@"photoDetailAndComment" bundle:nil];
    
    PhotoDetailViewController *detailViewController = [detailStoryBoard instantiateViewControllerWithIdentifier:@"photoDetailView"];
    [detailViewController setWhatsGoingOnItem:item];
    detailViewController.cellIndexInCollection = selectIndexPath;
    [self.navigationController pushViewController:detailViewController animated:YES];
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
                    //item.likeCount += 1;
                    [self addMeToZanData:item];
                    [self configureLikeLabelViewOf:cell with:item];
                    if (item.likeCount == 1)
                    {
                        //to do
                        //如何改变世界！
                        [self.tableView beginUpdates];
                        [self.tableView endUpdates];
                        
                    }
                
                    [cell.zanClickButton setTitle:@"已赞" forState:UIControlStateNormal];

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
                   // item.likeCount -= 1;
                    [self deleteMeFromZanData:item];
                    [self configureLikeLabelViewOf:cell with:item];
                    if (item.likeCount ==0)
                    {
                        
                        [self.tableView beginUpdates];
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectItemIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                        [self.tableView endUpdates];
                        
 
                    }
                    [cell.zanClickButton setTitle:@"赞" forState:UIControlStateNormal];
                }
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
            }
        }];
    }
    [cell setAppearance];
    NSLog(@"table view offset before reload the cell : %f",self.tableView.contentOffset.y);
    self.tableViewOffset = self.tableView.contentOffset.y;
   // [cell setNeedsLayout];
   // [cell layoutIfNeeded];

}
-(void)addMeToZanData:(WhatsGoingOn *)data
{
    User *me = [[User alloc]init];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    me.UserID = [ud integerForKey:@"userId"];
    me.UserName = [ud valueForKey:@"userName"];
    //me.avatarImageURLString = @"http://pic1.zhimg.com/9e2cf566532ec4cd24ce0f18b5282c79_l.jpg";
    me.avatarImageURLString = [ud valueForKey:@"avatarUrl"];
    NSMutableArray *newLikeUserList = [[NSMutableArray alloc]initWithObjects:me, nil];
    [newLikeUserList addObjectsFromArray:data.likeUserList];
    data.likeUserList = newLikeUserList;
    data.likeCount ++;
    data.isLike = true;
    
    

}
-(void)deleteMeFromZanData:(WhatsGoingOn *)data
{
    NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    for ( User *user in data.likeUserList)
    {
        if (user.UserID == myUserId)
        {
            [data.likeUserList removeObject:user];
            break;
        }
    }
    data.likeCount --;
    data.isLike = false;
}

-(void)commentButtonClick:(id)sender
{
    self.tableViewOffset = self.tableView.contentOffset.y;
    PhotoTableViewCell *cell = (PhotoTableViewCell *)[[sender superview]superview];
    NSIndexPath *selectItemIndexPath = [self.tableView indexPathForCell:cell];
    WhatsGoingOn *item = [self.dataSource objectAtIndex:selectItemIndexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"photoDetailAndComment" bundle:nil];
    CommentListViewController *commentListView = [storyboard instantiateViewControllerWithIdentifier:@"commentListView"];
    commentListView.poiItem = item;
    [self.navigationController pushViewController:commentListView animated:YES];
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
    
    CGPoint loadMorePoint = CGPointMake(0, self.tableView.contentSize.height);
    CGPoint targetPoint = *targetContentOffset;
    if (targetPoint.y > loadMorePoint.y - WZ_APP_SIZE.height + 90.0)
    {
        //[self loadMore:self.loadMoreButton];
        //[self performSelector:@selector(loadMore:) withObject:self.tableView.tableFooterView];
        [self performSelectorOnMainThread:@selector(loadMore:) withObject:self.loadMoreButton waitUntilDone:NO];
    }
    
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
        //[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
        self.shouldRefreshData = false;
        self.currentPage = 1;
        [[QDYHTTPClient sharedInstance]GetWhatsGoingOnWithUserId:self.currentUser.UserID page:self.currentPage whenComplete:^(NSDictionary *result) {
            
            if ([result objectForKey:@"data"])
            {
                
                self.dataSource = [result objectForKey:@"data"];
                [self.tableView reloadData];
                [self addFooterLoadMore];
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
            //[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
            
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



@end
