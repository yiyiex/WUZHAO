//
//  AddressSearchTableViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/4/12.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "AddressSearchTableViewController.h"

#import "UIButton+ChangeAppearance.h"
#import "UIView+ChangeAppearance.h"
#import "AddressTableViewCell.h"


#import "captureMacro.h"
#import "macro.h"
#import "Geodetic.h"

#import <AMapSearchKit/AMapSearchAPI.h>
#import <MAMapKit/MAMapKit.h>
#import <MapKit/MapKit.h>



@interface AddressSearchTableViewController ()<CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,AMapSearchDelegate>
{
    AMapSearchAPI *_search;
    CLLocationManager *_locationManager;
    CGPoint postImageCenter;
    UIView *greyMaskView;
    UIActivityIndicatorView *_aiv;
}
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSIndexPath *currentAddressTableSelectedIndex;
@property (nonatomic ,strong)  NSMutableArray *addressDataSource;
@property (nonatomic ,strong)  NSMutableArray *searchAddressDataSource;
@property (nonatomic) BOOL searchControllerWasActive;


@end

@implementation AddressSearchTableViewController
static NSString *searchKeyWords = @"商场|娱乐|风景|餐饮|住宅|科教|机场|车站";
- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchControllerWasActive = NO;
    [self initTopBar];
    [self initTableView];
    if (self.addressDataSource.count<=0)
    {
        [self searchAddress];
    }
    NSLog(@"location info %@",self.location);

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSMutableArray *)addressDataSource
{
    if (!_addressDataSource)
    {
        _addressDataSource = [[NSMutableArray alloc]init];
    }
    return _addressDataSource;
}
-(NSMutableArray *)searchAddressDataSource
{
    if (!_searchAddressDataSource)
    {
        _searchAddressDataSource = [[NSMutableArray alloc]init];
    }
    return _searchAddressDataSource;
}


#pragma mark - initview
-(void)initTopBar
{
    UIView *topBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WZ_APP_SIZE.width,50)];
    [topBarView setBackgroundColor:DARK_PARENT_BACKGROUND_COLOR];
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(8, 8, 40,40)];
    [backButton.titleLabel setFont:WZ_FONT_COMMON_SIZE];
    [backButton setTitle:@"取消" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [topBarView addSubview:backButton];
    
    CGRect rect = CGRectMake((CGRectGetWidth(topBarView.bounds)-100)/2, 0, 100, CGRectGetHeight(topBarView.bounds));
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:rect];
    titleLabel.text = @"标记位置";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [topBarView addSubview:titleLabel];
    [self.view addSubview:topBarView];
}

-(void)initTableView
{
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, WZ_APP_SIZE.width, 44)];
    [_searchBar setBarStyle:UIBarStyleDefault];
    [_searchBar setPlaceholder:@"搜索更多地址"];
    _searchBar.delegate = self;
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 50, WZ_APP_SIZE.width, WZ_APP_SIZE.height-50) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"AddressTableViewCell" bundle:nil] forCellReuseIdentifier:@"addressInfoCell"];
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"addressInfoCell"];
    self.tableView.tableHeaderView = _searchBar;
    [self.view addSubview:self.tableView];
    
    UISwipeGestureRecognizer *swipGesture;
    swipGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeUp:)];
    swipGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [self.tableView addGestureRecognizer:swipGesture];
    swipGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeDown:)];
    swipGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self.tableView addGestureRecognizer:swipGesture];
}

#pragma mark -swipe gesture
-(void)swipeUp:(UISwipeGestureRecognizer*)gesture
{
    [self hideKeyboard];
}
-(void)swipeDown:(UISwipeGestureRecognizer *)gesture
{
    [self hideKeyboard];
}
-(void)hideKeyboard
{
    if ([self.searchBar isFirstResponder])
    {
        [self.searchBar resignFirstResponder];
    }
}

#pragma mark- location
-(void)searchAddress
{
    if (!_aiv)
    {
        _aiv = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _aiv.center = self.view.center;
        [self.view addSubview:_aiv];
    }
    [_aiv startAnimating];
    
    //如果当前有照片的经纬度信息
    if (self.location)
    {
        [self searchAddressWithLocation:self.location];
    }
    else
    {
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
        _locationManager.distanceFilter = 500;
        [_locationManager startUpdatingLocation];
    }
}
#pragma mark - CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"location failed!");
    [self.addressDataSource removeAllObjects];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"location success");
    NSLog(@"location: %@",locations);
    [manager stopUpdatingLocation];
    CLLocation *location = locations.lastObject;
    [self searchAddressWithLocation:location];
    
}

#pragma mark - searchBar delegate
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchControllerWasActive = NO;
    if([_aiv isAnimating])
    {
        [_aiv stopAnimating];
    }
    [self.searchBar setText:nil];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
    [self.tableView reloadData];
    NSLog(@"cancel search");
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"did end search edit");
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"begin search");
    self.searchControllerWasActive = YES;
    if (!_aiv)
    {
        _aiv = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _aiv.center = self.view.center;
        [self.view addSubview:_aiv];
    }
    [_aiv startAnimating];
    
    NSLog(@"searchBy : %@",_searchBar.text);
    [self searchAddressWithKeyword:_searchBar.text];
    
}
#pragma mark - search With Location
-(void)searchAddressWithLocation:(CLLocation *)location
{
    _search = [[AMapSearchAPI alloc]initWithSearchKey:@"2552aafe945c02ece19c41739007ca14" Delegate:self];
    NSLog(@"world location %f %f",location.coordinate.latitude,location.coordinate.longitude);
    CLLocation *marsLocation = [Geodetic transFromGPSToMars:location];
     NSLog(@"mars location %f %f",marsLocation.coordinate.latitude,marsLocation.coordinate.longitude);
    
    AMapPlaceSearchRequest *poiRequest = [[AMapPlaceSearchRequest alloc]init];
    poiRequest.searchType = AMapSearchType_PlaceAround;
    AMapGeoPoint *postImageGeoPoint = [[AMapGeoPoint alloc]init];
    postImageGeoPoint.latitude = marsLocation.coordinate.latitude;
    postImageGeoPoint.longitude = marsLocation.coordinate.longitude;
    NSLog(@"location :%f-----%f",postImageGeoPoint.latitude,postImageGeoPoint.longitude);
    poiRequest.location = postImageGeoPoint;
    
    poiRequest.keywords = searchKeyWords;
    //poiRequest.types = @"050000";
    poiRequest.radius = 500;
    poiRequest.sortrule = 1;
    poiRequest.offset = 50;
    poiRequest.requireExtension = YES;
    [_search AMapPlaceSearch:poiRequest];
}
#pragma mark - search With keyword
-(void)searchAddressWithKeyword:(NSString *)keyword
{
    _search = [[AMapSearchAPI alloc]initWithSearchKey:@"2552aafe945c02ece19c41739007ca14" Delegate:self];
    
    AMapPlaceSearchRequest *poiRequest = [[AMapPlaceSearchRequest alloc]init];
    poiRequest.searchType = AMapSearchType_PlaceKeyword;
    poiRequest.keywords = keyword;
    //poiRequest.types = @"050000";
    poiRequest.sortrule = 1;
    //poiRequest.offset = 30;
    poiRequest.requireExtension = YES;
    [_search AMapPlaceSearch:poiRequest];
}
#pragma mark -amapSearch delegate
-(void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response
{
    if (_aiv)
    {
        [_aiv stopAnimating];
    }
    NSLog(@"on place search Done %@",response);
    if (self.searchControllerWasActive)
    {
        [self.searchAddressDataSource removeAllObjects];
        NSString *strPoi = @"";
        for (AMapPOI *p in response.pois) {
            strPoi = [NSString stringWithFormat:@"%@\nPOI: %@", strPoi, p.description];
            POI *poiInfo = [[POI alloc]init];
            poiInfo.uid = p.uid;
            poiInfo.name = p.name;
            poiInfo.address = p.address;
            poiInfo.city = p.city;
            poiInfo.district = p.district;
            poiInfo.province = p.province;
            poiInfo.stamp = p.timestamp;
            NSString *location = [NSString stringWithFormat:@"%f,%f",p.location.latitude,p.location.longitude];
            poiInfo.location = location;
            poiInfo.classify = p.type;
            
            [self.searchAddressDataSource addObject:poiInfo];
        }
    }
    else
    {
        //通过AMapPlaceSearchResponse对象处理搜索结果
        [self.addressDataSource removeAllObjects];
        NSString *strPoi = @"";
        for (AMapPOI *p in response.pois) {
            if (p.weight <0.20)
            {
                continue;
            }
            strPoi = [NSString stringWithFormat:@"%@\nPOI: %@", strPoi, p.description];
            POI *poiInfo = [[POI alloc]init];
            poiInfo.uid = p.uid;
            poiInfo.name = p.name;
            poiInfo.address = p.address;
            poiInfo.city = p.city;
            poiInfo.district = p.district;
            poiInfo.province = p.province;
            poiInfo.stamp = p.timestamp;
            NSString *location = [NSString stringWithFormat:@"%f,%f",p.location.latitude,p.location.longitude];
            poiInfo.location = location;
            poiInfo.classify = p.type;
            [self.addressDataSource addObject:poiInfo];
        }
        
    }
    [self.tableView reloadData];
    
}
#pragma mark -tableview delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchControllerWasActive)
    {
        if (self.searchAddressDataSource.count == 0)
        {
            return 1;
        }
        return self.searchAddressDataSource.count;
    }
    else
    {
        return self.addressDataSource.count+1;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8"))
    {
        return UITableViewAutomaticDimension;
    }
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddressTableViewCell *cell;
    if (!self.poiInfo && indexPath.row == 0)
    {
        self.currentAddressTableSelectedIndex = indexPath;
    }
    if (self.searchControllerWasActive)
    {
        if (indexPath.row == 0 && self.searchAddressDataSource.count ==0)
        {
            cell = [[AddressTableViewCell alloc]init];
            cell.textLabel.text = @"未搜索到结果，建议输入更详细一点";
            [cell.textLabel setFont:WZ_FONT_LARGE_BOLD_SIZE];
            [cell.textLabel setTextColor:THEME_COLOR_DARKER_GREY];
        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"addressInfoCell" forIndexPath:indexPath];
            if (!cell)
            {
                cell = [[AddressTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"addressInfoCell"];
            }
            
            POI *poiInfo = [self.searchAddressDataSource objectAtIndex:(indexPath.row)];
            if ([self.poiInfo.uid isEqualToString:poiInfo.uid])
            {
                self.currentAddressTableSelectedIndex = indexPath;
            }
            cell.addressLabel.text = [NSString stringWithFormat:@"%@",poiInfo.name];
            cell.detailAddressLabel.text =[NSString stringWithFormat:@"%@%@",poiInfo.city,poiInfo.address];
            [cell setAppearance];
            /*
            cell.textLabel.text = [NSString stringWithFormat:@"%@",poiInfo.name];
            cell.detailTextLabel.text =[NSString stringWithFormat:@"%@%@",poiInfo.city,poiInfo.address];
             */
        }
        
    }
    else
    {
        if (indexPath.row == 0)
        {
            cell = [[AddressTableViewCell alloc]init];
            cell.textLabel.text = @"不显示位置";
            [cell.textLabel setFont:WZ_FONT_LARGE_BOLD_SIZE];
            [cell.textLabel setTextColor:THEME_COLOR_DARK];
        }
        else if (indexPath.row >0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"addressInfoCell" forIndexPath:indexPath];
            if (!cell)
            {
               cell = [[AddressTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"addressInfoCell"];
            }
            POI *poiInfo = [self.addressDataSource objectAtIndex:(indexPath.row-1)];
            if ([self.poiInfo.uid isEqualToString:poiInfo.uid])
            {
                self.currentAddressTableSelectedIndex = indexPath;
            }
            cell.addressLabel.text = [NSString stringWithFormat:@"%@",poiInfo.name];
            cell.detailAddressLabel.text =[NSString stringWithFormat:@"%@%@",poiInfo.city,poiInfo.address];
            [cell setAppearance];
            //return cell;
        }
        if (indexPath == self.currentAddressTableSelectedIndex)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.searchControllerWasActive)
    {
        if (self.searchAddressDataSource.count == 0)
        {
            return;
        }
        POI *poiInfo = [self.searchAddressDataSource objectAtIndex:(indexPath.row)];
        // self.whatsGoingOnItem.imageDescription = @"";
        self.poiInfo = poiInfo;
        [[self.tableView cellForRowAtIndexPath:self.currentAddressTableSelectedIndex] setAccessoryType:UITableViewCellAccessoryNone];
        self.currentAddressTableSelectedIndex = indexPath;
        [[self.tableView cellForRowAtIndexPath:self.currentAddressTableSelectedIndex] setAccessoryType:UITableViewCellAccessoryCheckmark];
        if ([self.delegate respondsToSelector:@selector(finishSelectAddress:)])
        {
            [self.delegate finishSelectAddress:self.poiInfo];
        }
        [self dismissViewControllerAnimated:YES completion:^{

        }];
        
    }
    else
    {
        if (indexPath.row >0)
        {
            POI *poiInfo = [self.addressDataSource objectAtIndex:(indexPath.row -1)];
            // self.whatsGoingOnItem.imageDescription = @"";
            self.poiInfo = poiInfo;
        }
        else
        {
            self.poiInfo = nil;
        }
        if ([self.delegate respondsToSelector:@selector(finishSelectAddress:)])
        {
            [self.delegate finishSelectAddress:self.poiInfo];
        }
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
        [[self.tableView cellForRowAtIndexPath:self.currentAddressTableSelectedIndex] setAccessoryType:UITableViewCellAccessoryNone];
        self.currentAddressTableSelectedIndex = indexPath;
        [[self.tableView cellForRowAtIndexPath:self.currentAddressTableSelectedIndex] setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    // self.currentAddressTableSelectedIndex = indexPath;
    
    
}

#pragma mark - action
-(void)backBarButtonClick:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
