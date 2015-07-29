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

#import "RecommendUserTableViewCell.h"

#import "CommentTextView.h"
#import "progressImageView.h"

#import "UIViewController+HideBottomBar.h"

#import "UIImageView+WebCache.h"
#import "UIImageView+ChangeAppearance.h"
#import "UIButton+ChangeAppearance.h"
#import "UILabel+ChangeAppearance.h"

#import "PhotoCommon.h"

#import "PureLayout.h"

#import "SVProgressHUD.h"

#import "QDYHTTPClient.h"
#import "macro.h"
#import "UMSocial.h"

#define ONEPAGEITEMS 10
#define RecommendCellHeigh 100



@interface HomeTableViewController ()<UIActionSheetDelegate,UIAlertViewDelegate,CommentTextViewDelegate,UMSocialDataDelegate,UMSocialUIDelegate>
@property (nonatomic,strong) UIButton *loadMoreButton;
@property (nonatomic,strong) UIActivityIndicatorView *aiv;
@property (nonatomic,strong) UIActivityIndicatorView *refreshaiv;
//current page
@property (nonatomic,assign) NSInteger currentPage;

@property (nonatomic,strong) NSIndexPath *currentZanIndexPath;

@property (nonatomic,strong) NSIndexPath *currentCommentIndexPath;
@property (nonatomic,strong) NSIndexPath *currentDeleteIndexPath;

@property (nonatomic,strong) PhotoTableViewCell *prototypeCell;
@property (nonatomic,strong) UIView *introductionView;

@property (nonatomic, strong) UIScrollView *uploadPhotoIndicatorView;
@property (nonatomic, strong) NSMutableArray *uploadImageProgressViews;



@end

@implementation HomeTableViewController
static NSString *reuseIdentifier = @"HomeTableCell";

- (void)viewDidLoad {
    NSLog(@"table view did load");
    [super viewDidLoad];
    [self initNavigationItem];
    [self initTableView];
    
    //init flag
    self.shouldRefreshData = true;
    [self GetLatestDataList];
    
    //refresh control
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refreshByPullingTable:) forControlEvents:UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clearUserInfo) name:@"deleteUserInfo" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(beginUploadPhotos:) name:@"beginUploadPhotos" object:Nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(finishiIndicator:) name:@"uploadPhotoSuccess" object:nil];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(errorIndicator:) name:@"uploadPhotoFail" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideIndicator) name:@"uploadAllPhotosSuccess" object:nil];
}



-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"table view will appear");
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
    if (self.dataSource == nil)
    {
        [self GetLatestDataList];
    }
    //[[NSNotificationCenter defaultCenter]postNotificationName:@"showTabBar" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"table view will disappear");
    [super viewWillDisappear:animated];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)initTableView
{
    self.tableView.alwaysBounceVertical = YES;
    //[self.tableView setContentOffset:CGPointMake(0, -64)];
    [self.tableView registerNib:[UINib nibWithNibName:@"RecommendCell" bundle:nil] forCellReuseIdentifier:@"RecommendCell"];
}


-(void)initNavigationItem
{
    self.navigationController.navigationBarHidden = NO;
    if (self.tableStyle == WZ_TABLEVIEWSTYLE_HOME)
    {
        self.navigationItem.title = @"Place";
          self.navigationController.navigationItem.title = @"Place";
    }
    else
    {
        self.navigationItem.title = @"照片详情";
        self.navigationController.navigationItem.title = @"照片详情";
    }
    self.navigationController.navigationItem.hidesBackButton = YES;
    
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarItem;
    
    if (SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"7"))
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
        [self.tableView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    }
    
    _refreshaiv = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc]initWithCustomView:_refreshaiv];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    //[self.navigationItem.backBarButtonItem setTitle:@""];
}

-(User *)currentUser
{
    if (!_currentUser)
    {
        _currentUser = [[User alloc]init];
    }
    if ([[NSUserDefaults standardUserDefaults]integerForKey:@"userId"])
    {
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
        NSLog(@"get latest data list when call load data");
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
- (WhatsGoingOn *)getDataAtIndexPath:(NSIndexPath *)indexPath
{
    WhatsGoingOn *item;
    if (self.tableStyle == WZ_TABLEVIEWSTYLE_HOME && self.recommandDatasource != nil)
    {
        item = [self.dataSource objectAtIndex:indexPath.row-1];
    }
    else
    {
        item = [self.dataSource objectAtIndex:indexPath.row];
    }
    return item;
}

- (void)configureCell:(PhotoTableViewCell *)cell forContent:(WhatsGoingOn *)content atIndexPath:(NSIndexPath *)indexPath
{
    //配置评论样式
    [cell configureCellWithData:content parentController:self];
}
- (PhotoTableViewCell *)prototypeCell
{
    if (!_prototypeCell) {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    }
    
    return _prototypeCell;
}

-(float)caculateProtoCellHeightWithData:(WhatsGoingOn *)dataItem
{

    [self.prototypeCell configureCellWithData:dataItem parentController:self];
    float imageScrollHeight = self.prototypeCell.imagesContainerView.frame.size.height;
    float addressHeight = self.prototypeCell.addressLabelView.frame.size.height + self.prototypeCell.addressViewVerticalSpaceToUpView.constant;
    float descriptionHieght;
    CGSize descriptionSize = self.prototypeCell.descriptionTextView.frame.size;
    if (descriptionSize.height>0)
    {
        descriptionHieght = descriptionSize.height + 6.0f;
    }
    float commentViewHeight = 0;
    
    CGSize commentViewSize = self.prototypeCell.commentView.frame.size;
    if (commentViewSize.height>0)
    {
        commentViewHeight = commentViewSize.height;
    }
    float likeViewHeight = 0;
    if (dataItem.likeCount >0)
    {
        likeViewHeight = 36;
    }
    float basicheight = 48 + WZ_APP_SIZE.width + (12+24+12);
    float height = basicheight + imageScrollHeight + addressHeight + descriptionHieght+ commentViewHeight+likeViewHeight ;
     return (!isnan(height))?height:300;
}
-(float)caculateHeightAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableStyle !=WZ_TABLEVIEWSTYLE_HOME ||self.recommandDatasource == nil)
    {
        float height= 0;
        WhatsGoingOn *item = [self.dataSource objectAtIndex:indexPath.row];
        height = [self caculateProtoCellHeightWithData:item];
        
        return height;
    }
    else
    {
        if (indexPath.row > 0)
        {
            float height = 0;
            WhatsGoingOn *item = [self.dataSource objectAtIndex:indexPath.row-1];
            height = [self caculateProtoCellHeightWithData:item];
            return height;
        }
        else
        {
            return RecommendCellHeigh;
        }
    }
    return 300;
  
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"estimate height of tableview  at indexpath %@ %@",indexPath,self);
    float height = [self caculateHeightAtIndexPath:indexPath];
    NSLog(@"estimate height of tableview  at indexpath %@ %f",indexPath,height);
    return (!isnan(height))?height:UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   // NSLog(@" height of tableview  at indexpath %@ %@",indexPath,self);
    float height = [self caculateHeightAtIndexPath:indexPath];
    NSLog(@" height of tableview  at indexpath %@ %f",indexPath,height);
    return (!isnan(height))?height:UITableViewAutomaticDimension;
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
    NSLog(@"cell for row at indexpath");
    if (self.tableStyle !=WZ_TABLEVIEWSTYLE_HOME ||self.recommandDatasource == nil)
    {
        PhotoTableViewCell *cell;
        WhatsGoingOn *item = self.dataSource[indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        //各控件单击效果
        //点击头像，跳转个人主页
        
        [self configureCell:cell forContent:item atIndexPath:indexPath];
        [cell.imagesScrollView.panGestureRecognizer requireGestureRecognizerToFail:self.tableView.panGestureRecognizer];
       // [self.tableView.panGestureRecognizer requireGestureRecognizerToFail:cell.imagesScrollView.panGestureRecognizer];
        return cell;
    }
    else
    {
        if (indexPath.row != 0)
        {
            PhotoTableViewCell *cell;
            WhatsGoingOn *item = self.dataSource[indexPath.row-1];
            cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
            cell.content = nil;
            [self configureCell:cell forContent:item atIndexPath:indexPath];
            [cell.imagesScrollView.panGestureRecognizer requireGestureRecognizerToFail:self.tableView.panGestureRecognizer];
            return cell;
        }
        else
        {
            RecommendUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecommendCell" forIndexPath:indexPath];
            [cell configWithUser:[self.recommandDatasource objectAtIndex:indexPath.row]];
            UITapGestureRecognizer *avatarClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(recommendUserAvatarClick)];
            [cell.avatorImageView addGestureRecognizer:avatarClick];
            [cell.avatorImageView setUserInteractionEnabled:YES];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }

    return nil;
}


#pragma mark - gesture action
-(void)recommendUserAvatarClick
{
    User *user = self.recommandDatasource[0];
    [self goToPersonalPageWithUserInfo:user];
}

-(void)searchAndAddButtonClick:(UIButton *)sender
{
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"activeTargetTab" object:self userInfo:@{@"index":@1}];
}
-(void)postMyFirstPhotoButtonClick:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"activeTargetTab" object:self userInfo:@{@"index":@2}];
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
    WhatsGoingOn *item = [self getDataAtIndexPath:selectItemIndexPath];
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
    WhatsGoingOn *item = [self getDataAtIndexPath:selectItemIndexPath];
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
    WhatsGoingOn *item = [self getDataAtIndexPath:selectItemIndexPath];
    [self goToPersonalPageWithUserInfo:item.likeUserList[likeUserIndex]];
    
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
    WhatsGoingOn *item = [self getDataAtIndexPath:selectItemIndexPath];
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
                                         if(self.tableStyle == WZ_TABLEVIEWSTYLE_HOME)
                                         {
                                             [self.tableView beginUpdates];
                                             if (self.recommandDatasource == nil)
                                             {
                                             [self.dataSource removeObjectAtIndex:selectItemIndexPath.row];
                                             }
                                             else
                                             {
                                                 [self.dataSource removeObjectAtIndex:selectItemIndexPath.row -1];
                                             }
                                             [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject: selectItemIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
                                             [self.tableView endUpdates];
                                         }
                                         else if (self.tableStyle == WZ_TABLEVIEWSTYLE_DETAIL)
                                         {
                                             [[NSNotificationCenter defaultCenter]postNotificationName:@"deletePost" object:nil userInfo:@{@"postId":[NSNumber numberWithInteger:item.postId]}];
                                             [self.navigationController popViewControllerAnimated:YES];
                                         }
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
          
            UIAlertAction *shareAction = [UIAlertAction actionWithTitle:@"分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSString *shareText = item.imageDescription;
                UIImage *shareImage = cell.homeCellImageView.image;
                NSString *shareUrl =[NSString stringWithFormat:@"http://placeapp.cn/post/detail?postid=%ld",(long)item.postId];
                [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
                
                [UMSocialData defaultData].extConfig.qqData.title = @"来自Place的分享";
                [UMSocialData defaultData].extConfig.qzoneData.title = @"来自Place的分享";
                [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
                [UMSocialData defaultData].extConfig.qzoneData.url = shareUrl;
                [UMSocialData defaultData].extConfig.qqData.url = shareUrl;
                
                [UMSocialSnsService presentSnsIconSheetView:self
                                                     appKey:nil
                                                  shareText:shareText
                                                 shareImage:shareImage
                                            shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToWechatFavorite,UMShareToQQ,UMShareToEmail,nil]
                                                   delegate:self];
            
                
            }];
            [alertController addAction:shareAction];
            [alertController addAction:delectAction];
        }
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
    [self pushToViewController:personalViewCon animated:YES hideBottomBar:YES];
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
            WhatsGoingOn *item = [self getDataAtIndexPath:self.currentDeleteIndexPath];
            [[QDYHTTPClient sharedInstance]deletePhotoWithUserId:self.currentUser.UserID postId:item
             .postId whenComplete:^(NSDictionary *returnData)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if ([returnData objectForKey:@"data"])
                     {
                         [self.tableView beginUpdates];
                         if (self.tableStyle == WZ_TABLEVIEWSTYLE_HOME && self.recommandDatasource != nil)
                         {
                             [self.dataSource removeObjectAtIndex:self.currentDeleteIndexPath.row-1];
                         }
                         else
                         {
                             [self.dataSource removeObjectAtIndex:self.currentDeleteIndexPath.row];
                             
                         }
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
    WhatsGoingOn *item = [self getDataAtIndexPath:selectItemIndexPath];
    if ([cell.zanClickButton.currentTitle isEqualToString:@"赞"])
    {
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
            
        }
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[QDYHTTPClient sharedInstance]ZanPhotoWithUserId:self.currentUser.UserID postId:item.postId whenComplete:^(NSDictionary *returnData) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([returnData objectForKey:@"data"])
                    {
                        NSLog(@"zan success");
                    }
                    else
                    {
                        NSLog(@"zan failed");
                        // [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
                    }
                    
                });
            }];
        });
        
        // [cell.zanClickButton setTitle:@"已赞" forState:UIControlStateNormal];
        
    }
    else if ([cell.zanClickButton.currentTitle isEqualToString:@"赞了"])
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
        }
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[QDYHTTPClient sharedInstance]CancelZanPhotoWithUserId:self.currentUser.UserID postId:item.postId whenComplete:^(NSDictionary *returnData) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([returnData objectForKey:@"data"])
                    {
                        NSLog(@"cancel zan success");
                    }
                    else
                    {
                        NSLog(@"cancel zan failed");
                        //[SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
                    }
                });
                
            }];
        });
        //  [cell.zanClickButton setTitle:@"赞" forState:UIControlStateNormal];
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
    WhatsGoingOn *item = [self getDataAtIndexPath:selectItemIndexPath];
    CommentListViewController *commentListView = [[CommentListViewController alloc]init];
    commentListView.poiItem = item;
    commentListView.isKeyboardShowWhenLoadView = YES;
    [self pushToViewController:commentListView animated:YES hideBottomBar:YES];
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
    NSIndexPath *selectItemIndexPath = [self.tableView indexPathForCell:cell];
    WhatsGoingOn *item = [self getDataAtIndexPath:selectItemIndexPath];
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
                    [followsList setHidesBottomBarWhenPushed:YES];
                    [self pushToViewController:followsList animated:YES hideBottomBar:YES];
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
    WhatsGoingOn *item = [self getDataAtIndexPath:selectItemIndexPath];
    UIStoryboard *addressStoryboard = [UIStoryboard storyboardWithName:@"Address" bundle:nil];
    AddressViewController *addressViewCon = [addressStoryboard instantiateViewControllerWithIdentifier:@"addressPage"];
    //[self hidesBottomBarWhenPushed];
    addressViewCon.poiId = item.poiId;
    addressViewCon.poiName = item.poiName;
    [self pushToViewController:addressViewCon animated:YES hideBottomBar:YES];
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
    
    if (self.tableStyle == WZ_TABLEVIEWSTYLE_HOME)
    {
        CGPoint loadMorePoint = CGPointMake(0, self.tableView.contentSize.height);
        CGPoint targetPoint = *targetContentOffset;
        float almostToBottomOffset = 0.0f;
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
            
            NSLog(@"get latest data list when pull to refresh");
            [self GetLatestDataList];
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

-(void)getRecommandUser
{
    [[QDYHTTPClient sharedInstance]GetRecommendUserListWhenComplete:^(NSDictionary *result) {
        if ([result objectForKey:@"data"])
        {
            self.recommandDatasource  = [result objectForKey:@"data"];
        }
        else if ([result objectForKey:@"error"])
        {
            //获取推荐用户失败
        }
    }];
}
-(void)GetLatestDataListWithAnimation
{
    [self.refreshControl beginRefreshing];
    double delayInseconds = 1;
    dispatch_time_t popTime =  dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInseconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [self GetLatestDataList];
        
        
    });
   
    
}

-(void)GetLatestDataList
{
    //[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    if (self.shouldRefreshData == false)
    {
        return;
    }
    self.shouldRefreshData = false;
    if (![self.refreshControl isRefreshing])
    {
        [self.tableView setContentOffset:CGPointMake(0, -64) animated:YES];
    }
    if (self.tableStyle == WZ_TABLEVIEWSTYLE_HOME)
    {
        self.recommandDatasource = nil;
        [self getRecommandUser];
        self.currentPage = 1;
        [self startAiv];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[QDYHTTPClient sharedInstance]GetWhatsGoingOnWithUserId:self.currentUser.UserID page:self.currentPage whenComplete:^(NSDictionary *result) {
             self.shouldRefreshData = true;
            [self stopAiv];
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
                 [self.tableView setContentOffset:CGPointMake(0, -64) animated:YES];
                 //[[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
             });

                
            }];
        });

    }
    else if (self.tableStyle == WZ_TABLEVIEWSTYLE_DETAIL)
    {
        self.currentPage = 1;
        WhatsGoingOn *item = [self.dataSource objectAtIndex:0];
        [self startAiv];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[QDYHTTPClient sharedInstance ]GetPhotoInfoWithPostId:item.postId userId:self.currentUser.UserID whenComplete:^(NSDictionary *result) {
                  self.shouldRefreshData = true;
                [self stopAiv];
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
                     [self.tableView setContentOffset:CGPointMake(0, -64) animated:NO];
                    
                  
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
                 [self.tableView setContentOffset:CGPointMake(0, -64) animated:YES];
                
            });
        }
    }
    
    
}

#pragma mark - commentTextView Delegate
-(void)commentTextView:(CommentTextView *)commentTextView didClickLinkUser:(User *)user
{
    [self goToPersonalPageWithUserInfo:user];
}

-(void)moreCommentClick:(CommentTextView *)commentTextView
{
    PhotoTableViewCell * cell ;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8"))
    {
        cell = (PhotoTableViewCell *)[[commentTextView superview]superview];
    }
    else
    {
        cell = (PhotoTableViewCell *)[[[commentTextView superview]superview]superview];
    }
    NSIndexPath *selectItemIndexPath = [self.tableView indexPathForCell:cell];
    self.currentCommentIndexPath = selectItemIndexPath;
    WhatsGoingOn *item = [self getDataAtIndexPath:selectItemIndexPath];
    CommentListViewController *commentListView = [[CommentListViewController alloc]init];
    [commentListView setPoiItem:item];
    [self pushToViewController:commentListView animated:YES hideBottomBar:YES];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch in the home table view");
    
}



#pragma mark - notification action
-(void)clearUserInfo
{
    self.currentUser = nil;
    self.dataSource = nil;
    [self.tableView reloadData];
    
}

-(void)beginUploadPhotos:(NSNotification *)notification
{
    NSArray *photos =  [[notification userInfo] objectForKey:@"photos"];
    [self showIndicator:photos];
}

-(void)finishiIndicator:(NSNotification *)notification
{
    
    NSInteger index = [[[notification userInfo] objectForKey:@"photoIndex"]integerValue];
    progressImageView *imageView = self.uploadImageProgressViews[index];
    [imageView setfinishState];
     
}

-(void)errorIndicator:(NSNotification *)notification
{
    
    NSInteger index = [[[notification userInfo] objectForKey:@"photoIndex"]integerValue];
    progressImageView *imageView = self.uploadImageProgressViews[index];
    [imageView setErrorState];
    
}

#pragma mark - uploadNewPhotoIndicator
-(void)showIndicator:(NSArray *)photos
{
    float imageWidth = 48;
    float spacing =8;
    self.uploadPhotoIndicatorView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, WZ_APP_SIZE.width, 64)];
    self.uploadPhotoIndicatorView.backgroundColor = [UIColor whiteColor];
    self.uploadPhotoIndicatorView.contentSize = CGSizeMake(spacing +(imageWidth+spacing)*photos.count, 64);
    [PhotoCommon drawALineWithFrame:CGRectMake(0, self.uploadPhotoIndicatorView.frame.size.height-0.5f, WZ_APP_SIZE.width, 0.5f) andColor:THEME_COLOR_LIGHT_GREY_PARENT inLayer:self.uploadPhotoIndicatorView.layer];
    self.uploadImageProgressViews = [[NSMutableArray alloc]init];
    [photos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        progressImageView *imageView = [[progressImageView alloc]initWithFrame:CGRectMake(spacing +idx*(imageWidth+spacing), spacing, imageWidth, imageWidth)];
        [self.uploadPhotoIndicatorView addSubview:imageView];
        imageView.image = obj;
        [self.uploadImageProgressViews addObject:imageView];
    }];
    self.tableView.tableHeaderView = self.uploadPhotoIndicatorView;
    //[self.view addSubview:self.uploadPhotoIndicatorView];
}

-(void)hideIndicator
{
    CGRect rect = CGRectMake(0, -64, WZ_APP_SIZE.width, 64);
    
    [UIView animateWithDuration:0.3 delay:2.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.uploadPhotoIndicatorView.frame = rect;
        
    } completion:^(BOOL finished) {
        [self.uploadImageProgressViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj removeFromSuperview];
        }];
        [self.uploadPhotoIndicatorView removeFromSuperview];
        self.tableView.tableHeaderView = nil;
        NSLog(@"get latest data list when finish upload photos");
        [self GetLatestDataList];
        
    }];
}

-(void)updateIndicatorAtIndex:(NSInteger)index withProcess:(float)process
{
    progressImageView *imageView = self.uploadImageProgressViews[index];
    [imageView setProgress:process];
}

-(void)startAiv
{
    [_refreshaiv startAnimating];
}
-(void)stopAiv
{
    if (_refreshaiv)
    {
        if ([_refreshaiv isAnimating])
        {
            [_refreshaiv stopAnimating];
        }
    }
}

#pragma mark - UMSocialData delegate
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}




@end
