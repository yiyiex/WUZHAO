//
//  AddImageInfoViewController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-21.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "AddImageInfoViewController.h"
#import "AddressInfoList.h"
#import "AddressSearchTableViewController.h"

#import "QDYHTTPClient.h"
#import "SVProgressHUD.h"


#import "QiniuSDK.h"
#import "macro.h"

#import "UIButton+ChangeAppearance.h"
#import "UIView+ChangeAppearance.h"

#import <AMapSearchKit/AMapSearchAPI.h>
#import <CoreLocation/CoreLocation.h>
#import <ImageIO/ImageIO.h>


//#define PIOTKEYWORDS @"餐饮|购物|生活|体育|住宿|风景|地名|商务|科教|公司";
#define POIKEYWORDS @"餐饮"
#define poi_privider 1

@interface AddImageInfoViewController()<UITableViewDataSource,UITableViewDelegate,AddressSearchTableViewControllerDelegate,UITextViewDelegate,UITextFieldDelegate>
{
    AMapSearchAPI *_search;
    CLLocationManager *_locationManager;
    CGPoint postImageCenter;
    CGRect postImageFrame;
    UIView *greyMaskView;
    UIImageView *bigImageView;
}
@property (strong, nonatomic)  IBOutlet UITableView *imageInfoTableView;
@property (strong, nonatomic)  UIImageView *postImageView;
@property (strong, nonatomic)  PlaceholderTextView *postImageDescription;
@property (strong, nonatomic)  UITableViewCell *addressTableViewCell;

@property (nonatomic) BOOL hasPoi;
@property (nonatomic ,strong) POI *poiInfo;
@property (nonatomic ,strong) NSArray *addressDatasource;

@property (strong, nonatomic) UIButton *postButton;
@property (strong, nonatomic) UIView *topBarView;



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
        self.addressTableViewCell.textLabel.text = self.poiInfo.name;
    }
    else
    {
        self.addressTableViewCell.textLabel.text = @"标记位置";
    }
}

#pragma mark -datas



-(UIImageView *)postImageView
{
    if (_postImage)
    {
        _postImageView.image = _postImage;
    }
    return _postImageView;
}
-(NSDictionary *)postImageInfo
{
    if (!_postImageInfo)
    {
        NSData *imageData = UIImageJPEGRepresentation(_postImage, 1.0);
        CFDataRef imageDataRef = (__bridge CFDataRef)imageData;
        CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData(imageDataRef, NULL);
        _postImageInfo = (NSDictionary *) CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, NULL));
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
    
    [self initPostImageView];
}
-(void)initPostImageView
{
    self.postImageView.image = self.postImage;
    [self.postImageView.layer setMasksToBounds:YES];
    [self.postImageView.layer setCornerRadius:4.0f];
    UITapGestureRecognizer *imageClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showImageDetail:)];
    [self.postImageView addGestureRecognizer:imageClick];
    [self.postImageView setUserInteractionEnabled:YES];
}
-(void)initTopBar
{
    self.topBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WZ_APP_SIZE.width,50)];
    [self.topBarView setBackgroundColor:rgba_WZ(23,24,26,0.9)];
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
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"finishPostImage" object:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self uploadPhotoToQiNiu];
    });


    
}

-(void)showImageDetail:(UITapGestureRecognizer *)gesture
{
    if ([self.postImageDescription isFirstResponder])
    {
        [self.postImageDescription resignFirstResponder];
    }
    greyMaskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WZ_APP_SIZE.width, WZ_APP_SIZE.height)];
    [greyMaskView setBackgroundColor:[UIColor blackColor]];
    [greyMaskView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *greyMaskClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(greyMaskClick:)];
    [greyMaskView addGestureRecognizer:greyMaskClick];
    [self.view addSubview:greyMaskView];
    bigImageView= [UIImageView new];
    UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
    postImageFrame = [self.postImageView.superview convertRect:self.postImageView.frame toView:window];
    postImageCenter = [self.postImageView.superview convertPoint:self.postImageView.center toView:window];
    bigImageView.center = postImageCenter;
    bigImageView.frame = postImageFrame;
    bigImageView.image = self.postImageView.image;
    bigImageView.userInteractionEnabled = YES;
    self.postImageView.userInteractionEnabled = NO;
    UITapGestureRecognizer *bigImageClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backToSmallImage:)];
    [bigImageView addGestureRecognizer:bigImageClick];

    [self.view addSubview:bigImageView];
    [UIView animateWithDuration:0.5 animations:^{
        bigImageView.frame = CGRectMake(0, (WZ_APP_SIZE.height-WZ_APP_SIZE.width)/2, WZ_APP_SIZE.width, WZ_APP_SIZE.width);
    }];
}
-(void)backToSmallImage:(UITapGestureRecognizer *)gesture
{
    UIView *view = bigImageView;
    [UIView animateWithDuration:0.5 animations:^{
        view.frame = postImageFrame;
        view.center = postImageCenter;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
        [greyMaskView removeFromSuperview];
        self.postImageView.userInteractionEnabled = YES;
        
    }];
}
-(void)greyMaskClick:(UITapGestureRecognizer *)gesture
{
    UIView *view = bigImageView;
    [UIView animateWithDuration:0.5 animations:^{
        view.frame = postImageFrame;
        view.center = postImageCenter;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
        [greyMaskView removeFromSuperview];
        self.postImageView.userInteractionEnabled = YES;
        
    }];
}

-(void)uploadPhotoToQiNiu
{
    
    //获取token和filename请求
    [SVProgressHUD showWithStatus:@"图片上传中..."];
   
    NSInteger userId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    NSString *photoDescription = self.postImageDescription.text;
    POI *uploadPoi;
    if (self.poiInfo)
    {
        uploadPoi = self.poiInfo;
    }
    else
    {
        uploadPoi = [[POI alloc]init];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    [[QDYHTTPClient sharedInstance] GetQiNiuTokenWithUserId:userId type:1 whenComplete:^(NSDictionary *result) {
        NSDictionary *data;
        if ([result objectForKey:@"data"])
        {
            data = [result objectForKey:@"data"];
            NSLog(@"%@",data);
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:@"获取token失败"];
                return ;
            });
        
        }
        
        QNUploadManager *upLoadManager = [[QNUploadManager alloc]init];
        NSData *imageData = UIImageJPEGRepresentation(self.postImage, 0.7f);
        [upLoadManager putData:imageData key:[data objectForKey:@"imageName"] token:[data objectForKey:@"uploadToken"] complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp)
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
                 //用户端提示
                 [[QDYHTTPClient sharedInstance]PostPhotoInfomationWithUserId:userId
                                                                        photo:[data objectForKey:@"imageName"]
                                                                      thought:photoDescription
                                                                       haspoi:_hasPoi
                                                                     provider:poi_privider
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
                      
                      dispatch_async(dispatch_get_main_queue(), ^{
                          if ([returnData objectForKey:@"data"])
                          {
                              [SVProgressHUD showSuccessWithStatus:@"上传图片成功"];
                              [[NSNotificationCenter defaultCenter]postNotificationName:@"uploadDataSuccess" object:nil];
                          }
                          else if ([returnData objectForKey:@"error"])
                          {
                              [SVProgressHUD showErrorWithStatus:@"上传图片失败"];
                          }
                      });
          
                      
                  }];
                 
                 
             }
             
             
         } option:nil];
        
    }];
    });

   
}
#pragma mark - addressSearchTableviewDelegate
-(void)finishSelectAddress:(POI *)addressInfo
{
    self.poiInfo = addressInfo;
    if ([self.poiInfo.name isEqualToString:@""])
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
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 100.0f;
    }
    else if (indexPath.section == 1)
    {
        return 50.0f;
    }
    return 44.0f;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    if (indexPath.section == 0 && indexPath.row ==0)
    {
        self.postImageView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 8, 84, 84)];
        [self.postImageView setImage:self.postImage];
        self.postImageView.image = self.postImage;
        [self.postImageView.layer setMasksToBounds:YES];
        [self.postImageView.layer setCornerRadius:4.0f];
        UITapGestureRecognizer *imageClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showImageDetail:)];
        [self.postImageView addGestureRecognizer:imageClick];
        [self.postImageView setUserInteractionEnabled:YES];
        self.postImageDescription = [[PlaceholderTextView alloc]initWithFrame:CGRectMake(100, 8, WZ_APP_SIZE.width - 108, 84)];
        self.postImageDescription.placeholder = @"添加照片说明";
        self.postImageDescription.placeholderFont = WZ_FONT_COMMON_SIZE;
        [self.postImageDescription setFont:WZ_FONT_COMMON_SIZE];
        [cell.contentView addSubview:self.postImageView];
        [cell.contentView addSubview:self.postImageDescription];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 1 && indexPath.row ==0)
    {
        self.addressTableViewCell = cell;
        cell.imageView.image = [UIImage imageNamed:@"map-marker"];
        cell.textLabel.text = @"标记位置";
        [cell.textLabel setFont:WZ_FONT_LARGE_SIZE];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UITapGestureRecognizer *addressCellClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addressCellClick:)];
        [self.addressTableViewCell addGestureRecognizer:addressCellClick];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section ==1 && indexPath.row == 0)
    {
        AddressSearchTableViewController *searchCon = [[AddressSearchTableViewController alloc]init];
        searchCon.delegate = self;
        if (self.poiInfo)
        {
            searchCon.poiInfo = self.poiInfo;
        }
        [self presentViewController:searchCon animated:YES completion:nil];
        
        
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

-(void)addressCellClick:(UITapGestureRecognizer *)gesture
{
    AddressSearchTableViewController *searchCon = [[AddressSearchTableViewController alloc]init];
    searchCon.delegate = self;
    if (self.poiInfo)
    {
        searchCon.poiInfo = self.poiInfo;
    }
    if ([self.postImageInfo objectForKey:@"{GPS}"])
    {
        
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
        [self presentViewController:alertController animated:YES completion:nil];
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
