//
//  MineViewController.m
//  Dtest3
//
//  Created by yiyi on 14-11-6.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#define TOPCOVERHEIGHT 240
#define kNavBarHeight 49
#define kAvatarWidth 76
#define kAvatarVerticalOffset 49
#define kFollowsLabelOffset 40

#import "MineViewController.h"

#import "PhotosCollectionViewController.h"
#import "FootPrintTableViewController.h"
#import "AddressMarkViewController.h"

#import "UserListTableViewController.h"
#import "EditPersonalInfoTableViewController.h"

#import "UIViewController+HideBottomBar.h"

#import "UIScrollView+BlurCover.h"

#import "UIView+ChangeAppearance.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+ChangeAppearance.h"
#import "UILabel+ChangeAppearance.h"
#import "UIButton+ChangeAppearance.h"

#import "NSLayoutConstraint+PureLayout.h"
#import "ALView+PureLayout.h"
#import "PureLayout+Internal.h"

#import "SVProgressHUD.h"
#import "QDYHTTPClient.h"
#import "POISearchAPI.h"
#import "macro.h"
#import "PhotoCommon.h"
#import "CameraUtility.h"

#import "QiniuSDK.h"

#define SEGUEFIRST @"segueForPhotosColletion"
#define SEGUESECOND @"segueForAddressTable"
#define SEGUETHIRD @"segueForThird"
#define SEGUEFORTH @"segueForForth"

@interface MineViewController () <CommonContainerViewControllerDelegate,UIScrollViewDelegate,UIActionSheetDelegate ,UIImagePickerControllerDelegate>
{
    CGPoint scrollViewInitContentOffset;
    UIActivityIndicatorView *_aiv;
}

@property (nonatomic, strong) UIView *navigationBar;
@property (strong, nonatomic) UIButton *mineButton;

@property (strong, nonatomic) UILabel *followsNumLabel;
@property (strong, nonatomic) UILabel *followsLabel;
@property (strong, nonatomic) UILabel *followersNumLabel;
@property (strong, nonatomic) UILabel *followersLabel;

@property (nonatomic, strong) UILabel *myPhotosNumLabel;
@property (nonatomic, strong) UILabel *myPhotosLabel;

@property (nonatomic, strong) UILabel *myAddressNumLabel;
@property (nonatomic, strong) UILabel *myAddressLabel;

//@property (nonatomic, strong) UIButton *myPhotosButton;
//@property (nonatomic, strong) UIButton *myAddressButton;
@property (nonatomic, strong) UIButton *myMapButton;

@property (nonatomic, strong) CommonContainerViewController *containerViewController;

@property (nonatomic, weak) PhotosCollectionViewController *myPhotoCollectionViewController;
@property (nonatomic) NSInteger photoCollectionCurrentPage;
@property (nonatomic)float currentCollectionViewOffset;

@property (nonatomic, weak) FootPrintTableViewController *myFootPrintViewController;
@property (nonatomic) NSInteger footPrintCurrentPage;
@property (nonatomic) float currentFootPrintViewOffset;

@property (nonatomic, strong) AddressMarkViewController *addressMarkViewController;

@property (nonatomic,strong) UIRefreshControl *refreshControl;

@property (nonatomic,strong) UILabel *footLabel;

@property (nonatomic, strong) UIImageView *placeHolderImageView;
@property (nonatomic, strong) UIImage *coverImage;


@property (nonatomic) BOOL shouldRefreshData;
@property (nonatomic) BOOL shouldReloadData;
@property (nonatomic) BOOL  shouldLoadMore;


@end

@implementation MineViewController


static NSString * const minePhotoCell = @"minePhotosCell";
- (void)viewDidLoad {    
    [super viewDidLoad];

    [self initView];

    
    self.shouldRefreshData = true;
    self.shouldReloadData = false;
    self.shouldLoadMore = true;
    self.shouldBackToTop = false;
    
    self.scrollView.delegate = self;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    [self configGesture];
    
    //backitemf
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarItem;
    
    //notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMyPhotos:) name:@"deletePost" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearUserInfo)  name:@"deleteUserInfo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo) name:@"updateUserInfo" object:nil];

    //默认显示照片列表
    [self.myPhotosNumLabel setHighlighted:YES];
    [self.myPhotosLabel setHighlighted:YES];
    
    if (_myPhotosCollectionDatasource.count >0)
    {
        [self updateMyInfomationUI];
        [self SetPhotosCollectionData];
    }
    else
    {
        [self getLatestData];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   // [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"transparent_nav"] forBarMetrics:UIBarMetricsDefault];
   // self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"transparent_nav"];
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.navigationItem.backBarButtonItem.title = @"";
    self.tabBarController.navigationController.navigationBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // [self.scrollView addBlurCoverWithImage:[UIImage imageNamed:@"cover.png"]];
    UITapGestureRecognizer *backGroundImageTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backGroundImageClick:)];
    [self.scrollView.blurCoverView addGestureRecognizer:backGroundImageTap];
    [self.scrollView.blurCoverView setUserInteractionEnabled:YES];
    if (self.shouldReloadData)
    {
        [self.myPhotoCollectionViewController.collectionView reloadData];
        self.shouldReloadData = false;
    }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
   // [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    // [self.navigationController.navigationBar setShadowImage:nil];
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.scrollView removeBlurCoverView];
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
}
-(void)setCoverImage:(UIImage *)coverImage
{
    _coverImage = coverImage;
    if (self.scrollView.blurCoverView)
    {
        [self.scrollView.blurCoverView setImage:coverImage];
    }
}
-(UIImageView *)placeHolderImageView
{
    if (!_placeHolderImageView)
    {
        _placeHolderImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -100, 20, 20)];
        [self.view addSubview:_placeHolderImageView];
        
    }
    return _placeHolderImageView;
}

-(float)scrollContentViewHeight
{
    float topHeight = TOPCOVERHEIGHT ;
    __block float bottomHeight = 44;
    if (self.myPhotosLabel.highlighted)
    {
        if (_myPhotosCollectionDatasource.count >6)
        {
             bottomHeight += (ceil ((float)_myPhotosCollectionDatasource.count/3)) * WZ_APP_SIZE.width/3 ;
        }
        else
        {
            //bottomHeight = 4*WZ_APP_SIZE.width/3;
            bottomHeight = WZ_APP_SIZE.height -topHeight +10;
        }
    }
    else if (self.myAddressLabel.highlighted)
    {
        if (self.myAddressListDatasource.count>1)
        {
            [self.myAddressListDatasource enumerateObjectsUsingBlock:^(AddressPhotos *address, NSUInteger idx, BOOL *stop) {
                bottomHeight += ceilf((float)address.photoList.count/3)*(WZ_APP_SIZE.width/3) +36;
            }];
        }
        else
        {
            bottomHeight = WZ_APP_SIZE.height - topHeight +10;
        }
    }
    
    return topHeight + bottomHeight;
}

#pragma mark - init views

-(void)adaptFollowsLabels
{
    [self.followsNumLabel sizeToFit];
    CGRect frame = self.followsNumLabel.frame;
    frame.origin.x = WZ_APP_SIZE.width/2 - 8 - frame.size.width;
    frame.origin.y = kAvatarVerticalOffset + kAvatarWidth + kFollowsLabelOffset;
    frame.size.height = 20;
    [self.followsNumLabel setFrame:frame];
    
    [self.followsLabel sizeToFit];
    CGRect followsFrame = self.followsLabel.frame;
    
    followsFrame.origin.x = frame.origin.x - 8 - followsFrame.size.width;
    followsFrame.origin.y = kAvatarVerticalOffset + kAvatarWidth + kFollowsLabelOffset;
    followsFrame.size.height = 20;
    [self.followsLabel setFrame:followsFrame];
}

-(void)adaptFollowersLabels
{
    [self.followersLabel sizeToFit];
    CGRect frame = self.followersLabel.frame;
    frame.origin.x = WZ_APP_SIZE.width/2 + 8 ;
    frame.origin.y = kAvatarVerticalOffset + kAvatarWidth + kFollowsLabelOffset;
    frame.size.height = 20;
    [self.followersLabel setFrame:frame];
    
    [self.followersNumLabel sizeToFit];
    CGRect followersNumFrame = self.followersNumLabel.frame;
    
    followersNumFrame.origin.x = frame.origin.x + frame.size.width +8;
    followersNumFrame.origin.y = kAvatarVerticalOffset + kAvatarWidth + kFollowsLabelOffset;
    followersNumFrame.size.height = 20;
    [self.followersNumLabel setFrame:followersNumFrame];
}

-(void)initView
{
    float avatarVerticalOffset = kAvatarVerticalOffset;
    float avatarViewWidth = kAvatarWidth;
    float followsLabelOffset = kFollowsLabelOffset;
    float buttonWidth = 44;
    float labelHeight = 22;
    float navBarHeight = 49;

    
    [self.scrollView addBlurCover];
    // [self.scrollView addBlurCoverWithImage:[UIImage imageNamed:@"cover.png"]];
    UITapGestureRecognizer *backGroundImageTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backGroundImageClick:)];
    [self.scrollView.blurCoverView addGestureRecognizer:backGroundImageTap];
    [self.scrollView.blurCoverView setUserInteractionEnabled:YES];
    
    //usernameLabel
    self.userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, WZ_APP_SIZE.width - 40, navBarHeight)];
    [self.userNameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.userNameLabel setTextColor:THEME_COLOR_WHITE];
    [self.userNameLabel setFont:[UIFont systemFontOfSize:20]];
    [self.scrollView addSubview:self.userNameLabel];
    
    //avatar
    self.avator = [[UIImageView alloc]initWithFrame:CGRectMake((WZ_APP_SIZE.width - avatarViewWidth)/2 , avatarVerticalOffset, avatarViewWidth, avatarViewWidth)];
    [self.avator setRoundAppearanceWithBorder:THEME_COLOR_WHITE borderWidth:2.0];
    [self.avator setBackgroundColor:THEME_COLOR_LIGHT_GREY_MORE_PARENT];
    UITapGestureRecognizer *avatarTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(personalAvatarClick)];
    [self.avator addGestureRecognizer:avatarTapGesture];
    [self.avator setUserInteractionEnabled:YES];
    
    [self.scrollView addSubview:self.avator];
    
    //myButton
    self.mineButton = [[UIButton alloc]initWithFrame:CGRectMake((WZ_APP_SIZE.width + avatarViewWidth)/2 + 28, avatarVerticalOffset + (avatarViewWidth - 24)/2, 64, 24)];
    [self.scrollView addSubview:self.mineButton];

    [self.mineButton setHidden:YES];
    [self.mineButton setNormalButtonAppearance];
    [self.mineButton addTarget:self action:@selector(MineButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //self description
    self.selfDescriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, avatarVerticalOffset + avatarViewWidth , WZ_APP_SIZE.width - 16 , 36)];
    [self.scrollView addSubview:self.selfDescriptionLabel];
    [self.selfDescriptionLabel setTextColor:[UIColor whiteColor]];
    [self.selfDescriptionLabel setFont:WZ_FONT_COMMON_SIZE];
    [self.selfDescriptionLabel setTextAlignment:NSTextAlignmentCenter];
    [self.selfDescriptionLabel setNumberOfLines:2];
    
    //follows and followers
    self.followsLabel = [[UILabel alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width/2 - 44 - 50, avatarVerticalOffset + avatarViewWidth + followsLabelOffset , 50, labelHeight)];
    self.followsNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width/2 - 40, avatarVerticalOffset + avatarViewWidth + followsLabelOffset  , 40, labelHeight)];
    [self.followsNumLabel setText:@"0"];
    [self.followsNumLabel setTextAlignment:NSTextAlignmentLeft];
    [self.followsNumLabel setFont:WZ_FONT_READONLY_BOLD];
    [self.followsNumLabel setTextColor:THEME_COLOR_WHITE];
    [self.followsLabel setText:@"关注"];
    [self.followsLabel setTextAlignment:NSTextAlignmentRight];
    [self.followsLabel setFont:WZ_FONT_SMALL_SIZE];
    [self.followsLabel setTextColor:THEME_COLOR_WHITE];
    [self.scrollView addSubview:self.followsLabel];
    [self.scrollView addSubview:self.followsNumLabel];
    
    UILabel *seperateLabel = [[UILabel alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width/2-4, avatarVerticalOffset + avatarViewWidth + followsLabelOffset , 8, labelHeight)];
    [seperateLabel setText:@"/"];
    [seperateLabel setTextAlignment:NSTextAlignmentCenter];
    [seperateLabel setTextColor:THEME_COLOR_WHITE];
    [seperateLabel setFont:WZ_FONT_COMMON_BOLD_SIZE];
    [self.scrollView addSubview:seperateLabel];
    
    self.followersNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width/2 + 58, avatarVerticalOffset + avatarViewWidth + followsLabelOffset , 40, labelHeight)];
    self.followersLabel = [[UILabel alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width/2 + 10 , avatarVerticalOffset + avatarViewWidth + followsLabelOffset  , 40, labelHeight)];
    [self.followersNumLabel setText:@"0"];
    [self.followersNumLabel setTextAlignment:NSTextAlignmentLeft];
    [self.followersNumLabel setFont:WZ_FONT_READONLY_BOLD];
    [self.followersNumLabel setTextColor:THEME_COLOR_WHITE];
    [self.followersLabel setText:@"关注者"];
    [self.followersLabel setTextAlignment:NSTextAlignmentLeft];
    [self.followersLabel setFont:WZ_FONT_SMALL_SIZE];
    [self.followersLabel setTextColor:THEME_COLOR_WHITE];
    [self.scrollView addSubview:self.followersLabel];
    [self.scrollView addSubview:self.followersNumLabel];
    
    //init tabbar
    UIView *backGroundView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPCOVERHEIGHT - 44, WZ_APP_SIZE.width, 44)];
    [backGroundView setBackgroundColor:THEME_COLOR_DARK_GREY_MORE_PARENT];
    [self.scrollView addSubview:backGroundView];
    
    float tabbarLabelWidth = WZ_APP_SIZE.width/3;
    self.myPhotosNumLabel = [[UILabel alloc]initWithFrame:CGRectMake((WZ_APP_SIZE.width/3 - tabbarLabelWidth)/2, TOPCOVERHEIGHT - (labelHeight-2)*2 , tabbarLabelWidth, labelHeight)];
    self.myPhotosLabel = [[UILabel alloc]initWithFrame:CGRectMake((WZ_APP_SIZE.width/3 - tabbarLabelWidth)/2, TOPCOVERHEIGHT - labelHeight , tabbarLabelWidth, labelHeight)];
    [self.myPhotosNumLabel setText:@"0"];
    [self.myPhotosNumLabel setTextAlignment:NSTextAlignmentCenter];
    [self.myPhotosNumLabel setFont:WZ_FONT_SMALL_SIZE];
    [self.myPhotosNumLabel setTextColor:THEME_COLOR_WHITE];
    [self.myPhotosNumLabel setHighlightedTextColor:THEME_COLOR_DARK];
    [self.myPhotosLabel setText:@"发布"];
    [self.myPhotosLabel setTextAlignment:NSTextAlignmentCenter];
    [self.myPhotosLabel setFont:WZ_FONT_SMALL_SIZE];
    [self.myPhotosLabel setTextColor:THEME_COLOR_WHITE];
    [self.myPhotosLabel setHighlightedTextColor:THEME_COLOR_DARK];
    UITapGestureRecognizer *myPhotoNumLabelTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myPhotosButtonClick:)];
    [self.myPhotosNumLabel addGestureRecognizer:myPhotoNumLabelTap];
    [self.myPhotosNumLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *myPhotoLabelTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myPhotosButtonClick:)];
    [self.myPhotosLabel addGestureRecognizer:myPhotoLabelTap];
    [self.myPhotosLabel setUserInteractionEnabled:YES];
    
    [self.scrollView addSubview:self.myPhotosNumLabel];
    [self.scrollView addSubview:self.myPhotosLabel];
    
    self.myAddressNumLabel = [[UILabel alloc]initWithFrame:CGRectMake((WZ_APP_SIZE.width/3 - tabbarLabelWidth)/2 + WZ_APP_SIZE.width/3 , TOPCOVERHEIGHT - (labelHeight -2)*2 , tabbarLabelWidth, labelHeight)];
    self.myAddressLabel = [[UILabel alloc]initWithFrame:CGRectMake((WZ_APP_SIZE.width/3 - tabbarLabelWidth)/2 + WZ_APP_SIZE.width/3 , TOPCOVERHEIGHT - labelHeight , tabbarLabelWidth, labelHeight)];
    [self.myAddressNumLabel setText:@"0"];
    [self.myAddressNumLabel setTextAlignment:NSTextAlignmentCenter];
    [self.myAddressNumLabel setTextColor:THEME_COLOR_WHITE];
    [self.myAddressNumLabel setFont:WZ_FONT_SMALL_SIZE];
    [self.myAddressNumLabel setHighlightedTextColor:THEME_COLOR_DARK];
    [self.myAddressLabel setText:@"地点"];
    [self.myAddressLabel setTextAlignment:NSTextAlignmentCenter];
    [self.myAddressLabel setTextColor:THEME_COLOR_WHITE];
    [self.myAddressLabel setFont:WZ_FONT_SMALL_SIZE];
    [self.myAddressLabel setHighlightedTextColor:THEME_COLOR_DARK];
    UITapGestureRecognizer *myAddressNumLabelTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myAddressButtonClick:)];
    [self.myAddressNumLabel addGestureRecognizer:myAddressNumLabelTap];
    [self.myAddressNumLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *myAddressLabelTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myAddressButtonClick:)];
    [self.myAddressLabel addGestureRecognizer:myAddressLabelTap];
    [self.myAddressLabel setUserInteractionEnabled:YES];
    
    [self.scrollView addSubview:self.myAddressNumLabel];
    [self.scrollView addSubview:self.myAddressLabel];
    
    self.myMapButton = [[UIButton alloc]initWithFrame:CGRectMake((WZ_APP_SIZE.width/3 - tabbarLabelWidth)/2 + WZ_APP_SIZE.width/3*2, TOPCOVERHEIGHT - buttonWidth , tabbarLabelWidth, buttonWidth)];
    [self.myMapButton setImage:[UIImage imageNamed:@"earth.png"] forState:UIControlStateNormal];
    [self.myMapButton setImage:[UIImage imageNamed:@"earth_s.png"] forState:UIControlStateSelected];
    [self.myMapButton addTarget:self action:@selector(myMapButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.myMapButton];
    
    //draw button lines
    [PhotoCommon drawALineWithFrame:CGRectMake(WZ_APP_SIZE.width/3, TOPCOVERHEIGHT - 36 , 0.6, 24) andColor:THEME_COLOR_WHITE inLayer:self.scrollView.layer];
    [PhotoCommon drawALineWithFrame:CGRectMake(WZ_APP_SIZE.width/3*2, TOPCOVERHEIGHT - 36 , 0.6, 24) andColor:THEME_COLOR_WHITE inLayer:self.scrollView.layer];
    
    //setting button
    UIButton *setting = [[UIButton alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width - 56, 0, 48, 48)];
    [setting setImage:[UIImage imageNamed:@"setting.png"] forState:UIControlStateNormal];
    [setting addTarget:self action:@selector(settingButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.scrollView addSubview:setting];
    
    //back button
    if (self.userInfo )
    {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(8, 24, 35, 35)];
        UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(6, 8, 19, 19)];
        [view addSubview:backButton];
        [view setBackgroundColor:THEME_COLOR_DARK_GREY_PARENT];
        UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backButtonClick:)];
        [view addGestureRecognizer:tapgesture];
        [view setUserInteractionEnabled:YES];
        [view setRoundAppearance];
        [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:view];
        
        if (self.userInfo.UserID != [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"])
        {
            [setting setHidden:YES];
        }
    }

}

-(void)setPersonalInfo
{
    [self.mineButton setTitle:@"正在加载..." forState:UIControlStateNormal];
    self.shouldRefreshData = false;
    [self.scrollView setContentOffset:CGPointMake(0, -20) animated:NO];
    if (!_userInfo)
    {
        _userInfo = [[User alloc]init];
        _userInfo.UserID = [[NSUserDefaults standardUserDefaults] integerForKey:@"userId"];
        _userInfo.UserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    }
    self.photoCollectionCurrentPage = 1;
    NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[QDYHTTPClient sharedInstance]GetPersonalInfoWithUserId:self.userInfo.UserID currentUserId:myUserId page:self.photoCollectionCurrentPage whenComplete:^(NSDictionary *returnData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([returnData objectForKey:@"data"])
                {
                    User *user = [returnData objectForKey:@"data"];
                    NSLog(@"userinfo %@",user);
                    [self setUserInfo:user];
                    [self updateMyInfomationUI];
                    [self SetPhotosCollectionData];
                    NSLog(@"collection view height%f",self.containerViewController.currentViewController.view.frame.size.height);
                    [self.scrollContentViewHeightConstraint setConstant:[self scrollContentViewHeight]];
                    [self.scrollContentView setNeedsLayout];
                    [self.scrollContentView layoutIfNeeded];
                   
                    
                }
                else if ([returnData objectForKey:@"error"])
                {
                    [SVProgressHUD showErrorWithStatus:@"获取个人信息失败"];
                }
                if ([self.refreshControl isRefreshing])
                {
                    [self.refreshControl endRefreshing];
                }
                self.shouldRefreshData = true;
                
            });
        }];

    });


}

#pragma mark - gesture and action
-(void)configGesture
{
    self.followersNumLabel.userInteractionEnabled = YES;
    self.followsNumLabel.userInteractionEnabled = YES;
    
    self.followersLabel.userInteractionEnabled = YES;
    self.followsLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *followsCilck = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(followsShow:)];
    [self.followsNumLabel addGestureRecognizer:followsCilck];
    UITapGestureRecognizer *followsLabelClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(followsShow:)];
    [self.followsLabel addGestureRecognizer:followsLabelClick];
    
    //[self.followsLabel addGestureRecognizer:followsCilck];
    UITapGestureRecognizer *followersClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(followersShow:)];
    [self.followersNumLabel addGestureRecognizer:followersClick];
    UITapGestureRecognizer *followersLabelClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(followersShow:)];
    [self.followersLabel addGestureRecognizer:followersLabelClick];
    
}

-(void)photoListShow:(UITapGestureRecognizer *)gesture
{
    
}

-(void)followsShow:(UITapGestureRecognizer *)gesture
{
    UIStoryboard *userListStoryBoard = [UIStoryboard storyboardWithName:@"UserList" bundle:nil];
    UserListTableViewController *followsList = [userListStoryBoard instantiateViewControllerWithIdentifier:@"userListTableView"];
    
    NSInteger userId = self.userInfo.UserID;
    NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[QDYHTTPClient sharedInstance]GetPersonalFollowsListWithUserId:userId currentUserId:myUserId whenComplete:^(NSDictionary *returnData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([returnData objectForKey:@"data"])
                {

                    [followsList setUserListStyle:UserListStyle2];
                    [followsList setDatasource:[returnData objectForKey:@"data"]];
                    [followsList.tableView reloadData];
                    if (userId == myUserId)
                    {
                        [followsList setTitle:@"我关注的"];
                    }
                    else
                    {
                        [followsList setTitle:[NSString stringWithFormat:@"%@关注的",self.userInfo.UserName]];
                    }
                    
                }
                else if ([returnData objectForKey:@"error"])
                {
                    [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
                    
                }
            });

        }];
    });

    [self pushToViewController:followsList animated:YES hideBottomBar:YES];


    
}

-(void)followersShow:(UITapGestureRecognizer *)gesture

{
    UIStoryboard *userListStoryBoard = [UIStoryboard storyboardWithName:@"UserList" bundle:nil];
    UserListTableViewController *followersList = [userListStoryBoard instantiateViewControllerWithIdentifier:@"userListTableView"];
    [followersList setUserListStyle:UserListStyle2];
    NSInteger userId = self.userInfo.UserID;
    NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[QDYHTTPClient sharedInstance]GetPersonalFollowersListWithUserId:userId currentUserId:myUserId whenComplete:^(NSDictionary *returnData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([returnData objectForKey:@"data"])
                {

                    [followersList setDatasource:[returnData objectForKey:@"data"]];
                    [followersList.tableView reloadData];
                    if (userId == myUserId)
                    {
                        [followersList setTitle:@"关注我的"];
                    }
                    else
                    {
                        [followersList setTitle:[NSString stringWithFormat:@"关注%@的",self.userInfo.UserName]];
                    }
                   
                }
                else if ([returnData objectForKey:@"error"])
                {
                    [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
                    
                }
            });

        }];
    });
    [self pushToViewController:followersList animated:YES hideBottomBar:YES];

    
}

- (void) personalAvatarClick
{
    if (self.userInfo.UserID == [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
        
        EditPersonalInfoTableViewController *editViewController = [storyboard instantiateViewControllerWithIdentifier:@"editPersonalInfo"];
        editViewController.userInfo = self.userInfo;
        [self pushToViewController:editViewController animated:YES hideBottomBar:YES];
    }
    
}
-(void)backGroundImageClick:(UIGestureRecognizer *)gesture
{
    
    if (self.userInfo.UserID == [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"])
    {
        UIActionSheet *choiceSheet = [[UIActionSheet alloc]initWithTitle:@"更新个人封面" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册中选取",@"恢复默认背景", nil];
        [choiceSheet showInView:self.view];
   
    }
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
            [self pushToViewController:editViewController animated:YES hideBottomBar:YES];
            
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
                            self.userInfo.followType = FOLLOWED;
                            [myBtn setWhiteFrameTransparentAppearence];
                            
                        }
                        else if ([result objectForKey:@"error"])
                        {
                            [SVProgressHUD showErrorWithStatus:[result objectForKey:@"error"]];
                        }
                    });

                }];
            });

        }
        else if ([myBtn.titleLabel.text  isEqualToString:@"已关注"]||[myBtn.titleLabel.text  isEqualToString:@"互相关注"])
        {
            NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[QDYHTTPClient sharedInstance]unFollowUser:self.userInfo.UserID withUserId:myUserId whenComplete:^(NSDictionary *result) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                if ([result objectForKey:@"data"])
                {
                    //[SVProgressHUD showInfoWithStatus:@"关注成功"];
                    [myBtn setTitle:@"关注" forState:UIControlStateNormal];
                    self.userInfo.followType = UNFOLLOW;
                    [myBtn setThemeBackGroundWhiteFrameAppearance];
                    
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


#pragma mark - button action

-(void)backButtonClick:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)settingButtonClick:(UIButton *)button
{
    [self personalAvatarClick];
}

-(void)myPhotosButtonClick:(UIButton *)sender
{
    [self.myPhotosNumLabel setHighlighted:YES];
    [self.myPhotosLabel setHighlighted:YES];
    [self.myAddressNumLabel setHighlighted:NO];
    [self.myAddressLabel setHighlighted:NO];
    [self.containerViewController swapViewControllersWithIdentifier:SEGUEFIRST];
    [self.scrollContentViewHeightConstraint setConstant:[self scrollContentViewHeight]];
    [self.scrollContentView setNeedsLayout];
    [self.scrollContentView layoutIfNeeded];
}
-(void)myAddressButtonClick:(UIButton *)sender
{
    [self.myPhotosNumLabel setHighlighted:NO];
    [self.myPhotosLabel setHighlighted:NO];
    [self.myAddressNumLabel setHighlighted:YES];
    [self.myAddressLabel setHighlighted:YES];
    [self.containerViewController swapViewControllersWithIdentifier:SEGUESECOND];
    [self.scrollContentViewHeightConstraint setConstant:[self scrollContentViewHeight]];
    [self.scrollContentView setNeedsLayout];
    [self.scrollContentView layoutIfNeeded];
    
}
-(void)myMapButtonClick:(UIButton *)sender
{
    if (!self.addressMarkViewController)
    {
        self.addressMarkViewController = [[AddressMarkViewController alloc]init];
    }
    [[POISearchAPI sharedInstance]getUserPOIsWithUserId:self.userInfo.UserID whenComplete:^(NSDictionary *returnData)
     {
         if ([returnData objectForKey:@"data"])
         {
             self.addressMarkViewController.locations = [returnData objectForKey:@"data"];
             [self.addressMarkViewController addAnnotations];
         }
         else if ([returnData objectForKey:@"error"])
         {
             [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
         }
         if ([self.refreshControl isRefreshing])
         {
             [self.refreshControl endRefreshing];
         }
         
         
     }];
    self.navigationController.navigationBarHidden = YES;
    [self pushToViewController:self.addressMarkViewController animated:YES hideBottomBar:YES];

    
}

#pragma mark - commonContainerViewController delegate

-(void)finishLoadChildController:(UIViewController *)childController
{
    if ([childController isKindOfClass: [PhotosCollectionViewController class]])
    {
        self.myPhotoCollectionViewController = (PhotosCollectionViewController *)childController;
        [self.myPhotoCollectionViewController.collectionView setBackgroundColor:[UIColor whiteColor]];
        [self.myPhotoCollectionViewController.collectionView setScrollEnabled:NO];
        [self.myPhotoCollectionViewController.collectionView setScrollsToTop:NO];
        self.myPhotoCollectionViewController.detailStyle = DETAIL_STYLE_SINGLEPAGE;
        self.myPhotoCollectionViewController.dataSource = self;
        [self SetPhotosCollectionData];
  
        
    }
    else if( [childController isKindOfClass:[FootPrintTableViewController class]])
    {
        
        self.myFootPrintViewController = (FootPrintTableViewController *)childController;
        [self.myFootPrintViewController.tableView setScrollEnabled:NO];
        self.myFootPrintViewController.currentUser = self.userInfo;
        [self SetAddressListData];
    }
}

#pragma mark - control the model



-(void) updateMyInfomationUI
{
    if ([self.userInfo.UserName isEqualToString:@""])
    {
        self.userNameLabel.text = @"个人主页";
        self.tabBarController.navigationItem.title = @"个人主页";
        self.navigationItem.title = @"个人主页";
    }
    else
    {
        self.userNameLabel.text = self.userInfo.UserName;
    }
    if (self.userInfo.avatarImageURLString)
    {
        [self.avator sd_setImageWithURL:[NSURL URLWithString:self.userInfo.avatarImageURLString] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
    }
    if (self.userInfo.backGroundImage && ![self.userInfo.backGroundImage isEqualToString:@""])
    {
        [self.placeHolderImageView sd_setImageWithURL:[NSURL URLWithString:self.userInfo.backGroundImage] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            self.coverImage = image;
        }];
       // [self.scrollView.blurCoverView setImageWithUrl:self.userInfo.backGroundImage];
    }
    else
    {
        self.coverImage = [UIImage imageNamed:@"cover.png"];
    }

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSInteger myUserId = [ud integerForKey:@"userId"];
    if (myUserId == self.userInfo.UserID)
    {
        [self.mineButton setHidden:YES];
    }
    else
    {
        [self.mineButton setHidden:NO];
        if (self.userInfo.followType == UNFOLLOW)
        {
            
            [self.mineButton setTitle:@"关注" forState:UIControlStateNormal];
            [self.mineButton setThemeBackGroundWhiteFrameAppearance];
        }
        else if (self.userInfo.followType == FOLLOWED)
        {
            [self.mineButton setTitle:@"已关注" forState:UIControlStateNormal];
            [self.mineButton setWhiteFrameTransparentAppearence];
        }
        else if (self.userInfo.followType == FOLLOWEACH)
        {
            [self.mineButton setTitle:@"互相关注" forState:UIControlStateNormal];
            [self.mineButton setWhiteFrameTransparentAppearence];
        }
        else
        {
            [self.mineButton setTitle:@"  " forState:UIControlStateNormal];
            [self.mineButton setBackgroundColor:[UIColor grayColor]];
            
        }
    }
    self.myAddressNumLabel.text = [NSString stringWithFormat:@"%lu",self.userInfo.poiNum ? (unsigned long)self.userInfo.poiNum : 0];
    self.myPhotosNumLabel.text =[NSString stringWithFormat:@"%lu", self.userInfo.photosNumber ? (unsigned long)self.userInfo.photosNumber:0];
    
    self.followersNumLabel.text =[NSString stringWithFormat:@"%lu", self.userInfo.numFollowers ? (unsigned long)self.userInfo.numFollowers:0];
    [self adaptFollowersLabels];
    self.followsNumLabel.text = [NSString stringWithFormat:@"%lu", self.userInfo.numFollows ? (unsigned long)self.userInfo.numFollows:0];
    [self adaptFollowsLabels];
    
    self.selfDescriptionLabel.text = self.userInfo.selfDescriptions ? [self.userInfo.selfDescriptions stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"]:@"";
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    [self.scrollView setContentOffset:CGPointMake(0, -19) animated:YES];
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
       // self.photoCollectionCurrentPage = 1;
        for (WhatsGoingOn *item in self.userInfo.photoList)
        {
            [_myPhotosCollectionDatasource addObject:item];
        }
        
    }
    [self.myPhotoCollectionViewController setDatasource:_myPhotosCollectionDatasource];
    [self.myPhotoCollectionViewController loadData];
}

-(void)addMorePhotoCollectionDataWith:(NSArray *)data
{
    for (WhatsGoingOn *item in data)
    {
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
                            [self.scrollContentViewHeightConstraint setConstant:[self scrollContentViewHeight]];
                            [self.view setNeedsLayout];
                            [self.view layoutIfNeeded];
                            if (_footLabel)
                            {
                                [_footLabel setHidden:YES];
                            }
                        }
                        else
                        {
                            NSLog(@"no more data");
                            if (!_footLabel)
                            {
                                float tabbarHeight = 0;
                                if (self.userInfo.UserID == [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"])
                                {
                                    tabbarHeight = 40;
                                }
                        
                                _footLabel = [[UILabel alloc]init];
                                _footLabel.text = @"没有更多照片了";
                                _footLabel.textColor = THEME_COLOR_DARK_GREY_PARENT;
                                _footLabel.font = WZ_FONT_COMMON_SIZE;
                                _footLabel.textAlignment = NSTextAlignmentCenter;
                                [self.containerViewController.currentViewController.view addSubview:_footLabel];
                            
                            }
                            [_footLabel setFrame:CGRectMake(0, self.containerViewController.currentViewController.view.frame.size.height -32, WZ_APP_SIZE.width, 32)];
                            [_footLabel setHidden:NO];
                            
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

//get more data without update the UI
-(void)getMoreCollectionDataWithCompleteBlock:(void (^)(void))whenComplete
{
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
                    }
         
                }
                else if ([returnData objectForKey:@"error"])
                {
                    NSLog(@"get more colleciton Data error");
                }
            });
            
        }];
    });
}


-(void)SetAddressListData
{
    //根据个人信息，获取更多信息
    if (!_myAddressListDatasource)
    {
        UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [aiv setCenter:CGPointMake(WZ_APP_SIZE.width/2, TOPCOVERHEIGHT +36)];
        [self.view addSubview:aiv];
        [aiv startAnimating];
        self.shouldRefreshData = false;
        NSInteger userId = self.userInfo.UserID;
        [[POISearchAPI sharedInstance]getUserPOIsWithUserId:userId whenComplete:^(NSDictionary *returnData) {
            [aiv stopAnimating];
            [aiv removeFromSuperview];
              self.shouldRefreshData = true;
            if ([returnData objectForKey:@"data"])
            {
                _myAddressListDatasource = [returnData objectForKey:@"data"];
                [self.scrollContentViewHeightConstraint setConstant:[self scrollContentViewHeight]];
                [self.scrollContentView setNeedsLayout];
                [self.scrollContentView layoutIfNeeded];
                [self.myFootPrintViewController setDatasource:_myAddressListDatasource];
                [self.myFootPrintViewController loadData];
                [self.scrollView setContentOffset:CGPointMake(0, -20) animated:YES];
            }
            else if ([returnData objectForKey:@"error"])
            {
                [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
            }
            if ([self.refreshControl isRefreshing])
            {
                [self.refreshControl endRefreshing];
            }
        }];
        

    }
    else
    {
        [self.scrollContentViewHeightConstraint setConstant:[self scrollContentViewHeight]];
        [self.scrollContentView setNeedsLayout];
        [self.scrollContentView layoutIfNeeded];
        [self.myFootPrintViewController setDatasource:_myAddressListDatasource];
        [self.myFootPrintViewController loadData];
    }

}

-(void)getLatestData
{
   
    if (self.shouldRefreshData)
    {
        if ([self.containerViewController.currentViewController isEqual:self.myPhotoCollectionViewController])
        {
            [self setPersonalInfo];
        }
        else if ([self.containerViewController.currentViewController isEqual:self.myFootPrintViewController])
        {
            self.myAddressListDatasource = nil;
            [self SetAddressListData];
        }
    }
    else
    {
        if([self.refreshControl isRefreshing])
        {
            [self.refreshControl endRefreshing];
        }
    }
}

-(void)deleteMyPhotos:(NSNotification *)notification
{
    NSLog(@"%@",notification);
    NSInteger postId =[(NSNumber *) [[notification userInfo] objectForKey:@"postId"]integerValue];
    [self.userInfo.photoList enumerateObjectsUsingBlock:^(WhatsGoingOn * item, NSUInteger idx, BOOL *stop) {
        if ( item.postId == postId)
        {
            [self.userInfo.photoList removeObject:item];
            *stop = YES;
        }
    }];
    [self SetPhotosCollectionData];
}
-(void)clearUserInfo
{
    self.userInfo = nil;
    self.myPhotosCollectionDatasource = nil;
    self.myAddressListDatasource = nil;
    [self.myPhotoCollectionViewController loadData];
}
-(void)updateUserInfo
{
    [self setPersonalInfo];
}

#pragma mark - scrollview delegate
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGPoint loadMorePoint = CGPointMake(0, self.scrollView.contentSize.height);
    CGPoint targetPoint = *targetContentOffset;
    NSLog(@"app size.hight :%f",WZ_APP_SIZE.height);
    if (targetPoint.y > loadMorePoint.y -WZ_APP_SIZE.height-41 )
    {
        [self loadMoreCollectionData];
        
    }
}
#pragma mark - photosCollectionView datasource
-(NSInteger)numberOfPhotos:(PhotosCollectionViewController *)collectionViews
{
    return _myPhotosCollectionDatasource.count;
}
-(WhatsGoingOn *)PhotosCollectionViewController:(PhotosCollectionViewController *)detailViews dataAtIndex:(NSInteger)index
{
    __block WhatsGoingOn *item;
    if (index<_myPhotosCollectionDatasource.count)
    {
        return _myPhotosCollectionDatasource[index];
    }
    if (index>= _myPhotosCollectionDatasource.count)
    {
         
      [self getMoreCollectionDataWithCompleteBlock:^{
          if (index > _myPhotosCollectionDatasource.count)
          {
              item = nil;
          }
          else
          {
              item = _myPhotosCollectionDatasource[index];
          }
      }];
        
    }
    WhatsGoingOn *result = item;
    return result;

   
}
-(NSArray *)PhotosCollectionViewController:(PhotosCollectionViewController *)collectionView moreData:(NSInteger)page
{
    NSMutableArray *datas = [[NSMutableArray alloc]init];
    return datas;
}

#pragma mark ---UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSMutableArray *mediaTypes = [[NSMutableArray alloc]init];
    [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
    if (buttonIndex ==0)
    {
        NSLog(@"select camera");
        if ([CameraUtility isCameraAvailable] && [CameraUtility doesCameraSupportTakingPhotos])
        {
            UIImagePickerController *controller = [[UIImagePickerController alloc]init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ( [CameraUtility isFrontCameraAvailable])
            {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller animated:YES completion:^{
                NSLog(@"camera view controller is presented");
            }];
        }
    }
    else if (buttonIndex == 1)
    {
        NSLog(@"select photo library");
        if ([CameraUtility isPhotoLibraryAvailable])
        {
            UIImagePickerController *controller = [[UIImagePickerController alloc]init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller animated:YES completion:^{
                NSLog(@"picker view controller  is presented");
            }];
        }
    }
    else if (buttonIndex == 2)
    {
        NSInteger userId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"backGroundPath"];
        self.coverImage = [UIImage imageNamed:@"cover.png"];
        
        [self.scrollView setContentOffset:CGPointMake(0, -20) animated:YES];
        [[QDYHTTPClient sharedInstance]PostBackGroundImageWithUserId:userId backgroundName:@"" whenComplete:^(NSDictionary *returnData)
         {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 if ([returnData objectForKey:@"data"])
                 {
                     //上传图片成功
                    // [SVProgressHUD showInfoWithStatus:@"修改背景图片成功"];
                 }
                 else if ([returnData objectForKey:@"error"])
                 {
                    // [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
                 }
                 
             });
             
             
         }];

        //恢复默认图片
    }
}

#pragma mark ----UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        if(!_aiv)
        {
            _aiv = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [_aiv setFrame:CGRectMake(WZ_APP_SIZE.width - _aiv.frame.size.width -8, 48, _aiv.frame.size.width, _aiv.frame.size.height)];
            [self.scrollView addSubview:_aiv];
           
        }
        [_aiv startAnimating];
        UIImage *backGroundImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        self.coverImage = [UIImage imageWithCGImage:[backGroundImage CGImage] scale:0.6f orientation:UIImageOrientationUp];
        [self.scrollView setContentOffset:CGPointMake(0, -20) animated:YES];
        NSInteger userId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
        [[QDYHTTPClient sharedInstance]GetQiNiuTokenWithUserId:userId type:3 whenComplete:^(NSDictionary *returnData) {
            NSDictionary *data;
            if ([returnData objectForKey:@"data"])
            {
                data = [returnData objectForKey:@"data"];
                NSLog(@"%@",data);
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showErrorWithStatus:@"获取token失败"];
                    return ;
                });
                
            }
            NSData *uploadImageData = UIImageJPEGRepresentation(backGroundImage, 0.6f);
            QNUploadManager *upLoadManager = [[QNUploadManager alloc]init];
            [upLoadManager putData:uploadImageData key:[data objectForKey:@"imageName"] token:[data objectForKey:@"uploadToken"] complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp)
             {
                 NSLog(@"%@",info);
                 if (info.error)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [SVProgressHUD showErrorWithStatus:@"上传图片失败"];
                     });
                 }
                 else
                 {
                     [[QDYHTTPClient sharedInstance]PostBackGroundImageWithUserId:userId backgroundName:[data objectForKey:@"imageName"] whenComplete:^(NSDictionary *returnData)
                      {
                          
                          dispatch_async(dispatch_get_main_queue(), ^{
                               [_aiv stopAnimating];
                              if ([returnData objectForKey:@"data"])
                              {
                                  [SVProgressHUD showInfoWithStatus:@"修改背景图片成功"];
                              }
                              else if ([returnData objectForKey:@"error"])
                              {
                                  [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
                              }
                              
                          });
                          
                          
                      }];
                     
                 }
                 
                 
             } option:nil];
        }];

        
    }];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}



@end
