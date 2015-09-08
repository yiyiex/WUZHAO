//
//  AddressMarkViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/7/6.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//
#import "macro.h"
#import "AddressPhotos.h"
#import "AddressMarkViewController.h"
#import "AddressMarkAnnotationView.h"
#import "AddressMarkAnnotationView2.h"
#import "AddressMarkAnnotation.h"
#import "UIView+ChangeAppearance.h"

#import "UIImageView+WebCache.h"
#import "UIImage+Resize.h"
#import "AddressMarkCollectionViewCell.h"
#import "AddressMarkCollectionView.h"

#import "UIViewController+Basic.h"
#import "HomeTableViewController.h"

#import "QDYHTTPClient.h"
#import "SVProgressHUD.h"
#import "UMSocialScreenShoter.h"
#import "UMSocialSnsService.h"
#import "UMSocial.h"
#import "ClusterMapView.h"
#import "PhotoCommon.h"

typedef NS_ENUM(NSInteger, FLAGSTYLE)
{
    FLAGSTYLE_PHOTOS = 0,
    FLAGSTYLE_FLAG = 1
};
typedef NS_ENUM(NSInteger, MAP_DIRECTION)
{
    MAP_DIRECTION_PORTRAIT,
    MAP_DIRECTION_LANDSCAPE
};

static CGFloat kDEFAULTCLUSTERSIZE = 0.1;
static CGFloat kFLAGCLUSTERSIZE = 0;

@interface AddressMarkViewController ()<MKMapViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) UIView *achivementPanel;
@property (nonatomic, strong) UIImageView *achivementPanelHandleImage;
@property (nonatomic) CGFloat achivementPanelHeight;
@property (nonatomic, strong) NSDictionary *datas;
@property (nonatomic, strong) NSMutableArray  *datasTextViews;
@property (nonatomic, strong) UITextView *countryTextView;
@property (nonatomic, strong) UIView *countryIconView;
@property (nonatomic, strong) UITextView *districtTextView;
@property (nonatomic, strong) UIView *districtIconView;
@property (nonatomic, strong) UITextView *placeCountTextView;
@property (nonatomic, strong) UITextView *photosCountTextView;
@property (nonatomic, strong) UITextView *distanceInfoTextView;

@property (nonatomic, strong) NSDictionary *countryFlagDictionary;


@property (nonatomic, strong) ClusterMapView *mapView;
@property (nonatomic, strong) NSMutableArray *annotations;

@property (nonatomic, strong) AddressMarkCollectionView *annotationsPhotosList;
@property (nonatomic, strong) NSArray *annotationsPhotosDatasource;

@property (nonatomic, strong) UIView *buttonsView;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *rotateButton;

@property (nonatomic, strong) UIView *shareView;
@property (nonatomic, strong) UIImage *shareImage;

@property (nonatomic) FLAGSTYLE flagStyle;
@property (nonatomic) MAP_DIRECTION map_direction;

@end

@implementation AddressMarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self.view setBackgroundColor:rgba_WZ(249, 245, 237, 1.0)];
    [self.view setBackgroundColor:rgba_WZ(165, 220, 241, 1.0)];
    self.flagStyle = FLAGSTYLE_PHOTOS;
    self.map_direction = MAP_DIRECTION_PORTRAIT;
    
    [self initMapView];
    [self initAchivementPanel];
    [self setButtons];
    
    //[self setDashboardInfo];
   // [self updateAchivementPanel];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setDashboardInfo];
    [self.navigationController setNavigationBarHidden:YES];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
     [self.navigationController setNavigationBarHidden:NO];
    if (self.map_direction == MAP_DIRECTION_LANDSCAPE)
    {
        [self rotateButtonClick:self.rotateButton];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSMutableArray *)annotations
{
    if (!_annotations)
    {
        _annotations = [[NSMutableArray alloc]init];

    }
    return _annotations;
}
-(AddressMarkCollectionView *)annotationsPhotosList
{
    if (!_annotationsPhotosList)
    {
        _annotationsPhotosList = [[AddressMarkCollectionView alloc]initWithFrame:CGRectMake(20, 60, WZ_APP_SIZE.width - 40, WZ_APP_SIZE.height - 120)];
        [_annotationsPhotosList setDatasource:self];
        [_annotationsPhotosList setDelegate:self];
        [self.view addSubview:_annotationsPhotosList];
    }
    return _annotationsPhotosList;
}

-(UIView *)achivementPanel
{
    if (!_achivementPanel)
    {
        _achivementPanelHeight = 184.0f;
        _achivementPanel = [[UIView alloc]initWithFrame:CGRectMake(0, 20-_achivementPanelHeight, WZ_APP_SIZE.width , _achivementPanelHeight)];
        [_achivementPanel setBackgroundColor:[UIColor colorWithRed:238 green:238 blue:238 alpha:1.0]];
        [_achivementPanel.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [_achivementPanel.layer setShadowOpacity:0.5];
        [_achivementPanel.layer setShadowRadius:10.0f];
        
    }
    return _achivementPanel;
}
-(NSMutableArray *)datasTextViews
{
    if (!_datasTextViews)
    {
        _datasTextViews =[[NSMutableArray alloc]init];
    }
    return _datasTextViews;
}

-(NSDictionary *)countryFlagDictionary
{
    return @{@"阿富汗":@"🇦🇫",@"阿尔巴尼亚":@"🇦🇱",@"阿尔及利亚":@"🇩🇿",@"安道尔":@"🇦🇩",@"安哥拉":@"🇦🇴",
             @"安提瓜和巴布达":@"🇦🇬",@"阿根廷":@"🇦🇷",@"亚美尼亚":@"🇦🇲",@"澳大利亚":@"🇦🇺",@"奥地利":@"🇦🇹",@"阿塞拜疆":@"🇦🇿",
             @"巴哈马":@"🇧🇸",@"巴林":@"🇧🇭",@"孟加拉国":@"🇧🇩",@"巴巴多斯":@"🇧🇧",@"白俄罗斯":@"🇧🇾",@"比利时":@"🇧🇪",@"伯利兹":@"🇧🇿",
             @"贝宁":@"🇧🇯",@"不丹":@"🇧🇹",@"玻利维亚":@"🇧🇴",@"波黑":@"🇧🇦",@"博茨瓦纳":@"🇧🇼",@"巴西":@"🇧🇷",@"文莱":@"🇧🇳",
             @"保加利亚":@"🇧🇬",@"布基纳法索":@"🇧🇫",@"布隆迪":@"🇧🇮",@"柬埔寨":@"🇰🇭",@"喀麦隆":@"🇨🇲",@"加拿大":@"🇨🇦",@"佛得角":@"🇨🇻",
             @"中非共和国":@"🇨🇫",@"智利":@"🇨🇱",@"中国":@"🇨🇳",@"哥伦比亚":@"🇨🇴",@"科摩罗":@"🇰🇲",@"刚果共和国":@"🇨🇬",
             @"刚果民主共和国":@"🇨🇩",@"库克群岛":@"🇨🇰",@"哥斯达黎加":@"🇨🇷",@"克罗地亚":@"🇭🇷",@"古巴":@"🇨🇺",@"塞浦路斯":@"🇨🇾",
             @"捷克":@"🇨🇿",@"丹麦":@"🇩🇰",@"吉布提":@"🇩🇯",@"多米尼克":@"🇩🇲",@"多米尼加":@"🇩🇴",@"厄瓜多尔":@"🇪🇨",@"埃及":@"🇪🇬",
             @"萨尔瓦多":@"🇸🇻",@"赤道几内亚":@"🇬🇶",@"厄立特里亚":@"🇪🇷",@"爱沙尼亚":@"🇪🇪",@"埃塞俄比亚":@"🇪🇹",@"斐济":@"🇫🇯",
             @"芬兰":@"🇫🇮",@"法国":@"🇫🇷",@"加蓬":@"🇬🇦",@"冈比亚":@"🇬🇲",@"格鲁吉亚":@"🇬🇪",@"德国":@"🇩🇪",@"加纳":@"🇬🇭",
             @"希腊":@"🇬🇷",@"格林纳达":@"🇬🇩",@"危地马拉":@"🇬🇹",@"几内亚":@"🇬🇳",@"几内亚比绍":@"🇬🇼",@"圭亚那":@"🇬🇾",
             @"海地":@"🇭🇹",@"洪都拉斯":@"🇭🇳",@"匈牙利":@"🇭🇺",@"冰岛":@"🇮🇸",@"印度":@"🇮🇳",@"印度尼西亚":@"🇮🇩",
             @"伊朗":@"🇮🇷",@"伊拉克":@"🇮🇶",@"爱尔兰":@"🇮🇪",@"以色列":@"🇮🇱",@"意大利":@"🇮🇹",@"牙买加":@"🇯🇲",@"日本 ":@"🇯🇵",
             @"约旦":@"🇯🇴",@"哈萨克斯坦":@"🇰🇿",@"肯尼亚":@"🇰🇪",@"基里巴斯":@"🇰🇮",@"韩国":@"🇰🇷",@"科威特":@"🇰🇼",
             @"吉尔吉斯斯坦":@"🇰🇬",@"老挝":@"🇱🇦",@"拉脱维亚":@"🇱🇻",@"黎巴嫩":@"🇱🇧",@"莱索托":@"🇱🇸",@"利比里亚":@"🇱🇷",
             @"利比亚":@"🇱🇾",@"列支敦士登":@"🇱🇮",@"立陶宛":@"🇱🇹",@"卢森堡":@"🇱🇺",@"马其顿":@"🇲🇰",@"马达加斯加":@"🇲🇬",
             @"马拉维":@"🇲🇼",@"马来西亚":@"🇲🇾",@"马尔代夫":@"🇲🇻",@"马里":@"🇲🇱",@"马耳他":@"🇲🇹",@"毛里塔尼亚":@"🇲🇷",
             @"墨西哥":@"🇲🇽",@"摩尔多瓦":@"🇲🇩",@"蒙古国":@"🇲🇳",@"黑山":@"🇲🇪",@"摩洛哥":@"🇲🇦",@"莫桑比克":@"🇲🇿",@"缅甸":@"🇲🇲",
             @"纳米比亚":@"🇳🇦",@"尼泊尔":@"🇳🇵",@"荷兰":@"🇳🇱",@"新西兰":@"🇳🇿",@"尼加拉瓜":@"🇳🇮",@"尼日尔":@"🇳🇪",@"尼日利亚":@"🇳🇬",
             @"纽埃":@"🇳🇺",@"挪威":@"🇳🇴",@"阿曼":@"🇴🇲",@"巴基斯坦":@"🇵🇰",@"帕劳":@"🇵🇼",@"巴拿马":@"🇵🇦",@"巴布亚新几内亚":@"🇵🇬",
             @"巴拉圭":@"🇵🇾",@"秘鲁":@"🇵🇪",@"菲律宾":@"🇵🇭",@"波兰":@"🇵🇱",@"葡萄牙":@"🇵🇹",@"卡塔尔":@"🇶🇦",@"罗马尼亚":@" 🇷🇴",
             @"俄罗斯":@"🇷🇺",@"卢旺达":@"🇷🇼",@"萨摩亚":@"🇼🇸",@"圣马力诺":@"🇸🇲",@"圣多美和普林西比":@"🇸🇹",@"沙特阿拉伯":@"🇸🇦",
             @"塞内加尔 ":@"🇸🇳",@"塞尔维亚":@"🇷🇸",@"塞舌尔":@"🇸🇨",@"塞拉利昂":@"🇸🇱",@"新加坡":@"🇸🇬",@"斯洛伐克":@"🇸🇰",
             @"斯洛文尼亚":@"🇸🇮",@"所罗门群岛":@"🇸🇧",@"索马里":@"🇸🇴",@"南非":@"🇿🇦",@"南苏丹":@"🇸🇸",@"西班牙":@"🇪🇸",
             @"斯里兰卡":@"🇱🇰",@"苏丹":@"🇸🇩",@"苏里南":@"🇸🇷",@"斯威士兰":@"🇸🇿",@"瑞典":@"🇸🇪",@"瑞士":@"🇨🇭",@"叙利亚":@"🇸🇾",
             @"塔吉克斯坦":@"🇹🇯",@"坦桑尼亚":@"🇹🇿",@"泰国":@"🇹🇭",@"东帝汶":@"🇹🇱",@"多哥":@"🇹🇬",@"汤加":@"🇹🇴",
             @"特立尼达和多巴哥":@"🇹🇹",@"突尼斯":@"🇹🇳",@"土耳其":@"🇹🇷",@"土库曼斯坦":@"🇹🇲",@"图瓦卢":@"🇹🇻",@"乌干达":@"🇺🇬",
             @"乌克兰":@"🇺🇦",@"阿联酋":@"🇦🇪",@"英国":@"🇬🇧",@"美国":@"🇺🇸",@"乌拉圭":@"🇺🇾",@"乌兹别克斯坦":@"🇺🇿",@"越南":@"🇻🇳",
             @"瓦努阿图":@"🇻🇺",@"也门":@"🇾🇪",@"赞比亚":@"🇿🇲",@"津巴布韦":@"🇿🇼"
             };
}


-(void)setButtons
{
    self.buttonsView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, WZ_APP_SIZE.width, 44)];
    [self.view addSubview:self.buttonsView];
    //back button
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(8, self.view.frame.size.height - 44, 35, 35)];
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(6, 8, 19, 19)];
    [view addSubview:backButton];
    [view setBackgroundColor:THEME_COLOR_DARK_GREY_PARENT];
    UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backButtonClick:)];
    [view addGestureRecognizer:tapgesture];
    [view setUserInteractionEnabled:YES];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:view];
    self.backView = view;
    [view setRoundAppearance];
    [self.view bringSubviewToFront:backButton];
    
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarItem;
    
    //share button
    
    float shareButtonSpace = 44;
    if (self.userInfo.UserID == [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"])
    {
        UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width - 44, 0, 36, 36)];
        [shareButton setImage:[UIImage imageNamed:@"share_c"] forState:UIControlStateNormal];
        [shareButton setBackgroundColor:THEME_COLOR_DARK_GREY_PARENT];
        [shareButton setRoundAppearance];
        [shareButton addTarget:self action:@selector(generateShareImage) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonsView addSubview:shareButton];
        self.shareButton = shareButton;
    }
    else
    {
        shareButtonSpace = 0;
    }
    //flag exchange button
    UIButton *exchangeButton = [[UIButton alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width - 44 -shareButtonSpace, 0, 36, 36)];
    if (self.flagStyle == FLAGSTYLE_FLAG)
    {
        [exchangeButton setImage:[UIImage imageNamed:@"photoFlag"] forState:UIControlStateNormal];
    }
    else if (self.flagStyle == FLAGSTYLE_PHOTOS)
    {
        [exchangeButton setImage:[UIImage imageNamed:@"flag"] forState:UIControlStateNormal];
    }
    [exchangeButton setBackgroundColor:THEME_COLOR_DARK_GREY_PARENT];
    [exchangeButton setRoundAppearance];
    [exchangeButton addTarget:self action:@selector(exchangeFlag:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonsView addSubview:exchangeButton];
    
    //rotate button
    UIButton *rotateButton = [[UIButton alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width - 88 - shareButtonSpace, 0, 36, 36)];
    [rotateButton setRoundAppearance];
    [rotateButton setImage:[UIImage imageNamed:@"rotate"] forState:UIControlStateNormal];
    [rotateButton setBackgroundColor:THEME_COLOR_DARK_GREY_PARENT];
    [rotateButton addTarget:self action:@selector(rotateButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonsView addSubview:rotateButton];
    self.rotateButton = rotateButton;
    
}

-(void)initAchivementPanel
{
    [self.view addSubview:self.achivementPanel];
    
    float titleLabelWidth = WZ_APP_SIZE.width /3;
    float titleLabelWidthSide = titleLabelWidth + 18;
    float titleLabelWidthMid = titleLabelWidth -36;
    float labelHeight = 18;
    float textViewHeight = 40;
    //info views
    NSArray *labelTitle = @[@"国家",@"省",@"城市",@"地点",@"照片",@"里程"];
    NSArray *labelCountText = @[@"  个",@" 个",@" 个",@"  个",@"  张",@"  KM"];
    
    for (NSInteger i = 0;i<labelTitle.count;i++)
    {
        float labelWidth;
        float originx ;
        if (i == 0 || i == 3)
        {
            labelWidth = titleLabelWidthSide;
            originx = 0;
        }
        else if (i == 2 || i == 5)
        {
            labelWidth = titleLabelWidthSide;
            originx = WZ_APP_SIZE.width - titleLabelWidthSide;
        }
        else
        {
            labelWidth = titleLabelWidthMid;
            originx = titleLabelWidthSide;
        }
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(originx,  ((_achivementPanelHeight-60)/2)*(i/3+1) , labelWidth, labelHeight)];
        [titleLabel setFont:WZ_FONT_HIRAGINO_SIZE_14_W6];
        [titleLabel setBackgroundColor:[UIColor colorWithRed:133 green:133 blue:133 alpha:1]];
        [titleLabel setTextColor:THEME_COLOR_FONT_GREY];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setText:labelTitle[i]];
        [self.achivementPanel addSubview:titleLabel];
        
        float textViewWidth = titleLabelWidth;
        if (i == 5)
        {
            textViewWidth += 30;
        }
         UITextView *dataInfo = [[UITextView alloc]initWithFrame:CGRectMake(0 ,0, textViewWidth, textViewHeight)];
        [dataInfo setEditable:NO];
        [dataInfo setScrollEnabled:NO];
        [dataInfo setSelectable:NO];
        [dataInfo setCenter:CGPointMake(titleLabel.center.x, titleLabel.frame.origin.y - labelHeight - 4)];
        [dataInfo setBackgroundColor:[UIColor clearColor]];
        dataInfo.textAlignment = NSTextAlignmentCenter;
        dataInfo.textColor = THEME_COLOR_DARK_GREY;
        dataInfo.font = WZ_FONT_HIRAGINO_SIZE_12;
        dataInfo.text = labelCountText[i];
        
        //[dataInfo sizeToFit];
        [self.achivementPanel addSubview:dataInfo];
        [self.datasTextViews addObject:dataInfo];
        /*
        if (i <2)
        {
            float IconViewOriginX = dataInfo.frame.origin.x + dataInfo.frame.size.width ;
            float IconViewOriginY = titleLabel.frame.origin.y - (iconWidth - labelHeight)/2;
            UIView *iconView = [[UIView alloc]initWithFrame:CGRectMake(IconViewOriginX, IconViewOriginY, WZ_APP_SIZE.width - IconViewOriginX, iconWidth)];
            if (i ==0)
                self.countryIconView = iconView;
            else if (i ==1)
                self.districtIconView = iconView;
            [self.achivementPanel addSubview:iconView];
        }*/
        
    }
    
    //handleImageView
    self.achivementPanelHandleImage = [[UIImageView alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width - 48 , 20-11.5, 48, 48)];
    [self.achivementPanelHandleImage setImage:[UIImage imageNamed:@"panel_handle"]];
    [self.achivementPanelHandleImage setUserInteractionEnabled:YES];
    [self.view addSubview:self.achivementPanelHandleImage];
    UITapGestureRecognizer *handleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(achivementPanelTap:)];
    [self.achivementPanelHandleImage addGestureRecognizer:handleTapGesture];
    UISwipeGestureRecognizer *handleSwipeGestureUp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(achivementPanelSwipe:)];
    handleSwipeGestureUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self.achivementPanelHandleImage addGestureRecognizer:handleSwipeGestureUp];
    UISwipeGestureRecognizer *handleSwipeGestureDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(achivementPanelSwipe:)];
    handleSwipeGestureDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.achivementPanelHandleImage addGestureRecognizer:handleSwipeGestureDown];
    

    [self.achivementPanel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(achivementPanelTap:)];
    [self.achivementPanel addGestureRecognizer:tapGesture];
    UISwipeGestureRecognizer *swipeGestureUp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(achivementPanelSwipe:)];
    swipeGestureUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self.achivementPanel addGestureRecognizer:swipeGestureUp];
    UISwipeGestureRecognizer *swipeGestureDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(achivementPanelSwipe:)];
    swipeGestureDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.achivementPanel addGestureRecognizer:swipeGestureDown];
    
}

-(void)initMapView
{
    self.mapView = [[ClusterMapView alloc]initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-20)];
    self.mapView.delegate = self;
    if (self.flagStyle == FLAGSTYLE_PHOTOS)
    {
        self.mapView.clusterSize = kDEFAULTCLUSTERSIZE;
    }
    else
    {
        self.mapView.clusterSize = kFLAGCLUSTERSIZE;
    }
    self.mapView.showsUserLocation = NO;
    [self.view addSubview:self.mapView];
}
-(void)addAnnotations
{
    
    if (self.flagStyle == FLAGSTYLE_PHOTOS)
    {
        self.mapView.clusterSize = kDEFAULTCLUSTERSIZE;
    }
    else
    {
        self.mapView.clusterSize = kFLAGCLUSTERSIZE;
    }
    __block AddressMarkAnnotation *centerAnnotation;
    [self.mapView removeAnnotations:self.annotations];
    [self.annotations removeAllObjects];
    [self.locations enumerateObjectsUsingBlock:^(AddressPhotos *obj, NSUInteger idx, BOOL *stop) {
        if (obj.poi.locationArray.count == 2)
        {
            
            AddressMarkAnnotation *annotation = [[AddressMarkAnnotation alloc]init];
            annotation.coordinate = CLLocationCoordinate2DMake([obj.poi.locationArray[0] floatValue], [obj.poi.locationArray[1] floatValue]);
            [self.annotations addObject:annotation];
            annotation.poi = obj.poi;
            annotation.photoList = obj.photoList;
            annotation.photoNum = obj.photoNum;
            if (idx == 0)
            {
                centerAnnotation = annotation;
            }
            else
            {
                if (annotation.photoNum >centerAnnotation.photoNum)
                {
                    centerAnnotation = annotation;
                }
            }
        }
        
    }];
    [self.mapView addAnnotations:self.annotations];
    [self.mapView setCenterCoordinate:centerAnnotation.coordinate animated:YES];
}

#pragma mark - MAMapViewDelegate
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation> )annotation
{
    static NSString *annotationReuseIdentifierFlag = @"addressMarkAnnotation_flag";
    static NSString *annotationReuseIdentifierPhoto = @"addressMarkAnnotation_photo";
    if (self.flagStyle == FLAGSTYLE_PHOTOS)
    {
        AddressMarkAnnotationView *annotationView = (AddressMarkAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationReuseIdentifierPhoto];
        if (annotationView == nil)
        {
            annotationView = [[AddressMarkAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annotationReuseIdentifierPhoto];
        }
        if ([annotation isKindOfClass:[ClusterAnnotation class]])
        {
            ClusterAnnotation *clusterAnnotation = (ClusterAnnotation *)annotation;
            NSArray *annotionsInCluster = [clusterAnnotation annotationsInCluster];
            AddressMarkAnnotation *firtstAnnotation = [annotionsInCluster firstObject];
            NSInteger photoNum = 0;
            for (AddressMarkAnnotation *annotation in annotionsInCluster)
            {
                photoNum += annotation.photoNum;
            }
            [annotationView setPhotoNumber:photoNum];
            WhatsGoingOn *item = firtstAnnotation.photoList[0];
            [annotationView setImageWithImageUrl:item.imageUrlString];
            
        }
        
        else if ([annotation isKindOfClass:[AddressMarkAnnotation class]])
        {
            AddressMarkAnnotation *addressAnnotation = (AddressMarkAnnotation *)annotation;

            WhatsGoingOn *item = addressAnnotation.photoList[0];
            [annotationView setPhotoNumber:addressAnnotation.photoNum];
            [annotationView setImageWithImageUrl:item.imageUrlString];
        
        }
        return annotationView;
    }
    else if (self.flagStyle == FLAGSTYLE_FLAG)
    {
        /*
         AddressMarkAnnotationView2 *annotationView = (AddressMarkAnnotationView2 *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationReuseIdentifierFlag];
         if (annotationView == nil)
         {
             annotationView = [[AddressMarkAnnotationView2 alloc]initWithAnnotation:annotation reuseIdentifier:annotationReuseIdentifierFlag];
         }
        return annotationView;*/
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationReuseIdentifierFlag];
        if (annotationView == nil)
        {
            annotationView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annotationReuseIdentifierFlag];
        }
        annotationView.pinColor = MKPinAnnotationColorRed;
        return annotationView;
        
    }
    return  nil;
 
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    id<MKAnnotation> annotation = view.annotation;
    [self loadImagesForSelectAnnotations:annotation];
    [mapView deselectAnnotation:annotation animated:YES];
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self.mapView doClustering];
}

#pragma mark - gesture and aciton
-(void)achivementPanelTap:(UIGestureRecognizer *)gesture
{
    if ([gesture.view isKindOfClass:[UIImageView class]])
    {
        if (self.achivementPanel.frame.origin.y==0)
        {
            [self hideAchievmentPanel];
        }
        else if(self.achivementPanel.frame.origin.y <0)
        {
            [self showAchivementPanel];
        }
    }
    else
    {
        if (self.achivementPanel.frame.origin.y>=0)
        {
            return;
        }
        else
        {
            [self showAchivementPanel];
        }
    }
    
    
    
}
-(void)achivementPanelSwipe:(UISwipeGestureRecognizer *)gesture
{
    if (gesture.direction == UISwipeGestureRecognizerDirectionUp && self.achivementPanel.frame.origin.y==0)
    {
        [self hideAchievmentPanel];
    }
    else if(gesture.direction == UISwipeGestureRecognizerDirectionDown && self.achivementPanel.frame.origin.y <0)
    {
        [self showAchivementPanel];
    }
}
-(void)updateAchivementPanel
{
    //_achivementPanelHeight = 220;
    //[self.achivementPanelHandleImage setFrame:CGRectMake((WZ_APP_SIZE.width - 48)/2 , (_achivementPanelHeight -24),48 , 24)];
    //[self.shareButton setFrame:CGRectMake(WZ_APP_SIZE.width - 44, _achivementPanelHeight - 43, 35, 35)];
    
    NSArray *mapArray = @[@{@"name":@"country",@"unit":@"个"},
                          @{@"name":@"district",@"unit":@"个"},
                          @{@"name":@"city",@"unit":@"个"},
                          @{@"name":@"poi",@"unit":@"个"},
                          @{@"name":@"photo",@"unit":@"张"},
                          @{@"name":@"distance",@"unit":@"公里"},
                             ];
    
    [self.datasTextViews enumerateObjectsUsingBlock:^(UITextView *textView, NSUInteger idx, BOOL *stop) {
        NSDictionary *mapDic = (NSDictionary *)[mapArray objectAtIndex:idx];
        NSDictionary *data = [self.datas objectForKey:[mapDic objectForKey:@"name"]];
        NSString *string = [NSString stringWithFormat:@" %@ %@",[data objectForKey:@"number"],[mapDic objectForKey:@"unit"]];
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc]initWithString:string];
        NSRange numberRange =  [string rangeOfString:[data objectForKey:@"number"]];
        [attString setAttributes:@{NSFontAttributeName:WZ_FONT_NUMBER_LONG,NSForegroundColorAttributeName:THEME_COLOR_FONT_DARK_GREY} range:numberRange];
        NSRange uintRange = [string rangeOfString:[mapDic objectForKey:@"unit"]];
        [attString setAttributes:@{NSFontAttributeName:WZ_FONT_HIRAGINO_SIZE_12,NSForegroundColorAttributeName:THEME_COLOR_FONT_GREY} range:uintRange];
        [textView setAttributedText:attString];
        textView.textAlignment = NSTextAlignmentCenter;
        //f[textView sizeToFit];
        /*
        if ([[mapDic objectForKey:@"name"]isEqualToString:@"country"])
        {
            NSArray *countryList = [data objectForKey:@"list"];
            [countryList enumerateObjectsUsingBlock:^(NSString *countryName, NSUInteger idx, BOOL *stop) {
                float iconWidth = 24;
                float iconSpacing = 2;
                
                CGRect iconFrame =  CGRectMake(idx* (iconWidth + iconSpacing), 0, iconWidth, iconWidth);
                if (self.countryIconView.frame.origin.x + iconFrame.origin.x + iconWidth + iconSpacing >= self.view.frame.size.width)
                    *stop = YES;
                else
                {
                
                    UILabel *iconLabel = [[UILabel alloc]initWithFrame:iconFrame];
                    [iconLabel setText:[self.countryFlagDictionary objectForKey:countryName]];
                    [self.countryIconView addSubview:iconLabel];
                }
            }];
        }
        if ([[mapDic objectForKey:@"name"]isEqualToString:@"district"])
        {
            NSArray *districtList = [data objectForKey:@"list"];
            [districtList enumerateObjectsUsingBlock:^(NSString *districtName, NSUInteger idx, BOOL *stop) {
                float iconWidth = 24;
                float iconSpacing = 2;
                
                CGRect iconFrame =  CGRectMake(idx* (iconWidth + iconSpacing), 0, iconWidth, iconWidth);
                if (self.districtIconView.frame.origin.x + iconFrame.origin.x + iconWidth + iconSpacing >= self.view.frame.size.width)
                    *stop = YES;
                else
                {
                    UIImageView *iconBack = [[UIImageView alloc]initWithFrame:CGRectOffset(iconFrame, -5, 0)];
                    iconBack.image = [UIImage imageNamed:@"province_back"];
                    UILabel *iconLabel = [[UILabel alloc]initWithFrame:iconFrame];
                    [iconLabel setFont:WZ_FONT_HIRAGINO_SIZE_13];
                    [iconLabel setTextColor:THEME_COLOR_DARK_GREY];
                    [iconLabel setBackgroundColor:[UIColor clearColor]];
                    
                    [iconLabel setText:districtName];
                    [self.districtIconView addSubview:iconBack];
                    [self.districtIconView addSubview:iconLabel];
                }
            }];
        }*/
    }];
    
    [self showAchivementPanel];
}
-(void)showAchivementPanel
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.achivementPanel setFrame:CGRectMake(0, 0, WZ_APP_SIZE.width, _achivementPanelHeight-36)];
        [self.mapView setFrame:CGRectMake(0, _achivementPanelHeight - 36, self.view.frame.size.width, self.view.frame.size.height - _achivementPanelHeight + 36)];
        [self.achivementPanelHandleImage setFrame:CGRectMake(WZ_APP_SIZE.width -48 ,_achivementPanelHeight-36-11.5, 48, 48)];
    }];
}
-(void)hideAchievmentPanel
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.achivementPanel setFrame:CGRectMake(0, 20-_achivementPanelHeight, WZ_APP_SIZE.width , _achivementPanelHeight)];
        [self.mapView setFrame:self.view.frame];
        [self.achivementPanelHandleImage setFrame:CGRectMake(WZ_APP_SIZE.width -48 ,20-11.5, 48, 48)];
    }];
}

#pragma mark - button action
-(void)backButtonClick:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)exchangeFlag:(UIButton *)button
{
    if (self.flagStyle == FLAGSTYLE_PHOTOS)
    {
        [button setImage:[UIImage imageNamed:@"photoFlag"] forState:UIControlStateNormal];
        [button setEnabled:NO];
        self.flagStyle = FLAGSTYLE_FLAG;
        [self addAnnotations];
        [button setEnabled:YES];

    }
    else if (self.flagStyle == FLAGSTYLE_FLAG)
    {
        [button setImage:[UIImage imageNamed:@"flag"] forState:UIControlStateNormal];
        [button setEnabled:NO];
        self.flagStyle = FLAGSTYLE_PHOTOS;
        [self addAnnotations];
        [button setEnabled:YES];
    }
}
-(void)rotateButtonClick:(UIButton *)button
{
    [button setEnabled:NO];
    if (self.map_direction == MAP_DIRECTION_PORTRAIT)
    {
        
        MKCoordinateSpan worldSpan = MKCoordinateSpanMake(180, 360);
        CGAffineTransform buttonViewTransform = CGAffineTransformMakeTranslation(-WZ_APP_SIZE.width/2+ 20, -WZ_APP_SIZE.width/2+24);
        CGAffineTransform backButtonTransform = CGAffineTransformMakeTranslation(-4, -WZ_APP_SIZE.height + 48);
        [self.mapView setRegion:MKCoordinateRegionMake(self.mapView.centerCoordinate, worldSpan) animated:YES];
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.mapView.transform = CGAffineTransformMakeRotation(M_PI/2);
            self.buttonsView.transform = CGAffineTransformRotate(buttonViewTransform, M_PI/2);
            self.backView.transform = CGAffineTransformRotate(backButtonTransform, M_PI/2);
            [self hideAchievmentPanel];
        } completion:^(BOOL finished) {
            //[self hideAchievmentPanel];
            //[self.mapView setFrame:CGRectMake(0,self.achivementPanel.frame.size.height, WZ_APP_SIZE.width, WZ_APP_SIZE.height - self.achivementPanel.frame.size.height +20)];
            self.map_direction = MAP_DIRECTION_LANDSCAPE;
            [button setEnabled:YES];
        }];
    }
    else if (self.map_direction == MAP_DIRECTION_LANDSCAPE)
    {
        
        MKCoordinateSpan worldSpan = MKCoordinateSpanMake(180, 360);
        [self.mapView setRegion:MKCoordinateRegionMake(self.mapView.centerCoordinate, worldSpan) animated:YES];
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.mapView.transform = CGAffineTransformIdentity;
            self.buttonsView.transform = CGAffineTransformIdentity;
            self.backView.transform = CGAffineTransformIdentity;
            [self showAchivementPanel];
        } completion:^(BOOL finished) {
            self.map_direction = MAP_DIRECTION_PORTRAIT;
            
            [button setEnabled:YES];
        }];
    }
    
    //[self.mapView mapRectThatFits:MKMapRectMake(10, 10, 300, 200)];
}
/*
#pragma mark -random coordinates
- (NSArray *)randomCoordinatesGenerator:(int)numberOfCoordinates
{
    MKCoordinateRegion visibleRegion = self.mapView.region;
    visibleRegion.span.latitudeDelta *= 0.8;
    visibleRegion.span.longitudeDelta *= 0.8;
    
    int max = 9999;
    numberOfCoordinates = MAX(0,numberOfCoordinates);
    NSMutableArray *coordinates = [[NSMutableArray alloc] initWithCapacity:numberOfCoordinates];
    for (int i = 0; i < numberOfCoordinates; i++) {
        
        // start with top left corner
        CLLocationDistance longitude = visibleRegion.center.longitude - visibleRegion.span.longitudeDelta/2.0;
        CLLocationDistance latitude  = visibleRegion.center.latitude + visibleRegion.span.latitudeDelta/2.0;
        
        // Get random coordinates within current map rect
        longitude += ((arc4random()%max)/(CGFloat)max) * visibleRegion.span.longitudeDelta;
        latitude  -= ((arc4random()%max)/(CGFloat)max) * visibleRegion.span.latitudeDelta;
        
        CLLocation *loc = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
        [coordinates addObject:loc];
    }
    return  coordinates;
}*/

#pragma mark - annotations photos
-(void)loadImagesForSelectAnnotations:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[ClusterAnnotation class]])
    {
        self.annotationsPhotosDatasource = [self POIsInClusterAnnotationsView:annotation];
    }
    else if ([annotation isKindOfClass:[AddressMarkAnnotation class]])
    {
        self.annotationsPhotosDatasource = [self POIsInAddressAnnotationView:annotation];
    }
    [self.annotationsPhotosList resizeWithContentCount:self.annotationsPhotosDatasource.count];
    [self.annotationsPhotosList showView];
}

-(NSArray *)POIsInAddressAnnotationView:(AddressMarkAnnotation *)addressAnnotation
{
    NSMutableArray *POIsList = [[NSMutableArray alloc]init];
    for (WhatsGoingOn *item in addressAnnotation.photoList)
    {
        [POIsList addObject:item];
    }
    return POIsList;
}
-(NSArray *)POIsInClusterAnnotationsView:(ClusterAnnotation *)clusterAnnotation
{
    NSMutableArray *POIsList = [[NSMutableArray alloc]init];
    for (AddressMarkAnnotation *annotation in [clusterAnnotation annotationsInCluster])
    {
        [POIsList addObjectsFromArray:[self POIsInAddressAnnotationView:annotation]];
    }
    return POIsList;
}

#pragma mark - collection view delegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _annotationsPhotosDatasource.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AddressMarkCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    WhatsGoingOn *item = self.annotationsPhotosDatasource[indexPath.item];
    [cell.placeHolderImageView setHidden:NO];
    [cell.shotStackView setHidden:YES];
    [cell.placeHolderImageView sd_setImageWithURL:[NSURL URLWithString:item.imageUrlString] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [cell.shotStackView setImage:image];
        [cell.placeHolderImageView setHidden:YES];
        [cell.shotStackView setHidden:NO];
    }];
    return cell;
    
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WhatsGoingOn *item = self.annotationsPhotosDatasource[indexPath.item];
    [self gotoPOIPageWithItem:item];
}

#pragma mark - action
-(void)gotoPOIPageWithItem:(WhatsGoingOn *)item
{
    UIStoryboard *whatsNew = [UIStoryboard storyboardWithName:@"WhatsNew" bundle:nil];
    HomeTableViewController *detailPhotoController  = [whatsNew instantiateViewControllerWithIdentifier:@"HomeTableViewController"];
    [detailPhotoController setDatasource:[NSMutableArray arrayWithObject:item]];
    [detailPhotoController setTableStyle:WZ_TABLEVIEWSTYLE_DETAIL];
    [self pushToViewController:detailPhotoController animated:YES hideBottomBar:YES];
}

#pragma mark - getDashboard
-(void)setDashboardInfo
{
    NSInteger userId = self.userInfo.UserID;
    [[QDYHTTPClient sharedInstance]getDashbordInfoWithUserId:userId whenComplete:^(NSDictionary *returnData) {
        if ([returnData objectForKey:@"data"])
        {
            [self.achivementPanel setHidden:NO];
            [self.achivementPanelHandleImage setHidden:NO];
            
            self.datas = [[NSMutableDictionary alloc]init];
            NSDictionary *data = [returnData objectForKey:@"data"];
            
            NSArray *countryList =[data objectForKey:@"countryList"];
            NSDictionary *country = @{@"number":[[NSNumber numberWithInteger:countryList.count]stringValue],@"list":countryList};
            [self.datas setValue:country forKey:@"country"];
            
            NSArray *provinceShortList = [data objectForKey:@"provinceShortList"];
            NSDictionary *province = @{@"number":[[NSNumber numberWithInteger:provinceShortList.count]stringValue],@"list":provinceShortList};
            [self.datas setValue:province forKey:@"district"];
            
            NSArray *cityList = [data objectForKey:@"cityList"];
            NSDictionary *city = @{@"number":[[NSNumber numberWithInteger:cityList.count]stringValue]};
            [self.datas setValue:city forKey:@"city"];
            
            NSDictionary *poi = @{@"number":[data objectForKey:@"poiNumber"]};
            [self.datas setValue:poi forKey:@"poi"];
            
            NSDictionary *photo = @{@"number":[data objectForKey:@"postNumber"]};
            [self.datas setValue:photo forKey:@"photo"];
            
            NSDictionary *distance = @{@"number":[data objectForKey:@"distance"]};
            [self.datas setValue:distance forKey:@"distance"];
            
            [self updateAchivementPanel];
        }
        else if ([returnData objectForKey:@"error"])
        {
            [self.achivementPanel setHidden:YES];
            [self.achivementPanelHandleImage setHidden:YES];
            //[SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
        }
        else
        {
            [self.achivementPanel setHidden:YES];
            [self.achivementPanelHandleImage setHidden:YES];
            //[SVProgressHUD showErrorWithStatus:@"获取总结数据失败"];
        }
    }];
}
#pragma mark - share to SNS
-(void)generateShareImage
{
    [SVProgressHUD showWithStatus:@"照片地图生成中" maskType:SVProgressHUDMaskTypeBlack];
    //改变mapview frame 的宽 高 比例参数
    float widthFactor = 1.6;
    float heightFactor = 1.2;
    
    //恢复所用参数
    CGRect originFrame = self.mapView.frame;
    MKCoordinateRegion originRegion = self.mapView.region;
    BOOL shouldShowAchivementPanel = NO;
    
    CGRect wholeFrame = CGRectMake(0, 0, self.view.frame.size.width*widthFactor, self.view.frame.size.height*heightFactor);
    
    
    if (self.achivementPanel.frame.origin.y<0)
    {
        shouldShowAchivementPanel = YES;
        [self hideAchievmentPanel];
    }
    
    [self.mapView setFrame:wholeFrame];

    //西半球
    MKCoordinateSpan worldSpan = MKCoordinateSpanMake(180, 180);
    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(30, 100), worldSpan)];
    
    //东半球与西半球 输出图片
    __block UIImage *image1;
    __block UIImage *image2;
    
    MKMapSnapshotOptions *options1 = [[MKMapSnapshotOptions alloc] init];
    options1.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(30, -80), MKCoordinateSpanMake(150, 180));
    options1.scale = [UIScreen mainScreen].scale;
    options1.size = wholeFrame.size;
    
    MKMapSnapshotter *snapshotter1 = [[MKMapSnapshotter alloc] initWithOptions:options1];
    [snapshotter1 startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        //西半球截图完成
        image1 = [self flagInSnapShort:snapshot];
        //东半球
        MKMapSnapshotOptions *options2 = [[MKMapSnapshotOptions alloc] init];
        options2.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(30, 100), MKCoordinateSpanMake(150, 180));
        options2.scale = [UIScreen mainScreen].scale;
        options2.size = wholeFrame.size;
        
        MKMapSnapshotter *snapshotter2 = [[MKMapSnapshotter alloc] initWithOptions:options2];
        [snapshotter2 startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
            //东半球截图完成
            image2 = [self flagInSnapShort:snapshot];

            //合成图片并保存
            UIImage *wholeImage = [PhotoCommon composeTwoImage:image1 rightImage:image2];
            UIImage *iconImage = [UIImage imageNamed:@"addressMapIcon"];
            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, WZ_APP_SIZE.width, 30)];
            [nameLabel setNumberOfLines:2];
            [nameLabel setText:[NSString stringWithFormat:@"by %@\nPlace",self.userInfo.UserName]];
            [nameLabel setTextColor:[UIColor whiteColor]];
            [nameLabel setFont:WZ_FONT_COMMON_SIZE];
            [nameLabel sizeToFit];
            
            
            iconImage = [PhotoCommon generateIconWithImage:iconImage logo:nameLabel];
            
            self.shareImage =  [PhotoCommon addImage:iconImage toImage:wholeImage atPosition:CGPointMake(16, wholeImage.size.height - 16 - iconImage.size.height)];
            
            [PhotoCommon saveImageToPhotoAlbum:self.shareImage];
            
            [SVProgressHUD showInfoWithStatus:@"照片地图已保存到相册"];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showShareWindow];
            });
            
            //恢复
            [self.mapView setFrame:originFrame];
            [self.mapView setRegion:originRegion];
            if (shouldShowAchivementPanel)
            {
                [self showAchivementPanel];
            }
      
        }];
    }];
}

-(void)showShareWindow
{
    if (!self.shareImage)
        return;
    if (!self.shareView)
    {
        self.shareView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WZ_DEVICE_SIZE.width, WZ_DEVICE_SIZE.height)];
        [self.shareView setBackgroundColor:THEME_COLOR_DARK_GREY_BIT_PARENT];
        
        float margin = 16;
        float imageViewRatio = self.shareImage.size.width/self.shareImage.size.height;
        
        float shareImageViewHeight = self.shareView.frame.size.height - 68 - margin*2 ;
        UIImageView *shareImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, shareImageViewHeight*imageViewRatio, shareImageViewHeight)];
        [shareImageView setImage:self.shareImage];
        
        UIScrollView *shareImageScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(margin, margin+20, self.shareView.frame.size.width-margin*2,shareImageViewHeight)];
        [self.shareView addSubview:shareImageScrollView];
        [shareImageScrollView setContentSize:CGSizeMake(shareImageViewHeight*imageViewRatio, shareImageViewHeight)];
        [shareImageScrollView setMaximumZoomScale:(self.shareImage.size.height/shareImageViewHeight)];
        [shareImageScrollView setContentOffset:CGPointMake((shareImageViewHeight*imageViewRatio/3),0)];
        [shareImageScrollView addSubview:shareImageView];
        
        
        float buttonWidth = (self.shareView.frame.size.width-margin*3)/2;
        UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(margin, shareImageScrollView.frame.origin.y+ shareImageScrollView.frame.size.height+margin, buttonWidth, 40)];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:THEME_COLOR_DARK_GREY forState:UIControlStateNormal];
        [cancelButton setBackgroundColor:[UIColor whiteColor]];
        [cancelButton addTarget:self action:@selector(hideShareView) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton.layer setCornerRadius:3.0f];
        [cancelButton.layer setMasksToBounds:YES];
        [self.shareView addSubview:cancelButton];
        
        UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(margin+buttonWidth+margin,shareImageScrollView.frame.origin.y+ shareImageScrollView.frame.size.height+margin, buttonWidth ,40)];
        
        [shareButton setTitle:@"分享" forState:UIControlStateNormal];
        [shareButton setTitleColor:THEME_COLOR_DARK forState:UIControlStateNormal];
        [shareButton setBackgroundColor:[UIColor whiteColor]];
        [shareButton addTarget:self action:@selector(shareToSNS) forControlEvents:UIControlEventTouchUpInside];
        [shareButton.layer setCornerRadius:3.0f];
        [shareButton.layer setMasksToBounds:YES];
        [self.shareView addSubview:shareButton];
    }
    
    [self.view.window addSubview:self.shareView];
    [self.view.window bringSubviewToFront:self.shareView];
    
}

-(void)hideShareView
{
    [self.shareView removeFromSuperview];
    self.shareView = nil;
}

-(void)shareToSNS
{
    [self.shareView removeFromSuperview];
    self.shareView = nil;
    //share config
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
    [UMSocialData defaultData].extConfig.qqData.title = @"来自Place的分享";
    [UMSocialData defaultData].extConfig.qzoneData.title = @"来自Place的分享";
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
    // [UMSocialData defaultData].extConfig.qzoneData.url = shareUrl;
    //[UMSocialData defaultData].extConfig.qqData.url = shareUrl;
    
    [UMSocialSnsService presentSnsIconSheetView:self appKey:@"55a5c86567e58ecd13000507" shareText:@"我的照片地图 | place" shareImage:self.shareImage shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToWechatFavorite,UMShareToQQ,UMShareToEmail,nil] delegate:nil];
}

-(UIImage *)flagInSnapShort:(MKMapSnapshot *)snapshot
{
    UIImage *image = snapshot.image;
    CGRect finalImageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    //AddressMarkAnnotationView2 *pin = [[AddressMarkAnnotationView2 alloc]initWithAnnotation:nil reuseIdentifier:@""];
    //UIImage *pinImage = [UIImage imageNamed:@"flag_green"];
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc]initWithAnnotation:nil reuseIdentifier:@""];
    pin.pinColor = MKPinAnnotationColorRed;
    UIImage *pinImage = pin.image;
    UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
    [image drawAtPoint:CGPointMake(0, 0)];
    for (id<MKAnnotation>annotation in self.mapView.annotations)
    {
        CGPoint point = [snapshot pointForCoordinate:annotation.coordinate];
        if (CGRectContainsPoint(finalImageRect, point))
        {
            CGPoint pinCenterOffset = pin.centerOffset;
            point.x -= pin.bounds.size.width / 2.0;
            point.y -= pin.bounds.size.height / 2.0;
            point.x += pinCenterOffset.x;
            
            [pinImage drawAtPoint:point];
        }
    }
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImage;
}


@end

