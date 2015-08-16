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

static CGFloat kDEFAULTCLUSTERSIZE = 0.1;

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

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIButton *shareButton;

@end

@implementation AddressMarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self.view setBackgroundColor:rgba_WZ(249, 245, 237, 1.0)];
    [self.view setBackgroundColor:rgba_WZ(165, 220, 241, 1.0)];
    [self initMapView];
    [self initAchivementPanel];
    [self setNavigation];
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


-(void)setNavigation
{
    //back button
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(8, self.view.frame.size.height - 48, 35, 35)];
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
    
    //share button
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width - 36, 20, 35, 35)];
    [shareButton setImage:[UIImage imageNamed:@"share_c"] forState:UIControlStateNormal];
    //[shareButton setTitle:@"分享" forState:UIControlStateNormal];
    [shareButton.titleLabel setTextColor:[UIColor whiteColor]];
    [shareButton.titleLabel setFont:WZ_FONT_LARGE_BOLD_SIZE];
    [shareButton setRoundCornerAppearance];
    [shareButton addTarget:self action:@selector(shareToSNS) forControlEvents:UIControlEventTouchUpInside];
    [self.achivementPanel addSubview:shareButton];
    self.shareButton = shareButton;
    if (self.userInfo.UserID == [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"])
    {
        [self.shareButton setHidden:NO];
    }
    else
    {
        [self.shareButton setHidden:YES];
    }
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
    self.mapView.clusterSize = kDEFAULTCLUSTERSIZE;
    self.mapView.showsUserLocation = NO;
    [self.view addSubview:self.mapView];
}
-(void)addAnnotations
{
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
{        static NSString *annotationReuseIdentifier = @"addressMarkAnnotation";
    
    AddressMarkAnnotationView *annotationView = (AddressMarkAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationReuseIdentifier];
    if (annotationView == nil)
    {
        annotationView = [[AddressMarkAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annotationReuseIdentifier];
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
    /*
     AddressMarkAnnotationView2 *annotationView = (AddressMarkAnnotationView2 *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationReuseIdentifier];
     if (annotationView == nil)
     {
         annotationView = [[AddressMarkAnnotationView2 alloc]initWithAnnotation:annotation reuseIdentifier:annotationReuseIdentifier];
     }
     if ([annotation isKindOfClass:[ClusterAnnotation class]])
     {
         ClusterAnnotation *clusterAnnotation = (ClusterAnnotation *)annotation;
         NSArray *annotionsInCluster = [clusterAnnotation annotationsInCluster];
         NSInteger photoNum = 0;
         for (AddressMarkAnnotation *annotation in annotionsInCluster)
         {
         photoNum += annotation.photoNum;
         }
         [annotationView setPhotoNumber:photoNum];
     }
     
     else if ([annotation isKindOfClass:[AddressMarkAnnotation class]])
     {
         AddressMarkAnnotation *addressAnnotation = (AddressMarkAnnotation *)annotation;
         [annotationView setPhotoNumber:addressAnnotation.photoNum];
     
     }*/
    return annotationView;
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
-(void)shareToSNS
{
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
    
    [UMSocialData defaultData].extConfig.qqData.title = @"来自Place的分享";
    [UMSocialData defaultData].extConfig.qzoneData.title = @"来自Place的分享";
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
   // [UMSocialData defaultData].extConfig.qzoneData.url = shareUrl;
    //[UMSocialData defaultData].extConfig.qqData.url = shareUrl;
    [self.backView setHidden:YES];
    [self.shareButton setHidden:YES];
    [self.achivementPanelHandleImage setHidden:YES];
    UIImage *image = [[UMSocialScreenShoterDefault screenShoter] getScreenShot];
    [self.backView setHidden:NO];
    [self.shareButton setHidden:NO];
    [self.achivementPanelHandleImage setHidden:NO];
    [UMSocialSnsService presentSnsIconSheetView:self appKey:@"55a5c86567e58ecd13000507" shareText:@"我的照片地图 | place" shareImage:image shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToWechatFavorite,UMShareToQQ,UMShareToEmail,nil] delegate:nil];
}

@end
