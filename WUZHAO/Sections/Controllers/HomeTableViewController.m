//
//  HomeTableViewController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-15.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "HomeTableViewController.h"
#import "MineViewController.h"
#import "AddressViewController.h"
#import "CommentListViewController.h"
#import "UserListTableViewController.h"

#import "UIImageView+WebCache.h"
#import "UIImageView+ChangeAppearance.h"
#import "UIButton+ChangeAppearance.h"
#import "UILabel+ChangeAppearance.h"
#import "PhotoCommon.h"

#import "PureLayout.h"

#import "SVProgressHUD.h"

#import "QDYHTTPClient.h"
#import "macro.h"

#define ONEPAGEITEMS 10


@interface HomeTableViewController ()<UIActionSheetDelegate,UIAlertViewDelegate>
@property (nonatomic,strong) UIRefreshControl *refreshControl;
@property (nonatomic,strong) UIButton *loadMoreButton;
@property (nonatomic,strong) UIActivityIndicatorView *aiv;
//current page
@property (nonatomic,assign) NSInteger currentPage;


@property (nonatomic) float tableViewOffset;
@property (nonatomic)  BOOL shouldRefreshData;
@property (nonatomic,strong) NSIndexPath *currentZanIndexPath;

@property (nonatomic,strong) NSIndexPath *currentCommentIndexPath;
@property (nonatomic,strong) NSIndexPath *currentDeleteIndexPath;

@property (nonatomic,strong) PhotoTableViewCell *prototypeCell;
@property (nonatomic,strong) UIView *introductionView;

@end

@implementation HomeTableViewController
static NSString *reuseIdentifier = @"HomeTableCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    if (SYSTEM_VERSION_EQUAL_TO(@"7"))
    {
         self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.tableView.alwaysBounceVertical = YES;
    [self initNavigationItem];
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        self.tableView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    //refresh control
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refreshByPullingTable:) forControlEvents:UIControlEventValueChanged];
    self.shouldRefreshData = true;
    self.tableViewOffset = 0.0;
    [self loadData];
    

}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initNavigationItem];
    //从评论页面返回
    if (self.currentCommentIndexPath)
    {
        [self.tableView beginUpdates];
        PhotoTableViewCell *commentCell = (PhotoTableViewCell *) [self.tableView cellForRowAtIndexPath:self.currentCommentIndexPath];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.currentCommentIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [commentCell configureComment];
        [commentCell reloadInputViews];
        [self.tableView endUpdates];
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


-(void)initNavigationItem
{
    self.tabBarController.navigationController.navigationBarHidden = NO;
    if (self.tableStyle == WZ_TABLEVIEWSTYLEHOME)
    {
        self.tabBarController.navigationItem.title = @"Place";
    }
    else
    {
        self.tabBarController.navigationItem.title = @"照片详情";
        self.navigationItem.title = @"照片详情";
    }
    self.tabBarController.navigationItem.hidesBackButton = YES;
    
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarItem;
    
    //[self.navigationItem.backBarButtonItem setTitle:@""];
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
    NSString *footButonTitle = @"加载更多" ;
    UIView *tableFooterView = [[UIView alloc]init];
    tableFooterView.frame = CGRectMake(0, 0, WZ_APP_SIZE.width, 44);
    self.tableView.tableFooterView = tableFooterView;
    
    _loadMoreButton = [[UIButton alloc]init];
    _loadMoreButton.frame = CGRectMake(0, 0, WZ_APP_SIZE.width, 44);
    [_loadMoreButton setTitle:footButonTitle forState:UIControlStateNormal];
    [_loadMoreButton.titleLabel setFont:WZ_FONT_SMALL_READONLY];
    [_loadMoreButton setTitleColor:THEME_COLOR_LIGHT_GREY forState:UIControlStateNormal];
    [_loadMoreButton addTarget:self action:@selector(loadMore:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView.tableFooterView addSubview:_loadMoreButton];
    
    _aiv = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _aiv.center = _loadMoreButton.center;
    [self.tableView.tableFooterView addSubview:_aiv];
    NSLog(@"tableview frame:x %f y %f  w %f  h %f",self.tableView.frame.origin.x,self.tableView.frame.origin.y,self.tableView.frame.size.width,self.tableView.frame.size.height);
}
-(void)addIntroductionButton
{
    if (![self.introductionView superview])
    {
        self.introductionView = [[UIView alloc]initWithFrame:self.view.frame];
        UILabel *huoLabel = [[UILabel alloc]init];
        huoLabel.text = @"或";
        [huoLabel setSmallReadOnlyLabelAppearance];
        [huoLabel sizeToFit];
        huoLabel.center = CGPointMake(self.introductionView.frame.size.width/2,self.introductionView.frame.size.height/2-64);
        [self.introductionView addSubview:huoLabel];
        
        [PhotoCommon drawALineWithFrame:CGRectMake(60, huoLabel.center.y, WZ_APP_SIZE.width/2-huoLabel.frame.size.width-60, 0.5) andColor:THEME_COLOR_LIGHT_GREY_PARENT inLayer:self.introductionView.layer];
        [PhotoCommon drawALineWithFrame:CGRectMake(huoLabel.center.x+huoLabel.frame.size.width, huoLabel.center.y, WZ_APP_SIZE.width/2-huoLabel.frame.size.width-60, 0.5) andColor:THEME_COLOR_LIGHT_GREY_PARENT inLayer:self.introductionView.layer];
        
        UIButton *searchAndAddButton = [[UIButton alloc]initWithFrame:CGRectMake(30, huoLabel.center.y+38, WZ_APP_SIZE.width-60, 42)];
        [searchAndAddButton setTitle:@"浏览照片并关注" forState:UIControlStateNormal];
        [searchAndAddButton setThemeBackGroundAppearance];
        [searchAndAddButton setBigButtonAppearance];
        [searchAndAddButton addTarget:self action:@selector(searchAndAddButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.introductionView addSubview:searchAndAddButton];
        
        UIButton *postMyFirstPhotoButton = [[UIButton alloc]initWithFrame:CGRectMake(30, huoLabel.center.y-80, WZ_APP_SIZE.width-60, 42)];
        [postMyFirstPhotoButton setTitle:@"发布第一张照片" forState:UIControlStateNormal];
        [postMyFirstPhotoButton setThemeBackGroundAppearance];
        [postMyFirstPhotoButton setBigButtonAppearance];
        [postMyFirstPhotoButton addTarget:self action:@selector(postMyFirstPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.introductionView addSubview:postMyFirstPhotoButton];
        
        [self.view addSubview:self.introductionView];
        NSLog(@"introductionview frame:x %f y %f  w %f  h %f",self.introductionView.frame.origin.x,self.introductionView.frame.origin.y,self.introductionView.frame.size.width,self.introductionView.frame.size.height);
        NSLog(@"introductionview center %f  %f",self.introductionView.center.x,self.introductionView.center.y);
        NSLog(@"label center %f  %f",huoLabel.center.x,huoLabel.center.y);
        
        if (self.tableView.tableFooterView)
        {
            [self.tableView.tableFooterView removeFromSuperview];
        }
    }
    
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
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[QDYHTTPClient sharedInstance]GetWhatsGoingOnWithUserId:self.currentUser.UserID page:self.currentPage+1 whenComplete:^(NSDictionary *result) {
            //sleep(5);
            dispatch_async(dispatch_get_main_queue(), ^{
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
            });

        }];
    });
    
    
}

#pragma mark - tableview delegate

- (void)configureCell:(PhotoTableViewCell *)cell forContent:(WhatsGoingOn *)content atIndexPath:(NSIndexPath *)indexPath
{
  
    //配置评论样式
    [cell configureCellWithData:content parentController:self];
    
    [cell setAppearance];
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
}
- (PhotoTableViewCell *)prototypeCell
{
    if (!_prototypeCell) {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PhotoTableViewCell class])];
    }
    
    return _prototypeCell;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        return UITableViewAutomaticDimension;
    }
    return 600;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WhatsGoingOn *item = [self.dataSource objectAtIndex:indexPath.row];
    /*
    [self.prototypeCell configureCellWithData:item parentController:nil];
    CGSize size =  [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    float height = size.height;*/
    
    //NSDictionary *addressTextAttribute = @{NSFontAttributeName:WZ_FONT_COMMON_BOLD_SIZE};
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *descriptionTextAttribute = @{NSFontAttributeName:WZ_FONT_COMMON_SIZE,NSParagraphStyleAttributeName:paragraphStyle.copy};
    NSDictionary *commentTextAttribute = @{NSFontAttributeName:WZ_FONT_SMALL_SIZE,NSParagraphStyleAttributeName:paragraphStyle.copy};
    float labelWidth = WZ_APP_SIZE.width -16;
    //head view + image view + address view + description view + zan avatar view + comment view
    float baseHeight =  48 + WZ_APP_SIZE.width ; //head view + image View
    float descriptionViewHeight,ZanViewHeight,CommentViewHeight,buttonHeight;
    if ([item.imageDescription isEqualToString:@""])
    {
        descriptionViewHeight = 8.0f;
    }
    else
    {
        descriptionViewHeight = 10.0f + [item.imageDescription boundingRectWithSize:CGSizeMake(labelWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine  attributes:descriptionTextAttribute context:nil].size.height + 8.0f +0.2f;
        
    }
    NSLog(@"descriptionViewHeight caculate :=====>%f",descriptionViewHeight);
    ZanViewHeight = item.likeUserList.count<=0?0:32;
    if (item.commentStringList.count == 0)
    {
        CommentViewHeight = 0;
    }
    else
    {
        for (NSString *commentString in item.commentStringList)
        {
            
            float commentLabelHeight = [commentString boundingRectWithSize:CGSizeMake(labelWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine attributes:commentTextAttribute context:nil].size.height;
            float offset = 6.7f + commentLabelHeight/13.8f*0.2f;
            //offset = 7.0f;
            CommentViewHeight += commentLabelHeight + offset;
            NSLog(@"comment Height caculate :=====>%f",commentLabelHeight);
        }
        if (item.commentStringList.count>4)
        {
            float moreLabelHeight = 24.0f;
            
            //float moreLabelHeight = [@"查看更多评论" boundingRectWithSize:CGSizeMake(labelWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine  attributes:commentTextAttribute context:nil].size.height;
            CommentViewHeight += moreLabelHeight;
            NSLog(@"lookmore comment Height caculate :=====>%f",moreLabelHeight);
        }
        CommentViewHeight += 4;
    }
    buttonHeight = 44;//8 +24 +12
    float height = baseHeight  + descriptionViewHeight + ZanViewHeight + CommentViewHeight + buttonHeight  ;
    NSLog(@"caculate height at index :%ld----- %f",(long)indexPath.row,height);
    return height;
}
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

    //各控件单击效果
    //点击头像，跳转个人主页
    [self configureCell:cell forContent:item atIndexPath:indexPath];

    return cell;
}


#pragma mark - gesture action
-(void)searchAndAddButtonClick:(UIButton *)sender
{
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"activeTargetTab" object:self userInfo:@{@"index":@1}];
}
-(void)postMyFirstPhotoButtonClick:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"activeTargetTab" object:self userInfo:@{@"index":@2}];
}

-(void)moreCommentClick:(UITapGestureRecognizer *)gesture
{
    PhotoTableViewCell * cell ;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8"))
    {
        cell = (PhotoTableViewCell *)[[[gesture.view superview]superview]superview];
    }
    else
    {
        cell = (PhotoTableViewCell *)[[[[gesture.view superview]superview]superview]superview];
    }
    NSIndexPath *selectItemIndexPath = [self.tableView indexPathForCell:cell];
    self.currentCommentIndexPath = selectItemIndexPath;
     WhatsGoingOn *item = [self.dataSource objectAtIndex:selectItemIndexPath.row];
    CommentListViewController *commentListView = [[CommentListViewController alloc]init];
    [commentListView setPoiItem:item];
    [commentListView setCommentList:[item.commentList mutableCopy]];
     [self.navigationController pushViewController:commentListView animated:YES];
}
-(void)commentLabelClick:(UITapGestureRecognizer *)gesture
{
    PhotoTableViewCell * cell ;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8"))
    {
        cell = (PhotoTableViewCell *)[[[gesture.view superview]superview]superview];
    }
    else
    {
        cell = (PhotoTableViewCell *)[[[[gesture.view superview]superview]superview]superview];
    }
    NSInteger indexOfComment = 0;
    for (NSInteger i = 0;i<[gesture.view superview].subviews.count;i++)
    {
        if ([gesture.view isEqual:gesture.view.superview.subviews[i]])
        {
            indexOfComment = i;
            break;
        }
            
    }
    NSIndexPath *selectItemIndexPath = [self.tableView indexPathForCell:cell];
    self.currentCommentIndexPath = selectItemIndexPath;
    WhatsGoingOn *item = [self.dataSource objectAtIndex:selectItemIndexPath.row];
    User *user = [[User alloc]init];
    NSDictionary *commentInfo = item.commentList[indexOfComment];
    user.UserID = [(NSNumber *)[commentInfo objectForKey:@"userId"] integerValue];
    user.UserName = [commentInfo objectForKey:@"nick"];
    [self goToPersonalPageWithUserInfo:user];
}

- (void)avatarClick:(UITapGestureRecognizer *)gesture
{
    //我们获取gesture关联的view,并将view的类名打印出来
    //NSString *className = NSStringFromClass([gesture.view class]);
    PhotoTableViewCell * cell;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8"))
    {
        cell = (PhotoTableViewCell *)[[[gesture.view superview]superview]superview];
    }
    else
    {
        cell = (PhotoTableViewCell *)[[[[gesture.view superview]superview]superview]superview];
    }
    NSIndexPath *selectItemIndexPath = [self.tableView indexPathForCell:cell];

    WhatsGoingOn *item = [self.dataSource objectAtIndex:selectItemIndexPath.row];
    [self goToPersonalPageWithUserInfo:item.photoUser];
}

-(void)zanUserAvatarClick:(UITapGestureRecognizer *)gesture
{
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
    PhotoTableViewCell * cell ;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8"))
    {
        cell = (PhotoTableViewCell *)[[[gesture.view superview]superview]superview];
    }
    else
    {
        cell = (PhotoTableViewCell *)[[[[gesture.view superview]superview]superview]superview];
    }
    NSIndexPath *selectItemIndexPath = [self.tableView indexPathForCell:cell];
    WhatsGoingOn *item = [self.dataSource objectAtIndex:selectItemIndexPath.row];
    [self goToPersonalPageWithUserInfo:item.likeUserList[likeUserIndex]];
   // [[NSNotificationCenter defaultCenter]postNotificationName:@"hideTabBar" object:nil];
}
-(void)moreButtonClick:(UIButton *)sender
{
    //NSInteger userId = [[NSUserDefaults standardUserDefaults] integerForKey:@"userId"];
    PhotoTableViewCell *cell ;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8"))
    {
        cell = (PhotoTableViewCell *)[[sender superview]superview];
    }
    else
    {
        cell = (PhotoTableViewCell *)[[[sender superview]superview]superview];
    }
    NSIndexPath *selectItemIndexPath = [self.tableView indexPathForCell:cell];
    WhatsGoingOn *item = [self.dataSource objectAtIndex:selectItemIndexPath.row];
    if (SYSTEM_VERSION_GREATER_THAN(@"8"))
    {
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
                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                            [[QDYHTTPClient sharedInstance]deletePhotoWithUserId:self.currentUser.UserID postId:item
                             .postId whenComplete:^(NSDictionary *returnData)
                             {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if ([returnData objectForKey:@"data"])
                                     {
                                         [self.tableView beginUpdates];
                                         [self.dataSource removeObjectAtIndex:selectItemIndexPath.row];
                                         [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject: selectItemIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
                                         [self.tableView endUpdates];
                                     }
                                     else
                                     {
                                         [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
                                     }
                                 });

                                 
                             }];
                        });

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
                [SVProgressHUD showInfoWithStatus:@"已举报"];
            }];
            [alertController addAction:delectAction];
        }
        /*
        UIAlertAction *shareAction = [UIAlertAction actionWithTitle:@"复制共享网址" style:nil handler:^(UIAlertAction *action) {
            NSLog(@"share pressed");
        }];
        [alertController addAction:shareAction];
         */
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else if (SYSTEM_VERSION_LESS_THAN(@"8"))
    {
        NSString *destructiveButtonTitle;
        self.currentDeleteIndexPath = selectItemIndexPath;
        if (self.currentUser.UserID == item.photoUser.UserID)
        {
            destructiveButtonTitle = @"删除";
        }
        else
        {
            destructiveButtonTitle = @"举报不良内容";
        }
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil];
        [actionSheet showInView:self.view];
    }
    

}

-(void)goToPersonalPageWithUserInfo:(User *)user
{
    UIStoryboard *personalStoryboard= [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
    MineViewController *personalViewCon = [personalStoryboard instantiateViewControllerWithIdentifier:@"personalPage"];
    [personalViewCon setUserInfo:user];
    [self.navigationController pushViewController:personalViewCon animated:YES];
}

#pragma mark - actionSheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"删除"])
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提醒" message:@"确定删除照片？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"举报不良内容"])
    {
        [SVProgressHUD showInfoWithStatus:@"已举报"];
    }
}

#pragma mark - alertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"确定"])
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            WhatsGoingOn *item = [self.dataSource objectAtIndex:self.currentDeleteIndexPath];
            [[QDYHTTPClient sharedInstance]deletePhotoWithUserId:self.currentUser.UserID postId:item
             .postId whenComplete:^(NSDictionary *returnData)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if ([returnData objectForKey:@"data"])
                     {
                         [self.tableView beginUpdates];
                         [self.dataSource removeObjectAtIndex:self.currentDeleteIndexPath.row];
                         [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.currentDeleteIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
                         [self.tableView endUpdates];
                     }
                     else
                     {
                         [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
                     }
                 });
                 
                 
             }];
        });

    }
}
/*
-(void)thoughtClick:(UITapGestureRecognizer *)gesture
{
    PhotoTableViewCell *cell = (PhotoTableViewCell *)[[[gesture.view superview]superview]superview];
    NSIndexPath *selectIndexPath = [self.tableView indexPathForCell:cell];
    WhatsGoingOn *item = [self.dataSource objectAtIndex:selectIndexPath.row];
    
    UIStoryboard *detailStoryBoard = [UIStoryboard storyboardWithName:@"photoDetailAndComment" bundle:nil];
    
    HomeTableViewController *detailViewController = [detailStoryBoard instantiateViewControllerWithIdentifier:@"photoDetailView"];
    [detailViewController setWhatsGoingOnItem:item];
    detailViewController.cellIndexInCollection = selectIndexPath;
    [self.navigationController pushViewController:detailViewController animated:YES];
}
 */
-(void)zanButtonClick:(id)sender
{
    PhotoTableViewCell *cell;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8"))
    {
         cell = (PhotoTableViewCell *)[[sender superview]superview];
    }
    else
    {
        cell = (PhotoTableViewCell *)[[[sender superview]superview]superview];
    }
    NSIndexPath *selectItemIndexPath = [self.tableView indexPathForCell:cell];
    
    WhatsGoingOn *item = [self.dataSource objectAtIndex:selectItemIndexPath.row];
    if (!item.isLike)
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[QDYHTTPClient sharedInstance]ZanPhotoWithUserId:self.currentUser.UserID postId:item.postId whenComplete:^(NSDictionary *returnData) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([returnData objectForKey:@"data"])
                    {
                        if ([cell.zanClickButton.currentTitle isEqualToString:@"赞"])
                        {
                            //item.likeCount += 1;
                            [self addMeToZanData:item];
                            [cell configureCellWithData:item parentController:self];
                            if (item.likeCount == 1)
                            {
                                //to do
                                //如何改变世界！
                                self.currentZanIndexPath = selectItemIndexPath;
                                [self.tableView beginUpdates];
                                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectItemIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                                [self.tableView endUpdates];
                                //[self.tableView beginUpdates];
                                //[self.tableView endUpdates];
                                
                            }
                            
                            // [cell.zanClickButton setTitle:@"已赞" forState:UIControlStateNormal];
                            
                        }
                    }
                    else
                    {
                        [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
                    }

                });
            }];
        });

        
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[QDYHTTPClient sharedInstance]CancelZanPhotoWithUserId:self.currentUser.UserID postId:item.postId whenComplete:^(NSDictionary *returnData) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([returnData objectForKey:@"data"])
                    {
                        if ([cell.zanClickButton.currentTitle isEqualToString:@"赞了"])
                        {
                            // item.likeCount -= 1;
                            [self deleteMeFromZanData:item];
                            [cell configureCellWithData:item parentController:self];
                            if (item.likeCount ==0)
                            {
                                self.currentZanIndexPath = selectItemIndexPath;
                                [self.tableView beginUpdates];
                                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectItemIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                                [self.tableView endUpdates];
                                // [self.tableView beginUpdates];
                                //[self.tableView endUpdates];
                            }
                            //  [cell.zanClickButton setTitle:@"赞" forState:UIControlStateNormal];
                        }
                    }
                    else
                    {
                        [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
                    }
                });

            }];
        });

    }

}
-(void)addMeToZanData:(WhatsGoingOn *)data
{
    User *me = [[User alloc]init];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    me.UserID = [ud integerForKey:@"userId"];
    me.UserName = [ud valueForKey:@"userName"];
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
    PhotoTableViewCell *cell;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8"))
    {
        cell = (PhotoTableViewCell *)[[sender superview]superview];
    }
    else
    {
        cell = (PhotoTableViewCell *)[[[sender superview]superview]superview];
    }
    NSIndexPath *selectItemIndexPath = [self.tableView indexPathForCell:cell];
    self.currentCommentIndexPath = selectItemIndexPath;
    WhatsGoingOn *item = [self.dataSource objectAtIndex:selectItemIndexPath.row];
    CommentListViewController *commentListView = [[CommentListViewController alloc]init];
    commentListView.poiItem = item;
    [self.navigationController pushViewController:commentListView animated:YES];
}

-(void)likeLabelClick:(UITapGestureRecognizer *)gesture
{
    PhotoTableViewCell *cell;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8"))
    {
        cell = (PhotoTableViewCell *)[[[gesture.view superview]superview]superview];
    }
    else
    {
        cell = (PhotoTableViewCell *)[[[[gesture.view superview]superview]superview]superview];
    }
    NSIndexPath *selectIndexPath = [self.tableView indexPathForCell:cell];
     WhatsGoingOn *item = [self.dataSource objectAtIndex:selectIndexPath.row];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[QDYHTTPClient sharedInstance]GetPhotoZanUserListWithPostId:item.postId whenComplete:^(NSDictionary *returnData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([returnData objectForKey:@"data"])
                {
                    UIStoryboard *userListStoryBoard = [UIStoryboard storyboardWithName:@"UserList" bundle:nil];
                    UserListTableViewController *followsList = [userListStoryBoard instantiateViewControllerWithIdentifier:@"userListTableView"];
                    [followsList setUserListStyle:UserListStyle1];
                    [followsList setDatasource:[returnData objectForKey:@"data"]];
                    [followsList setTitle:@"点赞的用户"];
                    [self.navigationController pushViewController:followsList animated:YES];
                }
                else
                {
                    [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
                }
            });

        }];
    });

}

-(void)addressLabelClick:(UITapGestureRecognizer *)gesture
{
    PhotoTableViewCell *cell;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8"))
    {
        cell = (PhotoTableViewCell *)[[[gesture.view superview]superview]superview];
    }
    else
    {
        cell = (PhotoTableViewCell *)[[[[gesture.view superview]superview]superview]superview];
    }
    NSIndexPath *selectItemIndexPath = [self.tableView indexPathForCell:cell];
    WhatsGoingOn *item = [self.dataSource objectAtIndex:selectItemIndexPath.row];
    UIStoryboard *addressStoryboard = [UIStoryboard storyboardWithName:@"Address" bundle:nil];
    AddressViewController *addressViewCon = [addressStoryboard instantiateViewControllerWithIdentifier:@"addressPage"];
    //[self hidesBottomBarWhenPushed];
    addressViewCon.poiId = item.poiId;
    addressViewCon.poiName = item.poiName;
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
    
    if (self.tableStyle == WZ_TABLEVIEWSTYLEHOME)
    {
        CGPoint loadMorePoint = CGPointMake(0, self.tableView.contentSize.height);
        CGPoint targetPoint = *targetContentOffset;
        float almostToBottomOffset = 90.0f;
        if (targetPoint.y > loadMorePoint.y - WZ_APP_SIZE.height + almostToBottomOffset)
        {
            [self performSelectorOnMainThread:@selector(loadMore:) withObject:self.loadMoreButton waitUntilDone:NO];
        }
    }
    
}

#pragma mark- Listen for the user to trigger a refresh

-(void)refreshByPullingTable:(id)sender
{
    if (self.dataSource.count>0)
    {
        if (self.shouldRefreshData)
        {
            [self.refreshControl beginRefreshing];
            [self GetLatestDataList];
        }
    }
    else
    {
        if ([self.refreshControl isRefreshing])
        {
            [self.refreshControl endRefreshing];
        }
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
        //[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
        self.shouldRefreshData = false;
        if (self.tableStyle == WZ_TABLEVIEWSTYLEHOME)
        {
            self.currentPage = 1;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [[QDYHTTPClient sharedInstance]GetWhatsGoingOnWithUserId:self.currentUser.UserID page:self.currentPage whenComplete:^(NSDictionary *result) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if ([result objectForKey:@"data"])
                     {
                         
                         self.dataSource = [result objectForKey:@"data"];
                         [self.tableView reloadData];
                         if (self.dataSource.count == 0)
                         {
                             [self addIntroductionButton];
                         }
                         else
                         {
                             if (self.introductionView)
                             {
                                 [self.introductionView removeFromSuperview];
                             }
                             [self addFooterLoadMore];
                         }
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
                 });

                    
                }];
            });

        }
        else if (self.tableStyle == WZ_TABLEVIEWSTYLEDETAIL)
        {
            self.currentPage = 1;
            WhatsGoingOn *item = [self.dataSource objectAtIndex:0];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [[QDYHTTPClient sharedInstance ]GetPhotoInfoWithPostId:item.postId userId:self.currentUser.UserID whenComplete:^(NSDictionary *result) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([result objectForKey:@"data"])
                        {
                            WhatsGoingOn *newItem = [result objectForKey:@"data"];
                            //[self.dataSource addObject:newItem];
                            self.dataSource = [NSMutableArray arrayWithObject:newItem];
                            [self.tableView reloadData];
                            //[self addFooterLoadMore];
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
                    });
                    
                }];
            });

        }
        else
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
    }
}
@end
