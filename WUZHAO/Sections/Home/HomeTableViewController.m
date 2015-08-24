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
#import "UploadPhotoIndicatorView.h"

#import "UIViewController+Basic.h"

#import "UIImageView+WebCache.h"
#import "UIImageView+ChangeAppearance.h"
#import "UIButton+ChangeAppearance.h"
#import "UILabel+ChangeAppearance.h"

#import "VoteAlertView.h"

#import "PhotoCommon.h"

#import "PureLayout.h"

#import "SVProgressHUD.h"

#import "QDYHTTPClient.h"
#import "macro.h"
#import "UMSocial.h"
#import "QiniuSDK.h"

#define ONEPAGEITEMS 10
#define RecommendCellHeigh 100



@interface HomeTableViewController ()<UIActionSheetDelegate,UIAlertViewDelegate,CommentTextViewDelegate,UMSocialDataDelegate,UMSocialUIDelegate>

//current page
@property (nonatomic,assign) NSInteger currentPage;

@property (nonatomic,strong) NSIndexPath *currentZanIndexPath;

@property (nonatomic,strong) NSIndexPath *currentCommentIndexPath;
@property (nonatomic,strong) NSIndexPath *currentDeleteIndexPath;

@property (nonatomic,strong) PhotoTableViewCell *prototypeCell;
@property (nonatomic,strong) UIView *introductionView;


@property (nonatomic, strong) UIView *uploadPhotoIndicatorViewContainer;
@property (nonatomic, strong) NSMutableArray *uploadPhotoIndicatorViews;
@property (nonatomic, strong) NSMutableArray *uploadPhotoInfos;
@property (nonatomic, strong) UploadPhotoIndicatorView *uploadPhotoIndicatorView;

@end

@implementation HomeTableViewController
static NSString *reuseIdentifier = @"HomeTableCell";
@dynamic refreshControl;

-(instancetype)init
{
    self = [super init];
    if (self)
    {

    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {

    }
    return self;
}
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad {
    NSLog(@"table view did load");
    [super viewDidLoad];
    [self initNavigationItem];
    [self initTableView];
    
    //init flag
    if (self.tableStyle == WZ_TABLEVIEWSTYLE_HOME || self.tableStyle == WZ_TABLEVIEWSTYLE_SUGGEST)
    {
        self.shouldLoadMore = YES;
    }
    self.shouldRefreshData = YES;
    [self getLatestDataAnimated];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clearUserInfo) name:@"deleteUserInfo" object:nil];
    if (self.tableStyle == WZ_TABLEVIEWSTYLE_HOME)
    {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(beginUploadPhotos:) name:@"beginShowUploadIndicator" object:Nil];
    }

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
    if (self.datasource == nil || self.datasource.count == 0)
    {
        [self getLatestDataAnimated];
    }
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

-(UIView *)uploadPhotoIndicatorViewContainer
{
    if (!_uploadPhotoIndicatorViewContainer)
    {
        _uploadPhotoIndicatorViewContainer = [[UIView alloc]init];
    }
    return _uploadPhotoIndicatorViewContainer;
}
-(NSMutableArray *)uploadPhotoIndicatorViews
{
    if (!_uploadPhotoIndicatorViews)
    {
        _uploadPhotoIndicatorViews = [[NSMutableArray alloc]init];
    }
    return _uploadPhotoIndicatorViews;
}
-(NSMutableArray *)uploadPhotoInfos
{
    if (!_uploadPhotoInfos)
    {
        _uploadPhotoInfos = [[NSMutableArray alloc]init];
    }
    return _uploadPhotoInfos;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)initTableView
{
    self.tableView.alwaysBounceVertical = YES;
    [self.tableView registerNib:[UINib nibWithNibName:@"RecommendCell" bundle:nil] forCellReuseIdentifier:@"RecommendCell"];
    [self setupRefreshControl];
}


-(void)initNavigationItem
{
    self.navigationController.navigationBarHidden = NO;
    if (self.tableStyle == WZ_TABLEVIEWSTYLE_HOME)
    {
        self.navigationItem.title = @"Place";
        self.navigationController.navigationItem.title = @"Place";
    }
    else if (self.tableStyle == WZ_TABLEVIEWSTYLE_SUGGEST)
    {
        self.navigationController.navigationItem.title = @"精选";
        self.navigationItem.title = @"精选";
    }
    else if (self.tableStyle == WZ_TABLEVIEWSTYLE_DETAIL)
    {
        self.navigationItem.title = @"照片详情";
        self.navigationController.navigationItem.title = @"照片详情";
    }
    self.navigationController.navigationItem.hidesBackButton = YES;

    [self setupRightBarRefreshAiv];
    
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

-(void)loadData
{
    [self.tableView reloadData];
    if (self.tableStyle == WZ_TABLEVIEWSTYLE_HOME || self.tableStyle == WZ_TABLEVIEWSTYLE_SUGGEST)
    {
        [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    else if (self.tableStyle == WZ_TABLEVIEWSTYLE_DETAIL)
    {
        [self.tableView setContentOffset:CGPointMake(0, -64) animated:YES];
    }
    [self setupLoadMore];
}

#pragma mark - tableview delegate
- (WhatsGoingOn *)getDataAtIndexPath:(NSIndexPath *)indexPath
{
     WhatsGoingOn *item;
    if (indexPath.section == 1)
    {
        item = [self.datasource objectAtIndex:indexPath.row];
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
    return height;
}
-(float)caculateHeightAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return RecommendCellHeigh;
    }
    else
    {
        float height= 0;
        WhatsGoingOn *item = [self.datasource objectAtIndex:indexPath.row];
        height = [self caculateProtoCellHeightWithData:item];
        return height;
    }
   
  
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0)
    {
        return self.recommandDatasource.count;
    }
    else
    {
        return [self.datasource count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cell for row at indexpath");
    
    if (indexPath.section == 1)
    {
        PhotoTableViewCell *cell;
        WhatsGoingOn *item = self.datasource[indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        //各控件单击效果
        //点击头像，跳转个人主页
        
        [self configureCell:cell forContent:item atIndexPath:indexPath];
        [self.tableView.panGestureRecognizer requireGestureRecognizerToFail:cell.imagesCollectionView.panGestureRecognizer];
        if (self.tableView.superview && [self.tableView.superview isKindOfClass:[UIScrollView class]])
        {
            UIScrollView *parentView =(UIScrollView *) self.tableView.superview;
            [parentView.panGestureRecognizer requireGestureRecognizerToFail:cell.imagesCollectionView.panGestureRecognizer];
        }
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
                                             [self.datasource removeObjectAtIndex:selectItemIndexPath.row];
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
                             [self.datasource removeObjectAtIndex:self.currentDeleteIndexPath.row];
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
    POI *poi = [[POI alloc]init];
    poi.poiId = item.poiId;
    poi.name = item.poiName;
    [self goToPOIPhotoListWithPoi:poi];
}
#pragma mark - control the model

-(void)getRecommandUser
{
    [[QDYHTTPClient sharedInstance]GetRecommendUserListWhenComplete:^(NSDictionary *result) {
        if ([result objectForKey:@"data"])
        {
            self.recommandDatasource  = [result objectForKey:@"data"];
            NSIndexSet *set = [NSIndexSet indexSetWithIndex:0];
            [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else if ([result objectForKey:@"error"])
        {
            //获取推荐用户失败
        }
    }];
}

-(void)getLatestData
{
    if([[NSUserDefaults standardUserDefaults]integerForKey:@"userId"]<=0)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"logOut" object:nil];
        return;
    }
    if (self.shouldRefreshData == NO)
    {
        return;
    }
    self.shouldRefreshData = NO;
    if (self.tableStyle == WZ_TABLEVIEWSTYLE_HOME)
    {
        self.recommandDatasource = nil;
        [self getRecommandUser];
        self.currentPage = 1;
        [self starRightBartAiv];
        [[QDYHTTPClient sharedInstance]GetWhatsGoingOnWithUserId:self.currentUser.UserID page:self.currentPage whenComplete:^(NSDictionary *result) {
         self.shouldRefreshData = YES;
        [self stopRightBarAiv];
         if ([result objectForKey:@"data"] )
         {
             self.datasource = [result objectForKey:@"data"];
             if (self.datasource.count == 0)
             {
                 //[self addIntroductionButton];
                 self.datasource = [[NSMutableArray alloc]initWithArray:@[]];
             }
             else
             {
                 /*
                 if (self.introductionView)
                 {
                     [self.introductionView removeFromSuperview];
                 }*/
             }
             [self loadData];
         }
         else if ([result objectForKey:@"error"])
         {
             [SVProgressHUD showErrorWithStatus:[result objectForKey:@"error"]];
         }
         [self endRefreshing];
        }];

    }
    else if (self.tableStyle == WZ_TABLEVIEWSTYLE_SUGGEST)
    {
        self.recommandDatasource = nil;
        self.currentPage = 1;
        [self starRightBartAiv];
        [[QDYHTTPClient sharedInstance]GetHomeRecommendListWithPageNum:self.currentPage whenComplete:^(NSDictionary *result) {
            self.shouldRefreshData = YES;
            [self stopRightBarAiv];
            if ([result objectForKey:@"data"] )
            {
                
                self.datasource = [result objectForKey:@"data"];
                if (self.datasource.count == 0)
                {
                    self.datasource = [[NSMutableArray alloc]initWithArray:@[]];
                }
                else
                {
                    
                }
                [self loadData];
            }
            else if ([result objectForKey:@"error"])
            {
                [SVProgressHUD showErrorWithStatus:[result objectForKey:@"error"]];
            }
            [self endRefreshing];
        }];
        
    }

    else if (self.tableStyle == WZ_TABLEVIEWSTYLE_DETAIL)
    {
        self.currentPage = 1;
        WhatsGoingOn *item = [self.datasource objectAtIndex:0];
        [self starRightBartAiv];
        [[QDYHTTPClient sharedInstance ]GetPhotoInfoWithPostId:item.postId userId:self.currentUser.UserID whenComplete:^(NSDictionary *result) {
              self.shouldRefreshData = true;
            [self stopRightBarAiv];
            if ([result objectForKey:@"data"])
            {
                WhatsGoingOn *newItem = [result objectForKey:@"data"];
                self.datasource = [NSMutableArray arrayWithObject:newItem];
                [self.tableView reloadData];
            }
            else if ([result objectForKey:@"error"])
            {
                [SVProgressHUD showErrorWithStatus:[result objectForKey:@"error"]];
            }
            [self.tableView setContentOffset:CGPointMake(0, -64) animated:NO];

          [self endRefreshing];
        }];

    }
    

}
-(void)loadMore
{
    //get new page data;
    [self.loadMoreAiv startAnimating];
    [self.loadMoreButton setHidden:YES];
    if (self.tableStyle == WZ_TABLEVIEWSTYLE_HOME)
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[QDYHTTPClient sharedInstance]GetWhatsGoingOnWithUserId:self.currentUser.UserID page:self.currentPage+1 whenComplete:^(NSDictionary *result) {
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
                            [self.datasource addObjectsFromArray:newData];
                            [self.tableView reloadData];
                            self.currentPage +=1;
                        }
                        
                    }
                    else if ([result objectForKey:@"error"])
                    {
                        [self.loadMoreButton setTitle:@"加载失败" forState:UIControlStateNormal];
                    }
                    [self.loadMoreAiv stopAnimating];
                    [self.loadMoreButton setHidden:NO];
                });
                
            }];
        });
    }
    else if (self.tableStyle == WZ_TABLEVIEWSTYLE_SUGGEST)
    {
        //TO DO
        //load more of the suggest page
        [[QDYHTTPClient sharedInstance]GetHomeRecommendListWithPageNum:self.currentPage +1 whenComplete:^(NSDictionary *returnData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([returnData objectForKey:@"data"])
                {
                    NSMutableArray *newData = [returnData objectForKey:@"data"];
                    if (newData.count ==0)
                    {
                        [self.loadMoreButton setTitle:@"没有更多数据了" forState:UIControlStateNormal];
                    }
                    else
                    {
                        [self.datasource addObjectsFromArray:newData];
                        [self.tableView reloadData];
                        self.currentPage +=1;
                    }
                    
                }
                else if ([returnData objectForKey:@"error"])
                {
                    [self.loadMoreButton setTitle:@"加载失败" forState:UIControlStateNormal];
                }
                [self.loadMoreAiv stopAnimating];
                [self.loadMoreButton setHidden:NO];
            });

        }];
        
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
-(void)didClickUnlinedTextOncommentTextView:(CommentTextView *)commentTextView
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
    commentListView.isKeyboardShowWhenLoadView = YES;
    [self pushToViewController:commentListView animated:YES hideBottomBar:YES];
}
#pragma mark - notification action
-(void)clearUserInfo
{
    self.currentUser = nil;
    self.datasource = [[NSMutableArray alloc]initWithArray:@[]];
    self.recommandDatasource = [[NSMutableArray alloc]initWithArray:@[]];
    /*
    if (self.introductionView)
    {
        [self.introductionView removeFromSuperview];
    }*/
    self.uploadPhotoInfos = nil;
    self.uploadPhotoIndicatorViewContainer = nil;
    [self loadData];
    
}

-(void)beginUploadPhotos:(NSNotification *)notification
{
    //初始化上传数据
    NSMutableDictionary *uploadInfo = [[NSMutableDictionary alloc]init];
    NSMutableArray *imagesAndInfo = [[notification userInfo]objectForKey:@"imagesAndInfo"];
    [imagesAndInfo enumerateObjectsUsingBlock:^(NSMutableDictionary *imageInfo, NSUInteger idx, BOOL *stop) {
        NSData *photoData = [PhotoCommon setImageInfo:[imageInfo objectForKey:@"imageInfo"] image:[imageInfo objectForKey:@"image"] scale:0.7f];
        [imageInfo setObject:photoData forKey:@"photoData"];
    }];
    [uploadInfo setObject:imagesAndInfo forKey:@"imagesAndInfo"];
    [uploadInfo setObject:[[notification userInfo]objectForKey:@"photoDescription"] forKey:@"photoDescription"];
    [uploadInfo setObject:[[notification userInfo]objectForKey:@"poiInfo"] forKey:@"poiInfo"];
    [uploadInfo setObject:@0 forKey:@"successNum"];
    [uploadInfo setObject:@"NO" forKey:@"isUploading"];
    [self.uploadPhotoInfos addObject:uploadInfo];

    //初始化界面
    UploadPhotoIndicatorView *indicatorView = [[UploadPhotoIndicatorView alloc]init];
    [indicatorView.imageView setImage:[imagesAndInfo[0] objectForKey:@"image"]];
    
    [indicatorView setStatus:UPLOAD_STATUS_UPLOADING withInfo:[NSString stringWithFormat:@"照片上传中，正在上传 1/%ld",(long)imagesAndInfo.count]];
    [indicatorView.deleteButton setEnabled:YES];
    [indicatorView.deleteButton addTarget:self action:@selector(deleteIndicator:) forControlEvents:UIControlEventTouchUpInside];
    [indicatorView.reloadButton setEnabled:YES];
    [indicatorView.reloadButton addTarget:self action:@selector(reuploadPhotos:) forControlEvents:UIControlEventTouchUpInside];
    [uploadInfo setObject:indicatorView forKey:@"indicatorView"];
    
    //界面显示
    [self.uploadPhotoIndicatorViews addObject:indicatorView];
    [self updateIndicatorView];
    
    //正式开始上传
    [self uploadPhotos:uploadInfo];
    
}

-(void)successIndicator:(NSMutableDictionary *)photosInfo
{
    NSInteger successNum = [[photosInfo objectForKey:@"successNum"]integerValue];
    NSArray *imagesAndInfo = [photosInfo objectForKey:@"imagesAndInfo"];
    successNum += 1;
    [photosInfo setObject:@(successNum) forKey:@"successNum"];
    UploadPhotoIndicatorView *indicatorView = [photosInfo objectForKey:@"indicatorView"];
    if (successNum + 1<=imagesAndInfo.count)
    {
        [indicatorView setStatus:UPLOAD_STATUS_UPLOADING withInfo:[NSString stringWithFormat:@"照片上传中，正在上传 %ld/%ld",(long)successNum+1,(long)imagesAndInfo.count]];
    }
}

-(void)finishiIndicator:(NSMutableDictionary *)photosInfo
{
    
    [photosInfo setObject:@"NO" forKey:@"isUploading"];
    NSInteger successNum = [[photosInfo objectForKey:@"successNum"]integerValue];
    NSArray *imagesAndInfo = [photosInfo objectForKey:@"imagesAndInfo"];
    UploadPhotoIndicatorView *indicatorView = [photosInfo objectForKey:@"indicatorView"];
    if (successNum == imagesAndInfo.count)
    {

        [self uploadPhotoInfosToServer:photosInfo];
    }
    else
    {
        NSInteger failedCount = imagesAndInfo.count - successNum;
        
        [indicatorView setStatus:UPLOAD_STATUS_UPLOAD_FAILED withInfo:[NSString stringWithFormat:@"%ld张照片上传失败",(long)failedCount]];
    }
}
-(void)deleteIndicator:(UIButton *)sender
{
    UploadPhotoIndicatorView *indicatorView = (UploadPhotoIndicatorView *)sender.superview;
    [self.uploadPhotoInfos enumerateObjectsUsingBlock:^(NSDictionary *photosInfo, NSUInteger idx, BOOL *stop) {
        if ([[photosInfo objectForKey:@"indicatorView"] isEqual:indicatorView])
        {
            [self.uploadPhotoInfos removeObject:photosInfo];
            [self hideIndicator:indicatorView WithDelay:0.0 ReloadData:NO];
            *stop = YES;
        }
    }];
    
}
-(void)reuploadPhotos:(UIButton *)sender
{
    UploadPhotoIndicatorView *indicatorView = (UploadPhotoIndicatorView *)sender.superview;
    [self.uploadPhotoInfos enumerateObjectsUsingBlock:^(NSMutableDictionary *photosInfo, NSUInteger idx, BOOL *stop) {
        if ([[photosInfo objectForKey:@"indicatorView"] isEqual:indicatorView])
        {
            [self uploadPhotos:photosInfo];
        }
    }];
    
}
-(void)uploadPhotos:(NSMutableDictionary *)photosInfo
{
    if ([[photosInfo objectForKey:@"isUploading"]isEqualToString:@"YES"])
        return;
    [photosInfo setValue:@"YES" forKey:@"isUploading"];
    
    NSMutableArray *imagesAndInfo = [photosInfo objectForKey:@"imagesAndInfo"];
    UploadPhotoIndicatorView *indicatorView = [photosInfo objectForKey:@"indicatorView"];
    NSInteger successNum = [[photosInfo objectForKey:@"successNum"]integerValue];
    if (successNum <= imagesAndInfo.count)
    {
        [indicatorView setStatus:UPLOAD_STATUS_UPLOADING withInfo:[NSString stringWithFormat:@"照片上传中，正在上传 %ld/%ld",(long)successNum+1,(long)imagesAndInfo.count]];
    }
    else
    {
        [indicatorView setStatus:UPLOAD_STATUS_UPLOADING withInfo:[NSString stringWithFormat:@"照片上传中，正在上传 %ld/%ld",(long)successNum,(long)imagesAndInfo.count]];
    }
    
    //begin upload
     __block NSInteger photoNum  = 0;
    NSInteger totalReuploadNum = imagesAndInfo.count - successNum;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [imagesAndInfo enumerateObjectsUsingBlock:^(NSDictionary *imageInfo, NSUInteger idx, BOOL *stop) {
            //还未上传或者上传失败状态
        if ( (![imageInfo objectForKey:@"success"]) || [[imageInfo objectForKey:@"success"]isEqualToString:@"NO"])
        {
            NSData *photoData = [imageInfo objectForKey:@"photoData"];
            if (!photoData)
            {
                photoData = [PhotoCommon setImageInfo:[imageInfo objectForKey:@"imageInfo"] image:[imageInfo objectForKey:@"image"] scale:0.7f];
            }
            NSInteger userId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
            [[QDYHTTPClient sharedInstance] GetQiNiuTokenWithUserId:userId type:1 whenComplete:^(NSDictionary *result) {
                NSDictionary *data;
                if ([result objectForKey:@"data"])
                {
                    data = [result objectForKey:@"data"];
                }
                else
                {
                    //获取token失败
                    dispatch_async(dispatch_get_main_queue(), ^{
                        photoNum ++;
                        [SVProgressHUD showErrorWithStatus:@"照片上传失败,请检查网络设置"];
                        [imageInfo setValue:@"NO" forKey:@"success"];
                        if (photoNum == totalReuploadNum)
                        {
                            [self finishiIndicator:photosInfo];
                        }
                    });
                    return ;
                }
                //获取token成功，继续上传逻辑
                QNUploadManager *upLoadManager = [[QNUploadManager alloc]init];
                NSString *dataName ;
                if ([imageInfo objectForKey:@"imageName"])
                {
                    dataName = [imageInfo objectForKey:@"imageName"];
                }
                else
                {
                    dataName = [data objectForKey:@"imageName"];
                }
                [imageInfo setValue:dataName forKey:@"imageName"];
                [upLoadManager putData:photoData key:[imageInfo objectForKey:@"imageName"] token:[data objectForKey:@"uploadToken"] complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp)
                 {
                     if (info.error)
                     {
                        dispatch_async(dispatch_get_main_queue(), ^{
                             //一张图片上传失败
                            photoNum ++;
                            [imageInfo setValue:@"NO" forKey:@"success"];
                            //已上传完所有图片
                            if (photoNum == totalReuploadNum)
                            {
                                [self finishiIndicator:photosInfo];
                            }
                        });
                     }
                     else
                     {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //一张图片上传成功
                            photoNum ++;
                            [imageInfo setValue:@"YES" forKey:@"success"];
                            [self successIndicator:photosInfo];
                            //已上传完所有图片
                            if (photoNum == totalReuploadNum)
                            {
                                [self finishiIndicator:photosInfo];
                            }
                        });
                     }
                 } option:nil];
            }];

        }
        }];
    });
}

#pragma mark - uploadNewPhotoIndicator
-(void)updateIndicatorView
{
    float indicatorViewHeight = 64;
    [self.uploadPhotoIndicatorViewContainer setFrame:CGRectMake(0, 0, WZ_APP_SIZE.width, self.uploadPhotoIndicatorViews.count * indicatorViewHeight)];
    
    [self.uploadPhotoIndicatorViewContainer.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UploadPhotoIndicatorView class]])
        {
            [obj removeFromSuperview];
        }
    }];
    
    if (self.uploadPhotoIndicatorViews.count == 0)
    {
        self.tableView.tableHeaderView = nil;
        return;
    }
    [self.uploadPhotoIndicatorViews enumerateObjectsUsingBlock:^(UploadPhotoIndicatorView *indicatorView, NSUInteger idx, BOOL *stop) {
        [indicatorView setFrame:CGRectMake(0, indicatorViewHeight*idx, WZ_APP_SIZE.width, indicatorViewHeight)];
        [self.uploadPhotoIndicatorViewContainer addSubview:indicatorView];
        
    }];
    self.tableView.tableHeaderView = self.uploadPhotoIndicatorViewContainer;
    //[self.view addSubview:self.uploadPhotoIndicatorView];
}

-(void)hideIndicator:(UploadPhotoIndicatorView *)indicatorView WithDelay:(float)delayTime ReloadData:(BOOL)reload
{
    CGRect frame = indicatorView.frame;
    [UIView animateWithDuration:0.3 delay:delayTime options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        indicatorView.transform  = CGAffineTransformMakeTranslation(frame.size.width*-1, 0);
    } completion:^(BOOL finished) {
        [self.uploadPhotoIndicatorViews removeObject:indicatorView];
        [self updateIndicatorView];
        if (reload)
        {
            [self getLatestDataAnimated];
            //上传成功，询问服务器，是否要提示去app store 评分
            NSInteger userId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
            [[QDYHTTPClient sharedInstance]getUserRateStatusWithUserId:userId whenComplete:^(NSDictionary *result) {
                if ([result objectForKey:@"data"])
                {
                    NSDictionary *data = [result objectForKey:@"data"];
                    NSInteger allowRate = [[data objectForKey:@"allowRate"]integerValue];
                    if (allowRate == 1)
                    {
                        double delaysInSecond = 5.0;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)delaysInSecond * NSEC_PER_SEC);
                        dispatch_after(popTime, dispatch_get_main_queue(), ^{
                            VoteAlertView *voteAlertControl = [VoteAlertView alertControllerWithTitle:@"" message:nil preferredStyle:UIAlertControllerStyleAlert];
                            [self presentViewController:voteAlertControl animated:YES completion:nil];
                        }) ;
                    }
                }
                else
                {
                    NSLog(@"get rate status error");
                }
            }];
        }
    }];
}


-(void)uploadPhotoInfosToServer:(NSDictionary *)photosInfo
{
    NSString *photosNameString = @"";
    NSArray *imagesAndInfo = [photosInfo objectForKey:@"imagesAndInfo"];
    for (int i = 0;i<imagesAndInfo.count;i++)
    {
        NSDictionary *imageInfo = imagesAndInfo[i];
        if ([imageInfo objectForKey:@"imageName"])
        {
            photosNameString = [NSString stringWithFormat:@"%@;%@",photosNameString,[imageInfo objectForKey:@"imageName"]];
        }
    }
    if (photosNameString.length >1)
    {
        photosNameString = [photosNameString substringFromIndex:1];
    }
    NSInteger userId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    POI *uploadPoi = [photosInfo objectForKey:@"poiInfo"];
    NSString *photoDescription = [photosInfo objectForKey:@"photoDescription"];
    BOOL hasPoi = YES;
    if ([uploadPoi.uid isEqualToString:@""])
    {
        hasPoi = NO;
    }
    [[QDYHTTPClient sharedInstance]PostPhotoInfomationWithUserId:userId
                                                           photo:photosNameString
                                                         thought:photoDescription
                                                          haspoi:hasPoi
                                                        provider:uploadPoi.type
                                                             uid:uploadPoi.uid
                                                            name:uploadPoi.name
                                                        classify:uploadPoi.classify
                                                        location:uploadPoi.location
                                                         address:uploadPoi.address
                                                        province:uploadPoi.province
                                                            city:uploadPoi.city
                                                        district:uploadPoi.district
                                                           stamp:uploadPoi.stamp
                                                    whenComplete:^(NSDictionary *returnData)
     {
         UploadPhotoIndicatorView *indicatorView =[photosInfo objectForKey:@"indicatorView"];
         if ([returnData objectForKey:@"data"])
         {
             [indicatorView setStatus:UPLOAD_STATUS_UPLOAD_SUCCESS withInfo:@"照片上传成功"];
             [self hideIndicator:indicatorView WithDelay:2.0f ReloadData:YES];
             [self.uploadPhotoInfos removeObject:photosInfo];
         }
         else if ([returnData objectForKey:@"error"])
         {
             [indicatorView setStatus:UPLOAD_STATUS_UPLOAD_FAILED withInfo:@"照片上传失败"];
         }
     }];
    
    
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

#pragma mark - pagerViewItemDelegate
-(NSString *)titleForPagerViewController:(PagerViewController *)pagerViewController
{
    if (self.tableStyle == WZ_TABLEVIEWSTYLE_HOME)
    {
        return @"关注";
    }
    else if (self.tableStyle == WZ_TABLEVIEWSTYLE_DETAIL)
    {
        return @"照片详情";
    }
    else if (self.tableStyle == WZ_TABLEVIEWSTYLE_LIST)
    {
        return @"照片列表";
    }
    else if (self.tableStyle == WZ_TABLEVIEWSTYLE_SUGGEST)
    {
        return @"精选";
    }
    return @"";
}





@end
