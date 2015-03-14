//
//  AddImageInfoViewController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-21.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "AddImageInfoViewController.h"
#import "AddressInfoList.h"

#import "QDYHTTPClient.h"
#import "SVProgressHUD.h"

#import "QiniuSDK.h"

#import <AMapSearchKit/AMapSearchAPI.h>
#import <CoreLocation/CoreLocation.h>


//#define PIOTKEYWORDS @"餐饮|购物|生活|体育|住宿|风景|地名|商务|科教|公司";
#define POIKEYWORDS @"餐饮|风景"
#define poi_privider 1

@interface AddImageInfoViewController()<AMapSearchDelegate,CLLocationManagerDelegate>
{
    AMapSearchAPI *_search;
    CLLocationManager *_locationManager;
}
@property (nonatomic ,strong)  NSMutableArray *addressDataSource;

@property (nonatomic) BOOL hasPoi;
@property (nonatomic ,strong) NSMutableDictionary *poiInfo;

@property (atomic) float progress;
@end

@implementation AddImageInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = NO;
    self.postImageView.image = self.postImage;
    self.hasPoi = NO;
    [self searchAddress];

}
#pragma mark -datas
- (NSArray *) addressDataSource
{
    if (!_addressDataSource)
    {
        _addressDataSource = [[NSMutableArray alloc]init];
    }
    return _addressDataSource;
}

-(NSMutableDictionary *)poiInfo
{
    if (!_poiInfo)
    {
        _poiInfo = [[NSMutableDictionary alloc]init];
        [_poiInfo setObject:@"" forKey:@"uid"];
        [_poiInfo setObject:@"" forKey:@"name"];
        [_poiInfo setObject:@"" forKey:@"classify"];
        [_poiInfo setObject:@"" forKey:@"location"];
        [_poiInfo setObject:@"" forKey:@"address"];
        [_poiInfo setObject:@"" forKey:@"province"];
        [_poiInfo setObject:@"" forKey:@"city"];
        [_poiInfo setObject:@"" forKey:@"district"];
        [_poiInfo setObject:@"" forKey:@"stamp"];
    }
    return _poiInfo;
}

-(UIImageView *)postImageView
{
    if (_postImage)
    {
        _postImageView.image = _postImage;
    }
    return _postImageView;
}

-(WhatsGoingOn *)whatsGoingOnItem
{
    if (!_whatsGoingOnItem)
    {
        _whatsGoingOnItem = [[WhatsGoingOn alloc]init];
    }
    return _whatsGoingOnItem;
}



#pragma mark -buttons

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
    [self uploadPhotoToQiNiu];


    
}

-(void)searchAddress
{
    _locationManager = [[CLLocationManager alloc]init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }
    _locationManager.distanceFilter = 50;
    [_locationManager startUpdatingLocation];
}

-(void)uploadPhotoToQiNiu
{
    
    //获取token和filename请求
    [SVProgressHUD showWithStatus:@"图片上传中..."];
    NSInteger userId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    NSString *photoDescription = self.postImageDescription.text;
    
    [[QDYHTTPClient sharedInstance] GetQiNiuTokenWithUserId:userId type:1 whenComplete:^(NSDictionary *result) {
        NSDictionary *data;
        if ([result objectForKey:@"data"])
        {
            data = [result objectForKey:@"data"];
            NSLog(@"%@",data);
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"获取token失败"];
            return ;
        }
        QNUploadManager *upLoadManager = [[QNUploadManager alloc]init];
        NSData *imageData = UIImageJPEGRepresentation(self.postImage, 1.0f);
        [upLoadManager putData:imageData key:[data objectForKey:@"imageName"] token:[data objectForKey:@"uploadToken"] complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp)
         {
            NSLog(@"%@",info);
            if (info.error)
            {
                [SVProgressHUD showErrorWithStatus:@"上传图片失败"];
            }
            else
            {


                //用户端提示
               [[QDYHTTPClient sharedInstance]PostPhotoInfomationWithUserId:userId
                                                                       method:@"post"
                                                                        photo:[data objectForKey:@"imageName"]
                                                                    thought:photoDescription
                                                                       haspoi:_hasPoi
                                                                     provider:poi_privider
                                                                          uid:[self.poiInfo valueForKey:@"uid"]
                                                                         name:[self.poiInfo valueForKey:@"name"]
                                                                     classify:[self.poiInfo valueForKey:@"classify"]
                                                                     location:[self.poiInfo valueForKey:@"location"]
                                                                      address:[self.poiInfo valueForKey:@"address"]
                                                                     province:[self.poiInfo valueForKey:@"province"]
                                                                         city:[self.poiInfo valueForKey:@"city"]
                                                                     district:[self.poiInfo valueForKey:@"district"]
                                                                        stamp:[self.poiInfo valueForKey:@"stamp"]
                                                                 whenComplete:^(NSDictionary *returnData)
                {
                    if (returnData)
                    {
                        [SVProgressHUD showSuccessWithStatus:@"上传图片成功"];
                    }
                    else
                    {
                        [SVProgressHUD showErrorWithStatus:@"上传图片失败"];
                    }
                    
                    NSLog(@"%lu",(unsigned long)[self.navigationController.viewControllers count]);
                    
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"finishPostImage" object:nil];
                    
                    //通知服务器并补充信息
                    //....

                }];

                
            }
            
            
        } option:nil];
    }];
   
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
/*
#pragma mark ===============alert delegate====================
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{

    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishPostImage" object:nil];
    [self.navigationController popViewControllerAnimated:YES];

    
}*/
#pragma mark - CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"location failed!");
    self.addressDataSource = nil;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"location success");
    NSLog(@"location: %@",locations);
    _search = [[AMapSearchAPI alloc]initWithSearchKey:@"2552aafe945c02ece19c41739007ca14" Delegate:self];
    AMapPlaceSearchRequest *poiRequest = [[AMapPlaceSearchRequest alloc]init];
    poiRequest.searchType = AMapSearchType_PlaceAround;
    AMapGeoPoint *postImageGeoPoint = [[AMapGeoPoint alloc]init];
    CLLocation *nowLocation = locations.lastObject;
    postImageGeoPoint.latitude = nowLocation.coordinate.latitude;
    postImageGeoPoint.longitude = nowLocation.coordinate.longitude;
    poiRequest.location = postImageGeoPoint;
    poiRequest.keywords = POIKEYWORDS;
    //poiRequest.types = @"050000";
    poiRequest.radius = 500;
    poiRequest.sortrule = 0;
    poiRequest.offset = 50;
    
    //poiRequest.requireExtension = YES;
    
    [_search AMapPlaceSearch:poiRequest];
    
}
#pragma mark -amapSearch delegaet
-(void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response
{
    NSLog(@"on place search Done");
    if (response.pois.count == 0)
    {
        return;
    }
    //通过AMapPlaceSearchResponse对象处理搜索结果
    [self.addressDataSource removeAllObjects];
    NSString *strCount = [NSString stringWithFormat:@"count: %ld",(long)response.count];
    NSString *strSuggestion = [NSString stringWithFormat:@"Suggestion: %@", response.suggestion];
    NSString *strPoi = @"";
    for (AMapPOI *p in response.pois) {
        strPoi = [NSString stringWithFormat:@"%@\nPOI: %@", strPoi, p.description];
        NSMutableDictionary *poiInfo = [[NSMutableDictionary alloc]init];
        [poiInfo setValue:p.uid forKey:@"uid"];
        [poiInfo setValue:p.name forKey:@"name"];
        [poiInfo setValue:p.address forKey:@"address"];
        [poiInfo setValue:p.city forKey:@"city"];
        [poiInfo setValue:p.district forKey:@"district"];
        [poiInfo setValue:p.province forKey:@"province"];
        [poiInfo setValue:p.timestamp forKey:@"stamp"];
        NSString *location = [NSString stringWithFormat:@"%f,%f",p.location.latitude,p.location.longitude];
        [poiInfo setValue:location forKey:@"location"];
        [poiInfo setValue:p.type forKey:@"classify"];
        [self.addressDataSource addObject:poiInfo];
    }
    NSString *result = [NSString stringWithFormat:@"%@ \n %@ \n %@", strCount, strSuggestion, strPoi];
    NSLog(@"Place: %@", result);
    [self.addressTableView reloadData];
    
}
#pragma mark -tableview delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.addressDataSource.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addressInfoCell" forIndexPath:indexPath];
    NSDictionary *poiInfo = [self.addressDataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[poiInfo valueForKey:@"name"]];
    cell.detailTextLabel.text =[NSString stringWithFormat:@"%@ %@",[poiInfo valueForKey:@"city"],[poiInfo valueForKey:@"district"]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.hasPoi = YES;
    
    NSDictionary *poiInfo = [self.addressDataSource objectAtIndex:indexPath.row];
   // self.whatsGoingOnItem.imageDescription = @"";
    self.poiInfo = [poiInfo copy];
    self.whatsGoingOnItem.poiName = [NSString stringWithFormat:@"%@~%@~%@",[poiInfo valueForKey:@"city"],[poiInfo valueForKey:@"district"],[poiInfo valueForKey:@"name"]];
    self.addressInfoLabel.text = [NSString stringWithFormat:@"   %@",self.whatsGoingOnItem.poiName];
    
}

#pragma mark -textview delegate
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
    return YES;
}

@end
