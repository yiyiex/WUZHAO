//
//  MineViewController.m
//  Dtest3
//
//  Created by yiyi on 14-11-6.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#define TOPCOVERHEIGHT 248
#define kNavBarHeight 64
#define kAvatarWidth 86
#define kAvatarVerticalOffset 28
#define kFollowsLabelOffset 62

#import "MineViewController.h"

#import "PhotosCollectionViewController.h"
#import "FootPrintTableViewController.h"
#import "FootPrintCollectionViewController.h"
#import "AddressMarkViewController.h"

#import "PrivateLetterDetailViewController.h"

#import "UserListTableViewController.h"
#import "EditPersonalInfoTableViewController.h"

#import "UIViewController+Basic.h"

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
#import "PrivateLetter.h"

#import "QiniuSDK.h"

#define SEGUEFIRST @"segueForPhotosColletion"
#define SEGUESECOND @"segueForAddressTable"

@interface MineViewController () <CommonContainerViewControllerDelegate,UIScrollViewDelegate,UIActionSheetDelegate ,UIImagePickerControllerDelegate>
{
    CGPoint scrollViewInitContentOffset;
    UIView *greyMaskView;
    UIImageView *bigImageView;
    CGRect selectImageFrame;
    CGPoint selectImageCenter;
}

@property (nonatomic, strong) UIView *navigationBar;
@property (strong, nonatomic) UIButton *mineButton;
@property (strong, nonatomic) UIButton *sendMessageButton;

@property (nonatomic, strong) UIView *backGroundView;
@property (strong, nonatomic) UILabel *followsNumLabel;
@property (strong, nonatomic) UILabel *followsLabel;
@property (strong, nonatomic) UILabel *followersNumLabel;
@property (strong, nonatomic) UILabel *followersLabel;
@property (nonatomic, strong) UILabel *seperateLabel;

@property (nonatomic, strong) UILabel *myPhotosNumLabel;
@property (nonatomic, strong) UILabel *myPhotosLabel;

@property (nonatomic, strong) UILabel *myAddressNumLabel;
@property (nonatomic, strong) UILabel *myAddressLabel;

//@property (nonatomic, strong) UIButton *myPhotosButton;
//@property (nonatomic, strong) UIButton *myAddressButton;
@property (nonatomic, strong) UIButton *myMapButton;
@property (nonatomic, strong) UIActivityIndicatorView *aiv;

@property (nonatomic, strong) CommonContainerViewController *containerViewController;

@property (nonatomic, weak) PhotosCollectionViewController *myPhotoCollectionViewController;
@property (nonatomic) NSInteger photoCollectionCurrentPage;
@property (nonatomic)float currentCollectionViewOffset;

@property (nonatomic, weak) FootPrintCollectionViewController *myFootPrintViewController;
//@property (nonatomic, weak) FootPrintTableViewController *myFootPrintViewController;
@property (nonatomic) NSInteger footPrintCurrentPage;
@property (nonatomic) float currentFootPrintViewOffset;

@property (nonatomic, strong) AddressMarkViewController *addressMarkViewController;

@property (nonatomic, strong) UserListTableViewController *followsList;
@property (nonatomic, strong) UserListTableViewController *followersList;

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
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refreshByPullingTable:) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:self.refreshControl];
    
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
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

-(UIImageView *)placeHolderImageView
{
    if (!_placeHolderImageView)
    {
        _placeHolderImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -100, 20, 20)];
        [self.view addSubview:_placeHolderImageView];
        
    }
    return _placeHolderImageView;
}

-(UIActivityIndicatorView *)aiv
{
    if (!_aiv)
    {
        _aiv = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.scrollView addSubview:_aiv];
    }
    return _aiv;
}

-(float)scrollContentViewHeight
{
    float topHeight = TOPCOVERHEIGHT ;
    __block float bottomHeight = 44;
    if (self.myPhotosLabel.highlighted)
    {
        if (_myPhotosCollectionDatasource.count >6)
        {
             bottomHeight += (ceil((float)_myPhotosCollectionDatasource.count/3)) * WZ_APP_SIZE.width/3 ;
        }
        else
        {
            //bottomHeight = 4*WZ_APP_SIZE.width/3;
            bottomHeight = WZ_APP_SIZE.height -topHeight +30;
        }
    }
    else if (self.myAddressLabel.highlighted)
    {
        if (self.myAddressListDatasource.count>2)
        {
            bottomHeight += (ceil((float)_myAddressListDatasource.count/2))*((WZ_APP_SIZE.width-24)/2+24+8);
        }
        else
        {
            bottomHeight = WZ_APP_SIZE.height - topHeight +30;
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
    if ([self.userInfo.selfDescriptions isEqualToString:@""])
    {
        frame.origin.y -=20;
    }
    frame.size.height = 20;
    [self.followsNumLabel setFrame:frame];
    
    [self.followsLabel sizeToFit];
    CGRect followsFrame = self.followsLabel.frame;
    
    followsFrame.origin.x = frame.origin.x - 8 - followsFrame.size.width;
    followsFrame.origin.y = kAvatarVerticalOffset + kAvatarWidth + kFollowsLabelOffset;
    [self.seperateLabel setFrame:CGRectMake(WZ_APP_SIZE.width/2-4, kAvatarVerticalOffset + kAvatarWidth + kFollowsLabelOffset , 8,22)];
    if ([self.userInfo.selfDescriptions isEqualToString:@""])
    {
        followsFrame.origin.y -=20;
        [self.seperateLabel setFrame:CGRectMake(WZ_APP_SIZE.width/2-4, kAvatarVerticalOffset + kAvatarWidth + kFollowsLabelOffset - 20 , 8,22)];
    }
    followsFrame.size.height = 20;
    [self.followsLabel setFrame:followsFrame];
}

-(void)adaptFollowersLabels
{
    [self.followersLabel sizeToFit];
    CGRect frame = self.followersLabel.frame;
    frame.origin.x = WZ_APP_SIZE.width/2 + 8 ;
    frame.origin.y = kAvatarVerticalOffset + kAvatarWidth + kFollowsLabelOffset;
    if ([self.userInfo.selfDescriptions isEqualToString:@""])
    {
        frame.origin.y -=20;
    }
    frame.size.height = 20;
    [self.followersLabel setFrame:frame];
    
    [self.followersNumLabel sizeToFit];
    CGRect followersNumFrame = self.followersNumLabel.frame;
    
    followersNumFrame.origin.x = frame.origin.x + frame.size.width +8;
    followersNumFrame.origin.y = kAvatarVerticalOffset + kAvatarWidth + kFollowsLabelOffset;
    [self.seperateLabel setFrame:CGRectMake(WZ_APP_SIZE.width/2-4, kAvatarVerticalOffset + kAvatarWidth + kFollowsLabelOffset , 8,22)];
    if ([self.userInfo.selfDescriptions isEqualToString:@""])
    {
        followersNumFrame.origin.y -=20;
        [self.seperateLabel setFrame:CGRectMake(WZ_APP_SIZE.width/2-4, kAvatarVerticalOffset + kAvatarWidth + kFollowsLabelOffset - 20 , 8,22)];
    }
    followersNumFrame.size.height = 20;
    [self.followersNumLabel setFrame:followersNumFrame];
}

-(void)initView
{
    
    float avatarVerticalOffset = kAvatarVerticalOffset;
    float avatarViewWidth = kAvatarWidth;
    float followsLabelOffset = kFollowsLabelOffset;
    float buttonWidth = 48;
    float labelHeight = 22;
    float verticalSpacing = 8;
    
    [self.view setBackgroundColor:[UIColor colorWithWhite:238 alpha:1.0f]];


    //avatar
    self.avator = [[UIImageView alloc]initWithFrame:CGRectMake((WZ_APP_SIZE.width - avatarViewWidth)/2 , avatarVerticalOffset, avatarViewWidth, avatarViewWidth)];
    [self.avator setRoundAppearance];
    [self.avator setBackgroundColor:THEME_COLOR_LIGHT_GREY_MORE_PARENT];
    UITapGestureRecognizer *avatarTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(personalAvatarClick)];
    [self.avator addGestureRecognizer:avatarTapGesture];
    [self.avator setUserInteractionEnabled:YES];
    [self.scrollView addSubview:self.avator];
    
    //usernameLabel
    self.userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, avatarVerticalOffset + avatarViewWidth + verticalSpacing, WZ_APP_SIZE.width - 40, labelHeight)];
    [self.userNameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.userNameLabel setTextColor:THEME_COLOR_FONT_BLACK];
    [self.userNameLabel setFont:[UIFont systemFontOfSize:20]];
    [self.scrollView addSubview:self.userNameLabel];
    
    //private letter button
    self.sendMessageButton = [[UIButton alloc]initWithFrame:CGRectMake((WZ_APP_SIZE.width + avatarViewWidth)/2 + 28,avatarVerticalOffset + avatarViewWidth - 48,36,36)];
    [self.sendMessageButton setHidden:YES];
    self.sendMessageButton.layer.borderWidth = 1.5f;
    self.sendMessageButton.layer.cornerRadius = 18.0f;
    self.sendMessageButton.layer.borderColor = [THEME_COLOR_LIGHT_GREY_BIT_PARENT CGColor];
    self.sendMessageButton.layer.masksToBounds = YES;
    [self.sendMessageButton addTarget:self action:@selector(sendMessageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendMessageButton setImage:[UIImage imageNamed:@"letter_bubble"] forState:UIControlStateNormal];
    //[self.sendMessageButton setTitle:@"私信" forState:UIControlStateNormal];
    [self.scrollView addSubview:self.sendMessageButton];
    
    //myButton
    self.mineButton = [[UIButton alloc]initWithFrame:CGRectMake((WZ_APP_SIZE.width- avatarViewWidth)/2 - 64, avatarVerticalOffset + avatarViewWidth - 48, 36, 36)];
    [self.scrollView addSubview:self.mineButton];

    [self.mineButton setHidden:YES];
    self.mineButton.layer.borderWidth = 1.5f;
    self.mineButton.layer.cornerRadius = 18.0f;
    self.mineButton.layer.borderColor = [THEME_COLOR_LIGHT_GREY_BIT_PARENT CGColor];
    self.mineButton.layer.masksToBounds = YES;
    [self.mineButton addTarget:self action:@selector(MineButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //self description
    self.selfDescriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, self.userNameLabel.frame.origin.y + labelHeight , WZ_APP_SIZE.width - 16 , 36)];
    [self.scrollView addSubview:self.selfDescriptionLabel];
    [self.selfDescriptionLabel setTextColor:THEME_COLOR_FONT_GREY];
    [self.selfDescriptionLabel setFont:WZ_FONT_COMMON_SIZE];
    [self.selfDescriptionLabel setTextAlignment:NSTextAlignmentCenter];
    [self.selfDescriptionLabel setNumberOfLines:2];
    
    //follows and followers
    self.followsLabel = [[UILabel alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width/2 - 44 - 50, kAvatarVerticalOffset + kAvatarWidth + kFollowsLabelOffset, 50, labelHeight)];
    self.followsNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width/2 - 40, kAvatarVerticalOffset + kAvatarWidth + kFollowsLabelOffset  , 40, labelHeight)];
    [self.followsNumLabel setText:@"0"];
    [self.followsNumLabel setTextAlignment:NSTextAlignmentLeft];
    [self.followsNumLabel setFont:WZ_FONT_SMALL_SIZE];
    [self.followsNumLabel setTextColor:THEME_COLOR_FONT_BLACK];
    [self.followsLabel setText:@"关注了"];
    [self.followsLabel setTextAlignment:NSTextAlignmentRight];
    [self.followsLabel setFont:WZ_FONT_SMALL_SIZE];
    [self.followsLabel setTextColor:THEME_COLOR_FONT_GREY];
    [self.scrollView addSubview:self.followsLabel];
    [self.scrollView addSubview:self.followsNumLabel];
    
    UILabel *seperateLabel = [[UILabel alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width/2-4, avatarVerticalOffset + avatarViewWidth + followsLabelOffset , 8, labelHeight)];
    [seperateLabel setText:@"/"];
    [seperateLabel setTextAlignment:NSTextAlignmentCenter];
    [seperateLabel setTextColor:THEME_COLOR_FONT_GREY];
    [seperateLabel setFont:WZ_FONT_COMMON_SIZE];
    self.seperateLabel = seperateLabel;
    [self.scrollView addSubview:seperateLabel];
    
    self.followersNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width/2 + 58, kAvatarVerticalOffset + kAvatarWidth + kFollowsLabelOffset, 40, labelHeight)];
    self.followersLabel = [[UILabel alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width/2 + 10 , kAvatarVerticalOffset + kAvatarWidth + kFollowsLabelOffset, 40, labelHeight)];
    [self.followersNumLabel setText:@"0"];
    [self.followersNumLabel setTextAlignment:NSTextAlignmentLeft];
    [self.followersNumLabel setFont:WZ_FONT_SMALL_SIZE];
    [self.followersNumLabel setTextColor:THEME_COLOR_FONT_BLACK];
    [self.followersLabel setText:@"关注者"];
    [self.followersLabel setTextAlignment:NSTextAlignmentLeft];
    [self.followersLabel setFont:WZ_FONT_SMALL_SIZE];
    [self.followersLabel setTextColor:THEME_COLOR_FONT_GREY];
    [self.scrollView addSubview:self.followersLabel];
    [self.scrollView addSubview:self.followersNumLabel];
    
    //init tabbar
    
    self.backGroundView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPCOVERHEIGHT - 50, WZ_APP_SIZE.width, 49)];
    [self.backGroundView setBackgroundColor:[UIColor colorWithWhite:238 alpha:1.0f]];
    [self.scrollView addSubview:self.backGroundView];
    
    [PhotoCommon drawALineWithFrame:CGRectMake(4, 0, self.backGroundView.frame.size.width - 8, 0.6) andColor:THEME_COLOR_LIGHT_GREY_BIT_PARENT inLayer:self.backGroundView.layer];
    [PhotoCommon drawALineWithFrame:CGRectMake(4, self.backGroundView.frame.size.height-0.6, self.backGroundView.frame.size.width - 8, 0.6) andColor:THEME_COLOR_LIGHT_GREY_BIT_PARENT inLayer:self.backGroundView.layer];
    /*
    //draw button lines
    [PhotoCommon drawALineWithFrame:CGRectMake(WZ_APP_SIZE.width/3, TOPCOVERHEIGHT - 36 , 0.6, 24) andColor:THEME_COLOR_WHITE inLayer:self.scrollView.layer];
    [PhotoCommon drawALineWithFrame:CGRectMake(WZ_APP_SIZE.width/3*2, TOPCOVERHEIGHT - 36 , 0.6, 24) andColor:THEME_COLOR_WHITE inLayer:self.scrollView.layer];
    */
    
    float tabbarLabelWidth = WZ_APP_SIZE.width/3;
    self.myPhotosNumLabel = [[UILabel alloc]initWithFrame:CGRectMake((WZ_APP_SIZE.width/3 - tabbarLabelWidth)/2, TOPCOVERHEIGHT - (labelHeight)*2 , tabbarLabelWidth, labelHeight)];
    self.myPhotosLabel = [[UILabel alloc]initWithFrame:CGRectMake((WZ_APP_SIZE.width/3 - tabbarLabelWidth)/2, TOPCOVERHEIGHT - labelHeight-4 , tabbarLabelWidth, labelHeight)];
    [self.myPhotosNumLabel setText:@"0"];
    [self.myPhotosNumLabel setTextAlignment:NSTextAlignmentCenter];
    [self.myPhotosNumLabel setFont:WZ_FONT_LARGER_SIZE];
    [self.myPhotosNumLabel setTextColor:THEME_COLOR_FONT_DARK_GREY];
    [self.myPhotosNumLabel setHighlightedTextColor:THEME_COLOR_FONT_BLACK];
    [self.myPhotosLabel setText:@"发布"];
    [self.myPhotosLabel setTextAlignment:NSTextAlignmentCenter];
    [self.myPhotosLabel setFont:WZ_FONT_SMALL_SIZE];
    [self.myPhotosLabel setTextColor:THEME_COLOR_FONT_GREY];
    [self.myPhotosLabel setHighlightedTextColor:THEME_COLOR_FONT_DARK_GREY];
    UITapGestureRecognizer *myPhotoNumLabelTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myPhotosButtonClick:)];
    [self.myPhotosNumLabel addGestureRecognizer:myPhotoNumLabelTap];
    [self.myPhotosNumLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *myPhotoLabelTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myPhotosButtonClick:)];
    [self.myPhotosLabel addGestureRecognizer:myPhotoLabelTap];
    [self.myPhotosLabel setUserInteractionEnabled:YES];
    
    [self.scrollView addSubview:self.myPhotosNumLabel];
    [self.scrollView addSubview:self.myPhotosLabel];
    
    self.myAddressNumLabel = [[UILabel alloc]initWithFrame:CGRectMake((WZ_APP_SIZE.width/3 - tabbarLabelWidth)/2 + WZ_APP_SIZE.width/3 , TOPCOVERHEIGHT - (labelHeight )*2 , tabbarLabelWidth, labelHeight)];
    self.myAddressLabel = [[UILabel alloc]initWithFrame:CGRectMake((WZ_APP_SIZE.width/3 - tabbarLabelWidth)/2 + WZ_APP_SIZE.width/3 , TOPCOVERHEIGHT - labelHeight - 4 , tabbarLabelWidth, labelHeight)];
    [self.myAddressNumLabel setText:@"0"];
    [self.myAddressNumLabel setTextAlignment:NSTextAlignmentCenter];
    [self.myAddressNumLabel setTextColor:THEME_COLOR_FONT_DARK_GREY];
    [self.myAddressNumLabel setFont:WZ_FONT_LARGER_SIZE];
    [self.myAddressNumLabel setHighlightedTextColor:THEME_COLOR_FONT_BLACK];
    [self.myAddressLabel setText:@"地点"];
    [self.myAddressLabel setTextAlignment:NSTextAlignmentCenter];
    [self.myAddressLabel setTextColor:THEME_COLOR_FONT_GREY];
    [self.myAddressLabel setFont:WZ_FONT_SMALL_SIZE];
    [self.myAddressLabel setHighlightedTextColor:THEME_COLOR_FONT_DARK_GREY];
    UITapGestureRecognizer *myAddressNumLabelTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myAddressButtonClick:)];
    [self.myAddressNumLabel addGestureRecognizer:myAddressNumLabelTap];
    [self.myAddressNumLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *myAddressLabelTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myAddressButtonClick:)];
    [self.myAddressLabel addGestureRecognizer:myAddressLabelTap];
    [self.myAddressLabel setUserInteractionEnabled:YES];
    
    [self.scrollView addSubview:self.myAddressNumLabel];
    [self.scrollView addSubview:self.myAddressLabel];
    
    self.myMapButton = [[UIButton alloc]initWithFrame:CGRectMake((WZ_APP_SIZE.width/3 - tabbarLabelWidth)/2 + WZ_APP_SIZE.width/3*2, TOPCOVERHEIGHT - buttonWidth , tabbarLabelWidth, buttonWidth)];
    
    [self.myMapButton setImage:[UIImage imageNamed:@"earth"] forState:UIControlStateNormal];
    [self.myMapButton addTarget:self action:@selector(myMapButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.myMapButton];
    

    //setting button
    UIButton *setting = [[UIButton alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width - 42, 24, 36, 36)];
    [setting setImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
    [setting addTarget:self action:@selector(settingButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.scrollView addSubview:setting];
    
    //back button
    if (self.userInfo )
    {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 20, 36, 36)];
        UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(6, 6, 24, 24)];
        [view addSubview:backButton];
        UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backButtonClick:)];
        [view addGestureRecognizer:tapgesture];
        [view setUserInteractionEnabled:YES];
        [view setRoundAppearance];
        [backButton setBackgroundImage:[UIImage imageNamed:@"back_arrow_bold"] forState:UIControlStateNormal];
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
    [self.mineButton setHidden:YES];
    //[self.mineButton setTitle:@"正在加载..." forState:UIControlStateNormal];
    self.shouldRefreshData = NO;
    
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    if (!_userInfo)
    {
        _userInfo = [[User alloc]init];
        _userInfo.UserID = [[NSUserDefaults standardUserDefaults] integerForKey:@"userId"];
        _userInfo.UserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    }
    [self.aiv setCenter:CGPointMake(self.myPhotosLabel.center.x,  self.myPhotosLabel.center.y-10)];
    [self.myPhotosLabel setHidden:YES];
    [self.myPhotosNumLabel setHidden:YES];
    [self.aiv startAnimating];
    self.photoCollectionCurrentPage = 1;
    NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    [[QDYHTTPClient sharedInstance]GetPersonalInfoWithUserId:self.userInfo.UserID currentUserId:myUserId page:self.photoCollectionCurrentPage whenComplete:^(NSDictionary *returnData) {
        self.shouldRefreshData = YES;
        if ([self.refreshControl isRefreshing])
        {
            [self.refreshControl endRefreshing];
        }
        [self.aiv stopAnimating];
        [self.myPhotosLabel setHidden:NO];
        [self.myPhotosNumLabel setHidden:NO];
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
    }];


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
    self.followsList = followsList;
    [self.followsList setUserListStyle:UserListStyle2];
    NSInteger userId = self.userInfo.UserID;
    NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    if (userId == myUserId)
    {
        [followsList setTitle:@"我关注的"];
    }
    else
    {
        [followsList setTitle:[NSString stringWithFormat:@"%@关注的",self.userInfo.UserName]];
    }
    WEAKSELF_WZ
    followsList.getLatestDataBlock = ^{
        __strong typeof (weakSelf_WZ) strongSelf = weakSelf_WZ;
        if (!strongSelf.followsList.shouldRefreshData)
            return ;
        strongSelf.followsList.shouldRefreshData = NO;
        [[QDYHTTPClient sharedInstance]GetPersonalFollowsListWithUserId:userId currentUserId:myUserId whenComplete:^(NSDictionary *returnData) {
            strongSelf.followsList.shouldRefreshData = YES;
            if ([returnData objectForKey:@"data"])
            {
                [strongSelf.followsList setDatasource:[returnData objectForKey:@"data"]];
                [strongSelf.followsList.tableView reloadData];
                
            }
            else if ([returnData objectForKey:@"error"])
            {
                [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
                
            }
            [strongSelf.followsList endRefreshing];

        }];
    };
    [self pushToViewController:self.followsList animated:YES hideBottomBar:YES];


    
}

-(void)followersShow:(UITapGestureRecognizer *)gesture

{
    UIStoryboard *userListStoryBoard = [UIStoryboard storyboardWithName:@"UserList" bundle:nil];
    UserListTableViewController *followersList = [userListStoryBoard instantiateViewControllerWithIdentifier:@"userListTableView"];
    self.followersList = followersList;
    [followersList setUserListStyle:UserListStyle2];
    NSInteger userId = self.userInfo.UserID;
    NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    if (userId == myUserId)
    {
        [followersList setTitle:@"关注我的"];
    }
    else
    {
        [followersList setTitle:[NSString stringWithFormat:@"关注%@的",self.userInfo.UserName]];
    }
    WEAKSELF_WZ
    self.followersList.getLatestDataBlock = ^{
        __strong typeof (weakSelf_WZ) strongSelf = weakSelf_WZ;
        if (!strongSelf.followersList.shouldRefreshData)
            return ;
        strongSelf.followersList.shouldRefreshData = NO;
        [[QDYHTTPClient sharedInstance]GetPersonalFollowersListWithUserId:userId currentUserId:myUserId whenComplete:^(NSDictionary *returnData) {
            strongSelf.followersList.shouldRefreshData = YES;
            if ([returnData objectForKey:@"data"])
            {

                [strongSelf.followersList setDatasource:[returnData objectForKey:@"data"]];
                [strongSelf.followersList.tableView reloadData];
               
            }
            else if ([returnData objectForKey:@"error"])
            {
                [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
                
            }
            [strongSelf.followersList endRefreshing];

        }];
    };
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
    else
    {
        if (!self.avator.image)
            return;
        NSLog(@"imageView click");
        if (!greyMaskView)
        {
            greyMaskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0 ,self.view.frame.size.width,self.view.frame.size.height)];
            [greyMaskView setBackgroundColor:[UIColor blackColor]];
            [greyMaskView setUserInteractionEnabled:YES];
            UITapGestureRecognizer *greyMaskClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(greyMaskClick:)];
            [greyMaskView addGestureRecognizer:greyMaskClick];
        }
        [self.view addSubview:greyMaskView];
        if (!bigImageView)
        {
            bigImageView= [UIImageView new];
        }
        UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
        UIImageView *imageView = self.avator;
        selectImageFrame = [imageView.superview convertRect:imageView.frame toView:window];
        selectImageCenter = [imageView.superview convertPoint:imageView.center toView:window];
        bigImageView.center = selectImageCenter;
        bigImageView.frame = selectImageFrame;
        UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [aiv setCenter:CGPointMake(WZ_APP_SIZE.width/2, WZ_APP_SIZE.width/2)];
        [aiv startAnimating];
        NSString *bigImageUrl = [self.userInfo.avatarImageURLString substringWithRange:NSMakeRange(0, self.userInfo.avatarImageURLString.length - 4)];
        [bigImageView sd_setImageWithURL:[NSURL URLWithString:bigImageUrl] placeholderImage:imageView.image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [aiv stopAnimating];
            if (aiv.superview)
            {
                [aiv removeFromSuperview];
            }
        }];
        bigImageView.userInteractionEnabled = YES;
        imageView.userInteractionEnabled = NO;
        UITapGestureRecognizer *bigImageClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backToSmallImage:)];
        [bigImageView addGestureRecognizer:bigImageClick];
        
        [self.view addSubview:bigImageView];
        [UIView animateWithDuration:0.5 animations:^{
            bigImageView.frame = CGRectMake(0, (WZ_APP_SIZE.height-WZ_APP_SIZE.width)/2, WZ_APP_SIZE.width, WZ_APP_SIZE.width);
            imageView.userInteractionEnabled = YES;
        }
         completion:^(BOOL finished) {
             [bigImageView addSubview:aiv];
         }];

    }
    
}
-(void)backToSmallImage:(UITapGestureRecognizer *)gesture
{
    UIView *view = bigImageView;
    [UIView animateWithDuration:0.5 animations:^{
        view.frame = selectImageFrame;
        view.center = selectImageCenter;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
        [greyMaskView removeFromSuperview];
    }];
}
-(void)greyMaskClick:(UITapGestureRecognizer *)gesture
{
    UIView *view = bigImageView;
    [UIView animateWithDuration:0.5 animations:^{
        view.frame = selectImageFrame;
        view.center = selectImageCenter;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
        [greyMaskView removeFromSuperview];
    }];
}
-(void)backGroundImageClick:(UIGestureRecognizer *)gesture
{
    
    if (self.userInfo.UserID == [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"])
    {
        UIActionSheet *choiceSheet = [[UIActionSheet alloc]initWithTitle:@"更新个人封面" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册中选取",@"恢复默认背景", nil];
        [choiceSheet showInView:self.view];
   
    }
}

-(void)sendMessageButtonClick:(id)sender
{
    UIStoryboard *feedStoryboard = [UIStoryboard storyboardWithName:@"Feeds" bundle:nil];
    PrivateLetterDetailViewController *conversationPage = [feedStoryboard instantiateViewControllerWithIdentifier:@"conversationView"];
    Conversation *conversation = [[Conversation alloc]init];
    conversation.me.UserID = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    conversation.other = self.userInfo;
    conversationPage.conversation = conversation;
    [self pushToViewController:conversationPage animated:YES hideBottomBar:YES];
}

- (IBAction)MineButtonClick:(id)sender {
    if ( [sender isKindOfClass:[UIButton class]])
    {
        UIButton *myBtn = (UIButton *)sender;
        if (self.userInfo.followType == UNFOLLOW)
        {
            NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [[QDYHTTPClient sharedInstance]followUser:self.userInfo.UserID withUserId:myUserId whenComplete:^(NSDictionary *result) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([result objectForKey:@"data"])
                        {
                            self.userInfo.followType = FOLLOWED;
                            [myBtn setImage:[UIImage imageNamed:@"followed"] forState:UIControlStateNormal];
                            
                        }
                        else if ([result objectForKey:@"error"])
                        {
                            [SVProgressHUD showErrorWithStatus:[result objectForKey:@"error"]];
                        }
                    });

                }];
            });

        }
        else if (self.userInfo.followType == FOLLOWEACH || self.userInfo.followType == FOLLOWED)
        {
            NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[QDYHTTPClient sharedInstance]unFollowUser:self.userInfo.UserID withUserId:myUserId whenComplete:^(NSDictionary *result) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                if ([result objectForKey:@"data"])
                {
                    self.userInfo.followType = UNFOLLOW;
                    [myBtn setImage:[UIImage imageNamed:@"unfollow"] forState:UIControlStateNormal];
                    
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
        self.containerViewController.ChildrenName = @[SEGUEFIRST,SEGUESECOND];
        self.containerViewController.isInteractive = NO;
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
    [self.myAddressNumLabel setHidden:NO];
    [self.myAddressLabel setHidden:NO];
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
    [self.myPhotosNumLabel setHidden:NO];
    [self.myPhotosLabel setHidden:NO];
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
    self.addressMarkViewController.userInfo = self.userInfo;
    [self pushToViewController:self.addressMarkViewController animated:YES hideBottomBar:YES];

    
}

#pragma mark - commonContainerViewController delegate
-(void)beginLoadChildController:(UIViewController *)childController
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
    else if( [childController isKindOfClass:[FootPrintCollectionViewController class]])
    {
       
       // self.myFootPrintViewController = (FootPrintTableViewController *)childController;
        self.myFootPrintViewController = (FootPrintCollectionViewController *)childController;
        [self.myFootPrintViewController.collectionView setScrollEnabled:NO];
        self.myFootPrintViewController.currentUser = self.userInfo;
        [self SetAddressListData];
    }
}
-(void)finishLoadChildController:(UIViewController *)childController
{
    if ([childController isKindOfClass: [PhotosCollectionViewController class]])
    {
        [self myPhotosButtonClick:nil];
        
    }
    else if( [childController isKindOfClass:[FootPrintCollectionViewController class]])
    {
        [self myAddressButtonClick:nil];
    }
}

#pragma mark - control the model



-(void) updateMyInfomationUI
{
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
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

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSInteger myUserId = [ud integerForKey:@"userId"];
    if (myUserId == self.userInfo.UserID)
    {
        [self.mineButton setHidden:YES];
        [self.sendMessageButton setHidden:YES];
    }
    else
    {
        [self.mineButton setHidden:NO];
        [self.sendMessageButton setHidden:NO];
        if (self.userInfo.followType == UNFOLLOW)
        {
            
            [self.mineButton setImage:[UIImage imageNamed:@"unfollow"] forState:UIControlStateNormal];
        }
        else if (self.userInfo.followType == FOLLOWED)
        {
            [self.mineButton setImage:[UIImage imageNamed:@"followed"] forState:UIControlStateNormal];
        }
        else if (self.userInfo.followType == FOLLOWEACH)
        {
             [self.mineButton setImage:[UIImage imageNamed:@"follow_each"] forState:UIControlStateNormal];
        }
        else
        {
            [self.mineButton setHidden:YES];
            
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
                            /*
                            if (_footLabel)
                            {
                                [_footLabel setHidden:YES];
                            }*/
                        }
                        else
                        {
                            NSLog(@"no more data");
                            /*
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
                            */
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
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    if (!_myAddressListDatasource)
    {
        [self.aiv setCenter:CGPointMake(self.myAddressLabel.center.x, self.myAddressLabel.center.y-10)];
        [self.myAddressNumLabel setHidden:YES];
        [self.myAddressLabel setHidden:YES];
        [self.aiv startAnimating];
        self.shouldRefreshData = NO;
        NSInteger userId = self.userInfo.UserID;
        [[POISearchAPI sharedInstance]getUserPOIsWithUserId:userId whenComplete:^(NSDictionary *returnData) {
            [self.aiv stopAnimating];
            [self.myAddressNumLabel setHidden:NO];
            [self.myAddressLabel setHidden:NO];
            self.shouldRefreshData = YES;
            if ([self.refreshControl isRefreshing])
            {
                [self.refreshControl endRefreshing];
            }
            if ([returnData objectForKey:@"data"])
            {
                _myAddressListDatasource = [returnData objectForKey:@"data"];
                [self.scrollContentViewHeightConstraint setConstant:[self scrollContentViewHeight]];
                [self.scrollContentView setNeedsLayout];
                [self.scrollContentView layoutIfNeeded];
                [self.myFootPrintViewController setDatasource:_myAddressListDatasource];
                self.myAddressNumLabel.text = [NSString stringWithFormat:@"%ld",(long)_myAddressListDatasource.count];
                [self.myFootPrintViewController loadData];
                
            }
            else if ([returnData objectForKey:@"error"])
            {
                [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
            }
        }];
    }
    else
    {
        self.shouldRefreshData = YES;
        if ([self.refreshControl isRefreshing])
        {
            [self.refreshControl endRefreshing];
        }
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
    self.userNameLabel.text = @"";
    self.avator.image = nil;
    self.selfDescriptionLabel.text = @"";
    self.followersNumLabel.text = @"0";
    self.followsNumLabel.text = @"0";
    self.myPhotosNumLabel.text = @"0";
    self.myAddressNumLabel.text = @"0";
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




@end
