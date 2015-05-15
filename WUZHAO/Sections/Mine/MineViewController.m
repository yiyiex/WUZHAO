//
//  MineViewController.m
//  Dtest3
//
//  Created by yiyi on 14-11-6.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//


#import "MineViewController.h"

#import "PhotosCollectionViewController.h"
#import "FootPrintTableViewController.h"

#import "UserListTableViewController.h"
#import "EditPersonalInfoTableViewController.h"

#import "UIImageView+WebCache.h"
#import "UIImageView+ChangeAppearance.h"
#import "UILabel+ChangeAppearance.h"
#import "UIButton+ChangeAppearance.h"

#import "NSLayoutConstraint+PureLayout.h"
#import "ALView+PureLayout.h"
#import "PureLayout+Internal.h"

#import "SVProgressHUD.h"
#import "QDYHTTPClient.h"
#import "macro.h"

#define SEGUEFIRST @"segueForPhotosColletion"
#define SEGUESECOND @"segueForAddressTable"
#define SEGUETHIRD @"segueForThird"
#define SEGUEFORTH @"segueForForth"

@interface MineViewController () <CommonContainerViewControllerDelegate,UIScrollViewDelegate>
{
    CGPoint scrollViewInitContentOffset;
}

@property (nonatomic, strong) CommonContainerViewController *containerViewController;

@property (nonatomic, weak) PhotosCollectionViewController *myPhotoCollectionViewController;
@property (nonatomic) NSInteger photoCollectionCurrentPage;
@property (nonatomic)float currentCollectionViewOffset;
@property (nonatomic, weak) FootPrintTableViewController *myFootPrintViewController;

@property (nonatomic,strong) UIRefreshControl *refreshControl;

@property (nonatomic) BOOL shouldRefreshData;
@property (nonatomic) BOOL shouldReloadData;
@property (nonatomic) BOOL  shouldLoadMore;


@end

@implementation MineViewController


static NSString * const minePhotoCell = @"minePhotosCell";
- (void)viewDidLoad {
    
    [super viewDidLoad];

    [self setAppearance];
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refreshByPullingTable:) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:self.refreshControl];
    self.shouldRefreshData = true;
    self.shouldReloadData = false;
    self.shouldLoadMore = true;
    self.shouldBackToTop = false;

    self.scrollView.delegate = self;
    [self getLatestData];
    [self configGesture];
    
    
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarItem;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteMyPhotos:) name:@"deleteMyPhoto" object:nil];
    self.selectToShowTabbar.selectedItem = [self.selectToShowTabbar.items objectAtIndex:0];
   
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.backBarButtonItem.title = @"";
    self.tabBarController.navigationController.navigationBarHidden = NO;
    [self updateMyInfomationUI];
    [self SetPhotosCollectionData];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.shouldReloadData)
    {
        [self.myPhotoCollectionViewController.collectionView reloadData];
        self.shouldReloadData = false;
    }
    NSLog(@"view frame : %f %f %f %f",self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.width,self.view.frame.size.height);
    NSLog(@"scrollview frame : %f %f %f %f",self.scrollView.frame.origin.x,self.scrollView.frame.origin.y,self.scrollView.frame.size.width,self.scrollView.frame.size.height);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setUserInfo:(User *)userInfo
{
    if (!_userInfo)
    {
        _userInfo = [[User alloc]init];
    }
    _userInfo = [userInfo mutableCopy];
    //同步本地保存用户数据
}

-(float)scrollContentViewHeight
{
    float topHeight = _avator.frame.size.height + self.descriptionTopConstraint.constant + self.descriptionViewHeightConstraint.constant + self.descriptionBottomConstraint.constant + _selectToShowTabbar.frame.size.height ;
    float bottomHeight;
    if (self.myPhotosCollectionDatasource.count >9)
    {
         bottomHeight = (ceil ((float)self.myPhotosCollectionDatasource.count/3)) * WZ_APP_SIZE.width/3 +44;
    }
    else
    {
        //bottomHeight = 4*WZ_APP_SIZE.width/3;
        bottomHeight = WZ_APP_SIZE.height -topHeight +44;
    }
    
    return topHeight + bottomHeight;
}

-(void)setAppearance
{
    [self.avator setBackgroundColor:THEME_COLOR_LIGHT_GREY_MORE_PARENT];
    [self.avator setRoundConerWithRadius:self.avator.frame.size.width/2];
    
    if([self.mineButton.titleLabel.text isEqualToString:@"已关注"]|| [self.mineButton.titleLabel.text isEqualToString:@"互相关注"])
    {
        [self.mineButton setThemeFrameAppearence];
    }
    else if([self.mineButton.titleLabel.text isEqualToString:@"关注"]||[self.mineButton.titleLabel.text isEqualToString:@"编辑个人信息"])
    {
        [self.mineButton setThemeBackGroundAppearance];
    }
    else
    {
        [_mineButton setTitle:@"正在加载..." forState:UIControlStateNormal];
        [self.mineButton setDarkGreyParentBackGroundAppearance];
    }
    [self.mineButton setNormalButtonAppearance];
    [self.selfDescriptionLabel setReadOnlyLabelAppearance];
    
 

}

-(void)setPersonalInfo
{

    [_mineButton setTitle:@"正在加载..." forState:UIControlStateNormal];
    self.shouldRefreshData = false;
    if (!_userInfo)
    {
        _userInfo = [[User alloc]init];
        _userInfo.UserID = [[NSUserDefaults standardUserDefaults] integerForKey:@"userId"];
        _userInfo.UserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    }
    self.photoCollectionCurrentPage = 1;
    NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[QDYHTTPClient sharedInstance]GetPersonalInfoWithUserId:_userInfo.UserID currentUserId:myUserId page:self.photoCollectionCurrentPage whenComplete:^(NSDictionary *returnData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([returnData objectForKey:@"data"])
                {
                    User *user = [returnData objectForKey:@"data"];
                    NSLog(@"userinfo %@",user);
                    [self setUserInfo:user];
                    [self updateMyInfomationUI];
                    [self SetPhotosCollectionData];
                    NSLog(@"collection view height%f",self.containerViewController.currentViewController.view.frame.size.height);
                    [self.scrollContentViewHeightConstraint setConstant:self.scrollContentViewHeight];
                    [self.scrollContentView setNeedsLayout];
                    [self.scrollContentView layoutIfNeeded];
                    if (self.shouldBackToTop)
                    {
                        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
                    }
                }
                else if ([returnData objectForKey:@"error"])
                {
                    [SVProgressHUD showErrorWithStatus:@"获取个人信息失败"];
                }
                self.shouldRefreshData = true;
                
                if ([self.refreshControl isRefreshing])
                {
                    [self.refreshControl endRefreshing];
                }
            });
        }];

    });


}

#pragma mark - gesture and action
-(void)configGesture
{
    self.rightHeaderView.userInteractionEnabled = YES;
    self.followersNumLabel.userInteractionEnabled = YES;
    self.followsNumLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *photoListClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(photoListShow:)];
    [self.photosNumLabel addGestureRecognizer:photoListClick];
    UITapGestureRecognizer *followsCilck = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(followsShow:)];
    [self.followsNumLabel addGestureRecognizer:followsCilck];
    //[self.followsLabel addGestureRecognizer:followsCilck];
    UITapGestureRecognizer *followersClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(followersShow:)];
    [self.followersNumLabel addGestureRecognizer:followersClick];
    
}

-(void)photoListShow:(UITapGestureRecognizer *)gesture
{
    
}

-(void)followsShow:(UITapGestureRecognizer *)gesture
{
    
    NSInteger userId = self.userInfo.UserID;
    NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[QDYHTTPClient sharedInstance]GetPersonalFollowsListWithUserId:userId currentUserId:myUserId whenComplete:^(NSDictionary *returnData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([returnData objectForKey:@"data"])
                {
                    UIStoryboard *userListStoryBoard = [UIStoryboard storyboardWithName:@"UserList" bundle:nil];
                    UserListTableViewController *followsList = [userListStoryBoard instantiateViewControllerWithIdentifier:@"userListTableView"];
                    [followsList setUserListStyle:UserListStyle2];
                    [followsList setDatasource:[returnData objectForKey:@"data"]];
                    if (userId == myUserId)
                    {
                        [followsList setTitle:@"我关注的"];
                    }
                    else
                    {
                        [followsList setTitle:[NSString stringWithFormat:@"%@关注的",self.userInfo.UserName]];
                    }
                    [self.navigationController pushViewController:followsList animated:YES];
                }
                else if ([returnData objectForKey:@"error"])
                {
                    [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
                    
                }
            });

        }];
    });


    
}

-(void)followersShow:(UITapGestureRecognizer *)gesture

{
    
    NSInteger userId = self.userInfo.UserID;
    NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[QDYHTTPClient sharedInstance]GetPersonalFollowersListWithUserId:userId currentUserId:myUserId whenComplete:^(NSDictionary *returnData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([returnData objectForKey:@"data"])
                {
                    UIStoryboard *userListStoryBoard = [UIStoryboard storyboardWithName:@"UserList" bundle:nil];
                    UserListTableViewController *followersList = [userListStoryBoard instantiateViewControllerWithIdentifier:@"userListTableView"];
                    [followersList setUserListStyle:UserListStyle2];
                    [followersList setDatasource:[returnData objectForKey:@"data"]];
                    if (userId == myUserId)
                    {
                        [followersList setTitle:@"关注我的"];
                    }
                    else
                    {
                        [followersList setTitle:[NSString stringWithFormat:@"关注%@的",self.userInfo.UserName]];
                    }
                    [self.navigationController pushViewController:followersList animated:YES];
                }
                else if ([returnData objectForKey:@"error"])
                {
                    [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
                    
                }
            });

        }];
    });

    
}
- (IBAction)MineButtonClick:(id)sender {
    if ( [sender isKindOfClass:[UIButton class]])
    {
        UIButton *myBtn = (UIButton *)sender;
        if ([myBtn.titleLabel.text  isEqualToString:@"编辑个人信息"])
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
            
            EditPersonalInfoTableViewController *editViewController = [storyboard instantiateViewControllerWithIdentifier:@"editPersonalInfo"];
            editViewController.userInfo = self.userInfo;
            [self.navigationController pushViewController:editViewController animated:YES];
            
           // [self performSegueWithIdentifier:@"editPersonInfo" sender:self];
        }
        else if ([myBtn.titleLabel.text  isEqualToString:@"关注"])
        {
            NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [[QDYHTTPClient sharedInstance]followUser:self.userInfo.UserID withUserId:myUserId whenComplete:^(NSDictionary *result) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([result objectForKey:@"data"])
                        {
                            //[SVProgressHUD showInfoWithStatus:@"关注成功"];
                            [myBtn setTitle:@"已关注" forState:UIControlStateNormal];
                            
                        }
                        else if ([result objectForKey:@"error"])
                        {
                            [SVProgressHUD showErrorWithStatus:[result objectForKey:@"error"]];
                        }
                    });

                }];
            });

        }
        else if ([myBtn.titleLabel.text  isEqualToString:@"已关注"])
        {
            NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[QDYHTTPClient sharedInstance]unFollowUser:self.userInfo.UserID withUserId:myUserId whenComplete:^(NSDictionary *result) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                if ([result objectForKey:@"data"])
                {
                    //[SVProgressHUD showInfoWithStatus:@"关注成功"];
                    [myBtn setTitle:@"关注" forState:UIControlStateNormal];
                    
                }
                else if ([result objectForKey:@"error"])
                {
                    [SVProgressHUD showErrorWithStatus:[result objectForKey:@"error"]];
                }
                 });
            }];
            });
        }
        
    }
}

-(void)refreshByPullingTable:(id)sender
{
    [self getLatestData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"embedContainer"])
    {
        self.containerViewController = segue.destinationViewController;
        self.containerViewController.delegate = self;
        self.containerViewController.ChildrenName = @[SEGUEFIRST,SEGUESECOND,SEGUETHIRD,SEGUEFORTH];
    }
    else if ([segue.identifier isEqualToString:@"editPersonInfo"])
    {
        EditPersonalInfoTableViewController *editController = (EditPersonalInfoTableViewController *)segue.destinationViewController;
        editController.userInfo = self.userInfo;
        
    }
}


#pragma mark -tapbar
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSString *segueIdentifier = SEGUEFIRST;
    if (item.tag == 1)
    {
        segueIdentifier = SEGUEFIRST;
        
    }
    else if (item.tag == 2)
    {
        segueIdentifier = SEGUESECOND;
    }
    [self.containerViewController swapViewControllersWithIdentifier:segueIdentifier];
    
}
#pragma mark - commonContainerViewController delegate

-(void)finishLoadChildController:(UIViewController *)childController
{
    if ([childController isKindOfClass: [PhotosCollectionViewController class]])
    {
        self.myPhotoCollectionViewController = (PhotosCollectionViewController *)childController;
        [self.myPhotoCollectionViewController.collectionView setBackgroundColor:[UIColor whiteColor]];
        [self SetPhotosCollectionData];
        [self.myPhotoCollectionViewController.collectionView setScrollEnabled:NO];
        [self.myPhotoCollectionViewController.collectionView setScrollsToTop:NO];
        
    }
    else if( [childController isKindOfClass:[FootPrintTableViewController class]])
    {
        self.myFootPrintViewController = (FootPrintTableViewController *)childController;
        [self SetAddressListData];
    }
}

#pragma mark - control the model



-(void) updateMyInfomationUI
{
    if ([self.userInfo.UserName isEqualToString:@""])
    {
        self.tabBarController.navigationItem.title = @"个人主页";
        self.navigationItem.title = @"个人主页";
    }
    else
    {
        self.tabBarController.navigationItem.title = self.userInfo.UserName;
        self.navigationItem.title = self.userInfo.UserName;
    }
    [self.avator sd_setImageWithURL:[NSURL URLWithString:self.userInfo.avatarImageURLString]];

    self.photosNumLabel.text =[NSString stringWithFormat:@"%lu", self.userInfo.photosNumber ? (unsigned long)self.userInfo.photosNumber:0];
    self.followersNumLabel.text =[NSString stringWithFormat:@"%lu", self.userInfo.numFollowers ? (unsigned long)self.userInfo.numFollowers:0];
    self.followsNumLabel.text = [NSString stringWithFormat:@"%lu", self.userInfo.numFollows ? (unsigned long)self.userInfo.numFollows:0];
    self.selfDescriptionLabel.text = self.userInfo.selfDescriptions ? [self.userInfo.selfDescriptions stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"]:@"";
    
    if ([self.selfDescriptionLabel.text isEqualToString:@""])
    {

        [self.descriptionTopConstraint setConstant:0.0];
        [self.descriptionBottomConstraint setConstant:0.0];
      //  [self.descriptionViewHeightConstraint setConstant:0];
        
    }
    else
    {
        [self.descriptionTopConstraint setConstant:4.0];
        [self.descriptionBottomConstraint setConstant:4.0];
       // self.descriptionViewHeightConstraint = [self.selfDescriptionView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.selfDescriptionLabel];
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSInteger myUserId = [ud integerForKey:@"userId"];
    if (myUserId == self.userInfo.UserID)
    {
        [self.mineButton setTitle:@"编辑个人信息" forState:UIControlStateNormal];
        [self.mineButton setThemeFrameAppearence];
    }
    else if (self.userInfo.followType == UNFOLLOW)
    {
        [self.mineButton setTitle:@"关注" forState:UIControlStateNormal];
        [self.mineButton setThemeFrameAppearence];
    }
    else if (self.userInfo.followType == FOLLOWED)
    {
        [self.mineButton setTitle:@"已关注" forState:UIControlStateNormal];
        [self.mineButton setThemeBackGroundAppearance];
    }
    else if (self.userInfo.followType == FOLLOWEACH)
    {
        [self.mineButton setTitle:@"互相关注" forState:UIControlStateNormal];
        [self.mineButton setThemeBackGroundAppearance];
    }
    else
    {
        [self.mineButton setTitle:@"  " forState:UIControlStateNormal];
        [self.mineButton setBackgroundColor:[UIColor grayColor]];
        
    }
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}
-(void)SetPhotosCollectionData
{
    if (!_myPhotosCollectionDatasource)
    {
        _myPhotosCollectionDatasource = [[NSMutableArray alloc]init];
    }
    
    if (self.userInfo.photoList)
    {
        //NSLog(@"photolist %@",self.userInfo.photoList);
        [_myPhotosCollectionDatasource removeAllObjects];
        self.photoCollectionCurrentPage = 1;
        for (NSDictionary *i in self.userInfo.photoList)
        {
            WhatsGoingOn *item = [[WhatsGoingOn alloc]init];
            item.postId = [(NSNumber *)[i objectForKey:@"postId"] integerValue];
            item.imageUrlString = [i objectForKey:@"photoUrl"];
            item.postTime = [i objectForKey:@"time"];
            item.photoUser = self.userInfo;
            [_myPhotosCollectionDatasource addObject:item];
        }
        
    }
    [self.myPhotoCollectionViewController setDatasource:_myPhotosCollectionDatasource];
    [self.myPhotoCollectionViewController loadData];


    

}

-(void)addMorePhotoCollectionDataWith:(NSArray *)data
{
    for (NSDictionary *i in data)
    {
        WhatsGoingOn *item = [[WhatsGoingOn alloc]init];
        item.postId = [(NSNumber *)[i objectForKey:@"postId"] integerValue];
        item.imageUrlString = [i objectForKey:@"photoUrl"];
        item.postTime = [i objectForKey:@"time"];
        item.photoUser = self.userInfo;
        [_myPhotosCollectionDatasource addObject:item];
    }
    [self.userInfo.photoList addObjectsFromArray:data];
    [self.myPhotoCollectionViewController setDatasource:_myPhotosCollectionDatasource];
    [self.myPhotoCollectionViewController loadData];
    
}

-(void)loadMoreCollectionData
{
    //请求更多数据
    if (self.shouldLoadMore)
    {
        self.shouldLoadMore = false;
        self.shouldRefreshData = false;
        NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[QDYHTTPClient sharedInstance]GetPersonalInfoWithUserId:_userInfo.UserID currentUserId:myUserId page:self.photoCollectionCurrentPage+1 whenComplete:^(NSDictionary *returnData) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([returnData objectForKey:@"data"])
                    {
                        
                        User *user = [returnData objectForKey:@"data"];
                        NSLog(@"userinfo %@",user);
                        if (user.photoList.count >0)
                        {
                            
                            [self addMorePhotoCollectionDataWith:user.photoList];
                            self.photoCollectionCurrentPage ++;
                            
                            [self.scrollContentViewHeightConstraint setConstant:self.scrollContentViewHeight];
                            [self.view setNeedsLayout];
                            [self.view layoutIfNeeded];
                        }
                        else
                        {
                            NSLog(@"no more data");
                            //TO DO
                        }
                        NSLog(@"collection view height%f",self.containerViewController.currentViewController.view.frame.size.height);
                    }
                    else if ([returnData objectForKey:@"error"])
                    {
                        [SVProgressHUD showErrorWithStatus:@"获取信息失败"];
                    }
                    self.shouldRefreshData = true;
                    self.shouldLoadMore = true;
                    
                    if ([self.refreshControl isRefreshing])
                    {
                        [self.refreshControl endRefreshing];
                    }
                });
                
            }];
        });
    }
    
}


-(void)SetAddressListData
{
    //根据个人信息，获取更多信息
    if (!_myAddressListDatasource)
    {
    /*
    
     [AFHTTPAPIClient sharedInstance]GetPersonalPhotosListWithUserId:self.userInfo.UserID complete:^(NSDictionary *result, NSError *error) {
     if (result)
     {
     //self.dataSource = [result mutableCopy];
     //set more info to userInfo
     //....
     }
     else if (error)
     {
     [SVProgressHUD showErrorWithStatus:@"请求失败,请检查连接"];
     
     }
     }];
     
     */

    }
    _myAddressListDatasource = [[FootPrint newData]mutableCopy];
    [self.myFootPrintViewController setDatasource:_myAddressListDatasource];
    [self.myFootPrintViewController loadData];
}

-(void)getLatestData
{
   
    if (self.shouldRefreshData)
    {

        [self setPersonalInfo];
    }
    return;
}

-(void)deleteMyPhotos:(NSNotification *)notification
{
    NSLog(@"%@",notification);
   // NSIndexPath *deleteIndexPath = [[notification userInfo]objectForKey:@"indexPath"];
    //[_myPhotosCollectionDatasource removeObjectAtIndex:deleteIndexPath.row];
    NSLog(@"%@",self.myPhotosCollectionDatasource);
    self.shouldReloadData = true;
    //网络刷新
    [self getLatestData];
    //本地刷新
    //[self.myPhotoCollectionViewController setDatasource:_myPhotosCollectionDatasource];
    //[self.myPhotoCollectionViewController.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:deleteIndexPath]];
}

#pragma mark - scrollview delegate
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGPoint loadMorePoint = CGPointMake(0, self.scrollView.contentSize.height);
    CGPoint targetPoint = *targetContentOffset;
    NSLog(@"app size.hight :%f",WZ_APP_SIZE.height);
    if (targetPoint.y > loadMorePoint.y -WZ_APP_SIZE.height )
    {
        [self loadMoreCollectionData];
        
    }
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}



@end
