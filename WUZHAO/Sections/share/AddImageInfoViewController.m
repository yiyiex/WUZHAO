//
//  AddImageInfoViewController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-21.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//
#import "captureMacro.h"
#import "AddImageInfoViewController.h"
#import "AddressSearchTableViewController.h"

#import "QDYHTTPClient.h"
#import "POISearchAPI.h"
#import "SVProgressHUD.h"


#import "QiniuSDK.h"
#import "macro.h"

#import "UIButton+ChangeAppearance.h"
#import "UIView+ChangeAppearance.h"

#import <AMapSearchKit/AMapSearchAPI.h>
#import <CoreLocation/CoreLocation.h>
#import "Geodetic.h"
#import "CLLocationUtility.h"

#import <ImageIO/ImageIO.h>
#import "UMSocial.h"

#import "ImageDetailView.h"
#import "PhotoCommon.h"


//#define PIOTKEYWORDS @"餐饮|购物|生活|体育|住宿|风景|地名|商务|科教|公司";
#define POIKEYWORDS @"餐饮"
#define PHOTOWIDTH  (WZ_APP_SIZE.width-24)/5
@interface AddImageInfoViewController()<UITableViewDataSource,UITableViewDelegate,AddressSearchTableViewControllerDelegate,UITextViewDelegate,UITextFieldDelegate,AMapSearchDelegate>
{
    AMapSearchAPI *_search;
    CLLocation *searchLocation;
}
@property (strong, nonatomic)  UITableView *imageInfoTableView;

@property (strong, nonatomic) UITableViewCell *postImagesCell;

@property (strong, nonatomic) UITableViewCell *postImageDescriptionCell;

@property (strong, nonatomic)  PlaceholderTextView *postImageDescription;
@property (strong, nonatomic)  UITableViewCell *addressTableViewCell;

@property (nonatomic) BOOL hasPoi;
@property (nonatomic ,strong) POI *poiInfo;
@property (nonatomic, strong) POI *provinceInfo;

@property (nonatomic ,strong) NSArray *addressDatasource;

@property (strong, nonatomic) UIButton *postButton;
@property (strong, nonatomic) UIView *topBarView;

@property (nonatomic, strong) UIImageView *shareToWeChatTimeLine;
@property (nonatomic, strong) UIImageView *shareToSinaWebo;
@property (nonatomic, strong) UIImageView *shareToWeChatFriend;
@property (nonatomic, strong) UIImageView *shareToQQZone;

@property (nonatomic, strong) CLLocationUtility *locationUtility;




//for state restoration
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;

@property (atomic) float progress;
@end

@implementation AddImageInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // restore the searchController's active state

}
-(void)viewWillAppear:(BOOL)animated
{
    if (self.poiInfo && self.hasPoi)
    {
        if (self.poiInfo.type == POI_TYPE_GAODE)
        {
            self.addressTableViewCell.textLabel.text = [NSString stringWithFormat:@"%@ · %@",self.poiInfo.city,self.poiInfo.name];
        }
        else
        {
            self.addressTableViewCell.textLabel.text = [NSString stringWithFormat:@"%@",self.poiInfo.name];
        }
    }
    else
    {
        self.addressTableViewCell.textLabel.text = @"标记位置";
    }
}


#pragma mark -datas

-(NSDictionary *)postImageInfo
{
    if (!_postImageInfo)
    {
        __block UIImage *image;
        [self.imagesAndInfo enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *postImageInfo = [obj objectForKey:@"imageInfo"];
            if ([postImageInfo objectForKey:@"{GPS}"])
            {
                _postImageInfo = postImageInfo;
                image = [obj objectForKey:@"image"];
                *stop = YES;
           
            }
            else
            {
                NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
                CFDataRef imageDataRef = (__bridge CFDataRef)imageData;
                CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData(imageDataRef, NULL);
                _postImageInfo = (NSDictionary *) CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, NULL));
            }
        }];
 
    }
    return _postImageInfo;
}

-(WhatsGoingOn *)whatsGoingOnItem
{
    if (!_whatsGoingOnItem)
    {
        _whatsGoingOnItem = [[WhatsGoingOn alloc]init];
    }
    return _whatsGoingOnItem;
}
-(void)initView
{
    //self.navigationController.navigationBarHidden = NO;
    //self.navigationItem.hidesBackButton = NO;

    self.hasPoi = NO;
    [self initTopBar];
    [self initTableView];
    [self initSendButton];

}
-(void)initTableView
{

    self.imageInfoTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 50, WZ_APP_SIZE.width, WZ_APP_SIZE.height-100) style:UITableViewStyleGrouped];
    [self.view addSubview:self.imageInfoTableView];
    self.imageInfoTableView.dataSource = self;
    self.imageInfoTableView.delegate = self;
    
    [self.imageInfoTableView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tableviewTouch:)];
    [self.imageInfoTableView addGestureRecognizer:tapGesture];
    UISwipeGestureRecognizer *swipDownGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(tableviewSwipeDown:)];
    [swipDownGesture setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.imageInfoTableView addGestureRecognizer:swipDownGesture];
    UISwipeGestureRecognizer *swipUpGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(tableviewSwipeUp:)];
    [swipUpGesture setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.imageInfoTableView addGestureRecognizer:swipUpGesture];
}
-(void)initTopBar
{
    self.topBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WZ_APP_SIZE.width,50)];
    [self.topBarView setBackgroundColor:DARK_PARENT_BACKGROUND_COLOR];
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(13, 13, 24, 24)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBarView addSubview:backButton];
    UIButton *postButton = [[UIButton alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width-70, 5, 70, 40)];
    [postButton setTitle:@"发布" forState:UIControlStateNormal];
    [postButton setBigButtonAppearance];
    [postButton setTitleColor:THEME_COLOR_DARK forState:UIControlStateNormal];
    [postButton addTarget:self action:@selector(PostButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBarView addSubview:postButton];
    
    CGRect rect = CGRectMake((CGRectGetWidth(self.topBarView.bounds)-100)/2, 0, 100, CGRectGetHeight(self.topBarView.bounds));
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:rect];
    titleLabel.text = @"添加信息";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [self.topBarView addSubview:titleLabel];
    [self.view addSubview:self.topBarView];
}
-(void)initSendButton
{
    self.postButton = [[UIButton alloc]initWithFrame:CGRectMake(0, WZ_DEVICE_SIZE.height - 48, WZ_APP_SIZE.width, 48)];
    [self.postButton setBackgroundColor:THEME_COLOR_DARK];
    [self.postButton setTitle:@"发布" forState:UIControlStateNormal];
    [self.postButton addTarget:self action:@selector(PostButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.postButton];
}
#pragma mark -buttons
-(void)backBarButtonClick:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"backToFilterPage" object:nil userInfo:@{@"imagesAndInfo":self.imagesAndInfo}];
}
-(void)PostButtonPressed:(UIBarButtonItem *)sender
{
    
    if(self.postImageDescription.text)
    {
        self.whatsGoingOnItem.imageDescription = self.postImageDescription.text;
    }
    self.whatsGoingOnItem.imageUrlString = @"";
    self.whatsGoingOnItem.likeCount = 0;
    self.whatsGoingOnItem.comment = @"";

    [self.postImageDescription resignFirstResponder];
    //发布照片信息,上传到七牛;上传成功后提示并转回主页
    //[self dismissViewControllerAnimated:YES completion:nil];
    //[[NSNotificationCenter defaultCenter]postNotificationName:@"finishPostImage" object:nil];
    [self uploadPhotoToQiNiu];
    [self shareAction];
    
    
}

-(void)showImageDetail:(UITapGestureRecognizer *)gesture
{
    if ([self.postImageDescription isFirstResponder])
    {
        [self.postImageDescription resignFirstResponder];
    }
    UIImageView *imageView = (UIImageView *)gesture.view;
    __block NSMutableArray *images = [[NSMutableArray alloc]init];
    __block NSMutableArray *infos = [[NSMutableArray alloc]init];
    [self.imagesAndInfo enumerateObjectsUsingBlock:^(NSDictionary *imageAndInfo, NSUInteger idx, BOOL *stop) {
        [images addObject:[imageAndInfo objectForKey:@"image"]];
        [infos addObject:[imageAndInfo objectForKey:@"imageInfo"]];
    }];
    ImageDetailView *detailView = [[ImageDetailView alloc]initWithImages:images currentImageIndex:imageView.tag];
    [detailView setImagesInfo:infos];
    [detailView show];
}

-(void)uploadPhotoToQiNiu
{
    //获取token和filename请求
    /*
     1.通知主页开始上传，将数据传到主页
     2.转回到主页，显示上传进度,并进行上传操作
     3.后台开始处理数据，转化为nsdata类型
     4.对于每条data数据，逐个请求token 并上传
     */
    //1 & 2
    NSString *photoDescription = self.postImageDescription.text;
    POI *uploadPoi;
    if (self.hasPoi && self.poiInfo)
    {
        uploadPoi = self.poiInfo;
    }
    else
    {
        uploadPoi = [[POI alloc]init];
        uploadPoi.uid = @"";
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"beginUploadPhotos" object:nil userInfo:@{@"imagesAndInfo":self.imagesAndInfo,@"photoDescription":photoDescription,@"poiInfo":uploadPoi}];
}

#pragma mark - addressSearchTableviewDelegate
-(void)finishSelectAddress:(POI *)addressInfo
{
    self.poiInfo = addressInfo;
    if (self.poiInfo == nil || [self.poiInfo.name isEqualToString:@""])
    {
        self.hasPoi = NO;
        self.addressTableViewCell.textLabel.text = @"标记位置";
    }
    else
    {
        self.hasPoi = YES;
        self.addressTableViewCell.textLabel.text = self.poiInfo.name;
    }
}

#pragma mark - tableviewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return ceil((float)self.imagesAndInfo.count/5)*(PHOTOWIDTH + 4) + 4;
    }
    else if (indexPath.section == 1)
    {
        return 100.0f;
    }
    else if (indexPath.section == 2)
    {
        return 50.0f;
    }
    
    else if (indexPath.section == 3)
    {
        return 80.0f;
    }
    return 44.0f;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    if (indexPath.section == 0 && indexPath.row ==0)
    {
        float spacing = 4;
        [self.imagesAndInfo enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(spacing+ (PHOTOWIDTH+spacing)*(idx%5) , spacing+(PHOTOWIDTH+spacing)*(idx/5), PHOTOWIDTH, PHOTOWIDTH)];
            [imageView setImage:[obj objectForKey:@"image"]];
            [imageView setTag:idx];
            [imageView.layer setMasksToBounds:YES];
            [imageView.layer setCornerRadius:4.0f];
            UITapGestureRecognizer *imageClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showImageDetail:)];
            [imageView addGestureRecognizer:imageClick];
            [imageView setUserInteractionEnabled:YES];
            [cell.contentView addSubview:imageView];
            [cell setBackgroundColor:[UIColor clearColor]];
        }];
    }
    else if (indexPath.section == 1 && indexPath.row == 0 )
    {
        self.postImageDescription = [[PlaceholderTextView alloc]initWithFrame:CGRectMake(8, 8, WZ_APP_SIZE.width - 16, 84)];
        self.postImageDescription.placeholder = @"添加照片说明";
        self.postImageDescription.placeholderFont = WZ_FONT_COMMON_SIZE;
        [self.postImageDescription setFont:WZ_FONT_COMMON_SIZE];
        [cell.contentView addSubview:self.postImageDescription];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 2 && indexPath.row ==0 )
    {
        [self setCurrentLocation];
        self.addressTableViewCell = cell;
        cell.imageView.image = [UIImage imageNamed:@"map-marker"];
       // cell.textLabel.text = @"标记位置";
        [cell.textLabel setFont:WZ_FONT_LARGE_SIZE];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UITapGestureRecognizer *addressCellClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addressCellClick:)];
        [self.addressTableViewCell addGestureRecognizer:addressCellClick];
    }
    
    else if (indexPath.section == 3)
    {
        if (!_shareToWeChatTimeLine)
        {
            _shareToWeChatTimeLine = [[UIImageView alloc ]initWithImage:[UIImage imageNamed:@"wechat_off"] highlightedImage:[UIImage imageNamed:@"wechat_icon"]];
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(shareToWeChatTimeLineClick:)];
            [_shareToWeChatTimeLine addGestureRecognizer:gesture];
            [_shareToWeChatTimeLine setUserInteractionEnabled:YES];
            [_shareToWeChatTimeLine setFrame:CGRectMake(32 , 18, 48, 48)];
        }
        if (!_shareToQQZone)
        {
            _shareToQQZone = [[UIImageView alloc ]initWithImage:[UIImage imageNamed:@"qzone_off"] highlightedImage:[UIImage imageNamed:@"qzone_icon"]];
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(shareToQQZoneClick:)];
            [_shareToQQZone addGestureRecognizer:gesture];
            [_shareToQQZone setUserInteractionEnabled:YES];
            [_shareToQQZone setFrame:CGRectMake(32*2+48 , 18, 48, 48)];
            
        }
        [cell addSubview:_shareToSinaWebo];
        [cell addSubview:_shareToWeChatTimeLine];
        [cell addSubview:_shareToQQZone];
    }
    return cell;
}

#pragma mark - address  ReGeocode
-(void)setCurrentLocation
{
    if ([self.postImageInfo objectForKey:@"{GPS}"])
    {
        NSDictionary *GPSInfo = [self.postImageInfo objectForKey:@"{GPS}"];
        NSString * latitude = [GPSInfo objectForKey:@"Latitude"];
        NSString * longitude = [GPSInfo objectForKey:@"Longitude"];
        searchLocation = [[CLLocation alloc]initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [self regeoLocation];
    }
    else
    {
        if (!self.locationUtility)
        {
           self.locationUtility = [[CLLocationUtility alloc]init];
        }
        
        [self.locationUtility getCurrentLocationWithComplete:^(NSDictionary *result) {
            if ([[result objectForKey:@"success"]isEqualToString:@"NO"])
            {
                NSLog(@"定位失败");
            }
            else
            {
                searchLocation = [result objectForKey:@"location"];
                [self regeoLocation];
            }
        }];

    }

}


-(void)regeoLocation
{
    // searchLocation = [[CLLocation alloc]initWithLatitude:29.646064 longitude:91.00334];
    if ([Geodetic isInsideChina:searchLocation])
    {
        CLLocation *marsLocation = [Geodetic transFromGPSToMars:searchLocation];
        _search =  [[AMapSearchAPI alloc]initWithSearchKey:GAODE_SDK_KEY Delegate:self];
        AMapReGeocodeSearchRequest *regeoRequest = [[AMapReGeocodeSearchRequest alloc]init];
        regeoRequest.searchType = AMapSearchType_ReGeocode;
        regeoRequest.location = [AMapGeoPoint locationWithLatitude:marsLocation.coordinate.latitude longitude:marsLocation.coordinate.longitude];
        regeoRequest.radius = 1000;
        regeoRequest.requireExtension = NO;
        [_search AMapReGoecodeSearch:regeoRequest];
    }
    else
    {
        [[POISearchAPI sharedInstance]regeoGoogleLocation:searchLocation.coordinate.latitude longitude:searchLocation.coordinate.longitude whenComplete:^(NSDictionary *result) {
            if ( [result objectForKey:@"data"])
            {
                self.poiInfo = [[POI alloc]init];
                self.provinceInfo = [[POI alloc]init];
                self.hasPoi = YES;
                [self.poiInfo configureWithGoogleSearchResult:[[result objectForKey:@"data"]objectForKey:@"poiInfo" ]];
                [self.provinceInfo configureWithGoogleSearchResult:[[result objectForKey:@"data"]objectForKey:@"poiInfo" ]];
                self.addressTableViewCell.textLabel.text = [NSString stringWithFormat:@"%@",self.poiInfo.name];
            }
            else if ([result objectForKey:@"error"])
            {
                [SVProgressHUD showErrorWithStatus:[result objectForKey:@"error"]];
                [self.addressTableViewCell.textLabel setText:@"选择地址"];
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:@"获取地址失败"];
                [self.addressTableViewCell.textLabel setText:@"选择地址"];
            }
        }];
    }
}
-(void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode != nil)
    {
        NSString *result = [NSString stringWithFormat:@"ReGeocode: %@", response.regeocode];
        NSLog(@"ReGeo: %@", result);
        AMapAddressComponent *addressComponent = response.regeocode.addressComponent;
        self.poiInfo = [[POI alloc]init];
        self.provinceInfo = [[POI alloc]init];
        self.hasPoi = YES;
        [self.poiInfo configureWithGaodeaddressComponent:addressComponent];
        if ([self.poiInfo.location isEqualToString:@"0.000000,0.000000"])
        {
            self.poiInfo.location = [NSString stringWithFormat:@"%f,%f",request.location.latitude,request.location.longitude];
        }
        [self.provinceInfo configureWithGaodeaddressComponent:addressComponent];
        if ([self.provinceInfo.location isEqualToString:@"0.000000,0.000000"])
        {
            self.provinceInfo.location = [NSString stringWithFormat:@"%f,%f",request.location.latitude,request.location.longitude];
        }
        self.addressTableViewCell.textLabel.text = [NSString stringWithFormat:@"%@ · %@",self.poiInfo.city,self.poiInfo.name];
    }
}

#pragma mark -dataformat

- (NSString *)getDateTimeString
{
    NSDateFormatter *formatter;
    NSString        *dateString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss"];
    
    dateString = [formatter stringFromDate:[NSDate date]];
    
    return dateString;
}


- (NSString *)randomStringWithLength:(int)len
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int)[letters length])]];
    }
    
    return randomString;
}

#pragma mark - gesture actions
-(void)shareAction
{
    /*
    if ([self.shareToSinaWebo isHighlighted])
    {
        [self shareToPlatform:UMShareToSina next:nil];
    }*/
    if ([self.shareToWeChatTimeLine isHighlighted])
    {
        if ([self.shareToQQZone isHighlighted])
        {
            [self shareToPlatform:UMShareToWechatTimeline next:UMShareToQzone];
        }
        else
        {
            [self shareToPlatform:UMShareToWechatTimeline next:nil];
        }
    }
    else if ([self.shareToQQZone isHighlighted])
    {
         [self shareToPlatform:UMShareToQzone next:nil];
    }
}

-(void)shareToPlatform:(NSString *)platformName next:(NSString *)nextPlatformName
{
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
    [UMSocialData defaultData].extConfig.qqData.title = @"";
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
    NSString *shareContent = self.postImageDescription.text;
    UIImage *shareImage = [self.imagesAndInfo[0] objectForKey:@"image"];
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[platformName] content:shareContent image:shareImage location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
        if (nextPlatformName != nil)
        {
            [self shareToPlatform:nextPlatformName next:nil];
        }
        if (response.responseCode == UMSResponseCodeSuccess) {
            NSLog(@"分享成功！");
        }
    }];
    
}
-(void)shareToWeChatTimeLineClick:(UITapGestureRecognizer *)gesture
{
    UIImageView *imageView = (UIImageView *)gesture.view;
    [imageView setHighlighted:!imageView.highlighted];
}
-(void)shareToQQMessage:(UITapGestureRecognizer *)gesture
{
    
}
-(void)shareToQQZoneClick:(UITapGestureRecognizer *)gesture
{
    UIImageView *imageView = (UIImageView *)gesture.view;
    [imageView setHighlighted:!imageView.highlighted];
}
-(void)shareToSinaWeboClick:(UITapGestureRecognizer *)gesture
{
    UIImageView *imageView = (UIImageView *)gesture.view;
    [imageView setHighlighted:!imageView.highlighted];
    
    //检查新浪微博授权
    //[self shareToPlatform:UMShareToSina];
}
-(void)addressCellClick:(UITapGestureRecognizer *)gesture
{
    AddressSearchTableViewController *searchCon = [[AddressSearchTableViewController alloc]init];
    searchCon.delegate = self;
    if (self.poiInfo)
    {
        searchCon.poiInfo = self.poiInfo;
    }
    if (self.provinceInfo)
    {
        searchCon.provincePoiInfo = self.provinceInfo;
    }
    if ([self.postImageInfo objectForKey:@"{GPS}"])
    {
        NSDictionary *GPSInfo = [self.postImageInfo objectForKey:@"{GPS}"];
        NSString * latitude = [GPSInfo objectForKey:@"Latitude"];
        NSString * longitude = [GPSInfo objectForKey:@"Longitude"];
        searchCon.location = [[CLLocation alloc]initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [self presentViewController:searchCon animated:YES completion:nil];
        /*
        
        UIAlertController *alertController =[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *choosePhotoLocationAction = [UIAlertAction actionWithTitle:@"标记拍照位置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSDictionary *GPSInfo = [self.postImageInfo objectForKey:@"{GPS}"];
            NSString * latitude = [GPSInfo objectForKey:@"Latitude"];
            NSString * longitude = [GPSInfo objectForKey:@"Longitude"];
            searchCon.location = [[CLLocation alloc]initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
            [self presentViewController:searchCon animated:YES completion:nil];

        }];
        UIAlertAction *chooseNearByLocationAction = [UIAlertAction actionWithTitle:@"标记当前位置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            searchCon.location = nil;
            [self presentViewController:searchCon animated:YES completion:nil];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:choosePhotoLocationAction];
        [alertController addAction:chooseNearByLocationAction];
        
        [self presentViewController:alertController animated:YES completion:nil];*/
        
    }
    else
    {
        searchCon.location =nil;
        [self presentViewController:searchCon animated:YES completion:nil];
    }
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![self.postImageDescription isExclusiveTouch])
    {
        self.whatsGoingOnItem.imageDescription = self.postImageDescription.text;
        [self.postImageDescription resignFirstResponder];
    }
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([self.postImageDescription isFirstResponder])
    {
        [self.postImageDescription resignFirstResponder];
    }
    return YES;
}

-(void)tableviewTouch:(UIGestureRecognizer *)gesture
{
    if (gesture.view != self.postImageDescription)
    {
        if ([self.postImageDescription isFirstResponder])
        {
            [self.postImageDescription resignFirstResponder];
        }
    }
}
-(void)tableviewSwipeDown:(UIGestureRecognizer *)gesture
{
    if (gesture.view != self.postImageDescription)
    {
        if ([self.postImageDescription isFirstResponder])
        {
            [self.postImageDescription resignFirstResponder];
        }
    }
}
-(void)tableviewSwipeUp:(UIGestureRecognizer *)gesture
{
    if (gesture.view != self.postImageDescription)
    {
        if ([self.postImageDescription isFirstResponder])
        {
            [self.postImageDescription resignFirstResponder];
        }
    }
}

@end
