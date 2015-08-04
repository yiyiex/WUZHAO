//
//  SystemNoticeViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/7/25.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "SystemNoticeViewController.h"
#import "CommonContainerViewController.h"
#import "NoticeViewController_.h"
#import "SystemNoticeViewController.h"
#import "PrivateLetterViewController.h"
#import "HMSegmentedControl.h"

#import "QDYHTTPClient.h"
#import "SVProgressHUD.h"

#import "UILabel+ChangeAppearance.h"

#import "macro.h"

#define SEGUEFIRST @"segueNotice"
#define SEGUESECOND @"seguePrivateLetter"

@interface NoticeViewController_ ()<CommonContainerViewControllerDelegate>
@property (nonatomic, strong) HMSegmentedControl *segmentControl;
@property (nonatomic,strong) UIView *infoView;
@property (nonatomic, strong) CommonContainerViewController *containerViewController;
@property (nonatomic, strong) SystemNoticeViewController *noticeViewController;
@property (nonatomic, strong) PrivateLetterViewController *privateLetterViewController;

@property (nonatomic, strong) NSMutableArray *noticeViewDatasouce;
@property (nonatomic, strong) NSMutableArray *privateLetterViewDatasource;

@property (nonatomic, strong) UIView *LetterIndicator;
@property (nonatomic, strong) UIView *NoticeIndicator;

@property (nonatomic) BOOL shouldRefreshNoticeData;
@property (nonatomic) BOOL shouldRefreshLettersData;

@property (nonatomic, strong) UIActivityIndicatorView *aiv;

@end

@implementation NoticeViewController_

- (void)viewDidLoad {

    
    [super viewDidLoad];
    [self initSegment];
    [self initNavigationBar];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateNoticeInfo:) name:@"updateNotificationNum" object:nil];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updatePageContent:) name:@"updateNoticePage" object:nil];
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSInteger loadIndex;
    if ([[NSUserDefaults standardUserDefaults]valueForKey:@"noticeIndex"])
    {
        loadIndex = [[[NSUserDefaults standardUserDefaults]valueForKey:@"noticeIndex"]integerValue];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"noticeIndex"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.segmentControl setSelectedSegmentIndex:loadIndex animated:YES];
        [self segmentValueChanged];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)initSegment
{
    _segmentControl = [[HMSegmentedControl alloc]initWithFrame:CGRectMake(0, 0, WZ_APP_SIZE.width-100, 44)];
    _segmentControl.backgroundColor = [UIColor clearColor];
    _segmentControl.sectionTitles = @[@"通 知",@"私 信"];
    _segmentControl.titleTextAttributes = @{NSForegroundColorAttributeName : THEME_COLOR_LIGHT_GREY,NSFontAttributeName:WZ_FONT_LARGE_SIZE};
    _segmentControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : THEME_COLOR_DARK_GREY,NSFontAttributeName:WZ_FONT_LARGE_SIZE};
    [_segmentControl setSelectionIndicatorColor:THEME_COLOR_DARK_GREY_BIT_PARENT];
    _segmentControl.selectionIndicatorHeight = 2.50f;
    
    _segmentControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    _segmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    [_segmentControl addTarget:self action:@selector(segmentValueChanged) forControlEvents:UIControlEventValueChanged];
    [_segmentControl setSelectedSegmentIndex:0];

    [_segmentControl setSelectedSegmentIndex:0];
    
    float indicatorWidth = 8;
    float indicatorOffset;
    if (isIPHONE_4s || isIPHONE_5)
    {
        indicatorOffset = _segmentControl.frame.size.width/6;
    }
    else if (isIPHONE_6)
    {
        indicatorOffset = _segmentControl.frame.size.width/7+8;
    }
    else if (isIPHONE_6P)
    {
        indicatorOffset = _segmentControl.frame.size.width/7+10;
    }
    
    _NoticeIndicator = [[UIView alloc]initWithFrame:CGRectMake(_segmentControl.frame.size.width/2-indicatorOffset, 12, indicatorWidth, indicatorWidth)];
    _NoticeIndicator.layer.cornerRadius = indicatorWidth/2;
    _NoticeIndicator.layer.masksToBounds = YES;
    _NoticeIndicator.backgroundColor = THEME_COLOR_DARK;
    
    _LetterIndicator = [[UIView alloc]initWithFrame:CGRectMake(_segmentControl.frame.size.width-indicatorOffset, 12, indicatorWidth, indicatorWidth)];
    _LetterIndicator.layer.cornerRadius = indicatorWidth/2;
    _LetterIndicator.layer.masksToBounds = YES;
    _LetterIndicator.backgroundColor = THEME_COLOR_DARK;
    
    [_segmentControl addSubview:_NoticeIndicator];
    [_segmentControl addSubview:_LetterIndicator];
    [_NoticeIndicator setHidden:YES];
    [_LetterIndicator setHidden:YES];
    
    
   
    
}
-(void)initNavigationBar
{

    //self.navigationItem.titleView = self.segmentControl;
    self.tabBarController.navigationItem.title = @"通 知";
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarItem;
    
    _aiv = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc]initWithCustomView:_aiv];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.titleView = self.segmentControl;
}
-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationItem.titleView = nil;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.shouldRefreshLettersData = YES;
    self.shouldRefreshNoticeData = YES;
    if ([segue.identifier isEqualToString:@"embedContainer"])
    {
        self.containerViewController = segue.destinationViewController;
        self.containerViewController.delegate = self;
        
        self.containerViewController.ChildrenName = @[SEGUEFIRST,SEGUESECOND];
        self.containerViewController.isInteractive = NO;
    }
}


-(CommonContainerViewController *)containerViewController
{
    if (!_containerViewController)
    {
        _containerViewController = [[CommonContainerViewController alloc]initWithChildren:@[SEGUEFIRST,SEGUESECOND]];
        
    }
    return _containerViewController;
}


#pragma mark - control the model

-(void)getLatestDataOfSystemNotice
{
    if ((!self.shouldRefreshNoticeData))
    {
        return;
    }
    [self startAiv];
    self.shouldRefreshNoticeData = NO;
    self.noticeViewController.shouldRefreshData = NO;
    NSInteger userId = [[NSUserDefaults standardUserDefaults] integerForKey:@"userId"];
    //获取最新数据
    [[QDYHTTPClient sharedInstance]getNoticeWithUserId:userId whenComplete:^(NSDictionary *returnData) {
        self.shouldRefreshNoticeData = YES;
        self.noticeViewController.shouldRefreshData = YES;
        if ([returnData objectForKey:@"data"])
        {
            [[QDYHTTPClient sharedInstance] getLatestNoticeNumber];
            self.noticeViewDatasouce = [returnData objectForKey:@"data"];
            if (self.noticeViewDatasouce.count == 0)
            {
                if (![self.infoView superview])
                {
                    self.infoView = [[UIView alloc]initWithFrame:self.view.frame];
                    UILabel *infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, WZ_APP_SIZE.width-20, 30)];
                    infoLabel.text = @"暂无数据";
                    infoLabel.textAlignment = NSTextAlignmentCenter;
                    [infoLabel setReadOnlyLabelAppearance];
                    [self.infoView addSubview:infoLabel];
                }
                [self.view addSubview:self.infoView];
            }
            else
            {
                if (self.infoView)
                {
                    [self.infoView removeFromSuperview];
                }
                self.noticeViewController.dataSource = self.noticeViewDatasouce;
                [self.noticeViewController loadData];
            }
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
        }

        [self stopAiv];
    }];
    //self.dataSource = [[Feeds getLatestFeeds]mutableCopy];;
}
-(void)getLatestDataOfPrivateLetter
{
    if ((!self.shouldRefreshLettersData) )
    {
        return ;
    }
    [self startAiv];
    self.shouldRefreshLettersData = NO;
    self.privateLetterViewController.shouldRefreshData = NO;
    [[QDYHTTPClient sharedInstance]getLetterListWithUserId:[[NSUserDefaults standardUserDefaults] integerForKey:@"userId"] whenComplete:^(NSDictionary *returnData) {
        self.shouldRefreshLettersData = YES;
        self.privateLetterViewController.shouldRefreshData = YES;
        if ([returnData objectForKey:@"data"])
        {

            [[QDYHTTPClient sharedInstance] getLatestNoticeNumber];
            self.privateLetterViewDatasource = [returnData objectForKey:@"data"];
            if (self.privateLetterViewDatasource.count == 0)
            {
                if (![self.infoView superview])
                {
                    self.infoView = [[UIView alloc]initWithFrame:self.view.frame];
                    UILabel *infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, WZ_APP_SIZE.width-20, 30)];
                    infoLabel.text = @"暂无数据";
                    infoLabel.textAlignment = NSTextAlignmentCenter;
                    [infoLabel setReadOnlyLabelAppearance];
                    [self.infoView addSubview:infoLabel];
                }
                [self.view addSubview:self.infoView];
            }
            else
            {
                if (self.infoView)
                {
                    [self.infoView removeFromSuperview];
                }
                self.privateLetterViewController.datasource = self.privateLetterViewDatasource;
                [self.privateLetterViewController loadData];
            }
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
        }
 
        [self stopAiv];
        
    }];
}

-(void)getLatestData
{
    if ([self.containerViewController.currentViewController isKindOfClass:[SystemNoticeViewController class]])
    {
        [self getLatestDataOfSystemNotice];
    }
    else  if ([self.containerViewController.currentViewController isKindOfClass:[PrivateLetterViewController class]])
    {
        [self getLatestDataOfPrivateLetter];
    }
}

#pragma mark - commencontainerviewcontroller delegate
-(void)beginLoadChildController:(UIViewController *)childController
{
    if ([childController isKindOfClass: [SystemNoticeViewController class]])
    {
        self.noticeViewController = (SystemNoticeViewController *)childController;
        self.noticeViewController.shouldRefreshData = YES;
 
    }
    else if ([childController isKindOfClass:[PrivateLetterViewController class]])
    {
        self.privateLetterViewController = (PrivateLetterViewController *)childController;
        self.privateLetterViewController.shouldRefreshData = YES;
    }
}
-(void)finishLoadChildController:(UIViewController *)childController
{
    [self.segmentControl setUserInteractionEnabled:YES];
    if ([childController isKindOfClass: [SystemNoticeViewController class]])
    {
        [self.segmentControl setSelectedSegmentIndex:0 animated:YES];
        if (self.NoticeIndicator.hidden == NO)
        {
            [self getLatestDataOfSystemNotice];
        }
        else if (self.noticeViewDatasouce.count >0)
        {
            self.noticeViewController.dataSource =self.noticeViewDatasouce;
            [self.noticeViewController loadData];
        }
        else
        {
            [self getLatestDataOfSystemNotice];
        }
    }
    else if ([childController isKindOfClass:[PrivateLetterViewController class]])
    {
        [self.segmentControl setSelectedSegmentIndex:1 animated:YES];
        if (self.LetterIndicator.hidden == NO)
        {
            [self getLatestDataOfPrivateLetter];
        }
        else  if (self.privateLetterViewDatasource.count >0)
        {
            self.privateLetterViewController.datasource = self.privateLetterViewDatasource;
            [self.privateLetterViewController loadData];
        }
        else
        {
            [self getLatestDataOfPrivateLetter];
        }

    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - segment delegate
- (void)segmentValueChanged
{
    [self.segmentControl setUserInteractionEnabled:NO];
    NSString *swapIdentifier ;
    switch (self.segmentControl.selectedSegmentIndex) {
        case 0:
            swapIdentifier = SEGUEFIRST;
            break;
        case 1:
            swapIdentifier = SEGUESECOND;
            break;
        default:
            swapIdentifier = SEGUEFIRST;
            break;
    }
    [self.containerViewController swapViewControllersWithIdentifier:swapIdentifier];
}

-(void)updatePageContent:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if ([[userInfo objectForKey:@"type"] isEqualToString:@"message"] )
    {
        [self getLatestDataOfPrivateLetter];
    }
    /*
    else if ([[userInfo objectForKey:@"type"]isEqualToString:@"notice"])
    {
        [self getLatestDataOfSystemNotice];
    }*/
}

-(void)updateNoticeInfo:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if ([(NSNumber *)[userInfo objectForKey:@"messageNum"]integerValue]>0)
    {
        [self.LetterIndicator setHidden:NO];
    }
    else
    {
        [self.LetterIndicator setHidden:YES];
    }
    if ([(NSNumber *)[userInfo objectForKey:@"noticeNum"]integerValue]>0)
    {
        [self.NoticeIndicator setHidden:NO];
    }
    else
    {
        [self.NoticeIndicator setHidden:YES];
    }
}


-(void)startAiv
{
    [_aiv startAnimating];
}
-(void)stopAiv
{
    if (_aiv)
    {
        if ([_aiv isAnimating])
        {
            [_aiv stopAnimating];
        }
    }
}

@end

