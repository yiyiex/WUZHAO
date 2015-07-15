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

#import "POISearchAPI.h"
#import "SVProgressHUD.h"

#import <AMapSearchKit/AMapSearchAPI.h>
#import <MAMapKit/MAMapKit.h>
#import <MapKit/MapKit.h>



@interface AddressSearchTableViewController ()<CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,AMapSearchDelegate>
{
    AMapSearchAPI *_search;
    CLLocationManager *_locationManager;
    CGPoint postImageCenter;
    UIView *greyMaskView;
    
    NSString *googleSearchNextPageToken;
}
@property (strong, nonatomic) UIButton *locationButton;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSIndexPath *currentAddressTableSelectedIndex;
@property (nonatomic ,strong)  NSMutableArray *addressDataSource;
@property (nonatomic ,strong)  NSMutableArray *searchAddressDataSource;
@property (nonatomic, strong) UITableView *historyAddressTableView;
@property (nonatomic, strong) NSMutableArray *historyAddressDataSource;
@property (nonatomic, strong) UIActivityIndicatorView *tableViewAiv;
@property (nonatomic, strong) UIActivityIndicatorView *locationButtonAiv;
@property (nonatomic) BOOL searchControllerWasActive;
@property (nonatomic) BOOL historyAddressViewActive;


@end

@implementation AddressSearchTableViewController
static NSString *searchKeyWords = @"商场|娱乐|风景|餐饮|住宅|科教|机场|车站";
- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchControllerWasActive = NO;
    [self initTopBar];
    [self initTableView];
    if (self.location)
    {
        [self.locationButton setSelected:YES];
    }
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
    
    UIButton *locationButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth( topBarView.bounds) - 50, 8, 44 , 44)];
    [locationButton setImage:[UIImage imageNamed:@"location_white"] forState:UIControlStateNormal];
    [locationButton setImage:[UIImage imageNamed:@"location_green"] forState:UIControlStateSelected];
    [locationButton addTarget:self action:@selector(switchLocation:) forControlEvents:UIControlEventTouchUpInside];
    self.locationButton = locationButton;
    [topBarView addSubview:self.locationButton];
    
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

-(void)initHistoryAddressTableView
{
    self.historyAddressTableView = [[UITableView alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width, 94, WZ_APP_SIZE.width, WZ_APP_SIZE.height - 94)];
    self.historyAddressTableView.delegate = self;
    self.historyAddressTableView.dataSource = self;
    [self.historyAddressTableView registerNib:[UINib nibWithNibName:@"AddressTableViewCell" bundle:nil] forCellReuseIdentifier:@"addressInfoCell"];
    
    [self.view addSubview:self.historyAddressTableView];
}
-(void)showHistoryAddressTableView
{
    _historyAddressViewActive = YES;
    [UIView animateWithDuration:0.3 animations:^{
        [self.historyAddressTableView setFrame:CGRectMake(0, 96, WZ_APP_SIZE.width, WZ_APP_SIZE.height - 94)];
    } completion:^(BOOL finished) {
        
        [self.historyAddressTableView reloadData];
    }];
}
-(void)hideHistoryAddressTableView
{
    _historyAddressViewActive = NO;
    [UIView animateWithDuration:0.3 animations:^{
        [self.historyAddressTableView setFrame:CGRectMake(WZ_APP_SIZE.width, 96, WZ_APP_SIZE.width, WZ_APP_SIZE.height - 94)];
    } completion:^(BOOL finished) {
        [self.tableView reloadData];
    }];
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
    [self startAiv];
    
    //如果当前有照片的经纬度信息
    if (self.location)
    {
        [self searchAddressWithLocation:self.location];
    }
    else
    {
        [self searchCurrentAddress];
    }
}
-(void)searchCurrentAddress
{
    [self startAiv];
    _locationManager = [[CLLocationManager alloc]init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }
    _locationManager.distanceFilter = 500;
    [_locationManager startUpdatingLocation];
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
    [self stopAiv];
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
    if (self.historyAddressViewActive)
    {
        [self hideHistoryAddressTableView];
    }
    
    NSLog(@"begin search");
    self.searchControllerWasActive = YES;
    [self startAiv];
    
    
    NSLog(@"searchBy : %@",_searchBar.text);
    [self searchAddressWithKeyword:_searchBar.text];
    
}
#pragma mark - search With Location
-(void)searchAddressWithLocation:(CLLocation *)location
{
    [self.addressDataSource removeAllObjects];
    [self.tableView reloadData];
    [self startAiv];
     //CLLocation *location2 = [[CLLocation alloc]initWithLatitude:-33.8670522 longitude:151.1957362];
    //CLLocation *location2 = [[CLLocation alloc]initWithLatitude:29.797155 longitude:119.69141];
    //判断是否在国内，国内通过高德SDK ，国外通过后台接口
    if (![Geodetic isInsideChina:location])
    {
        [[POISearchAPI sharedInstance]SearchAroundPOIWithLongitude:location.coordinate.longitude Latitude:location.coordinate.latitude radius:500 ignorepolitical:1 whenComplete:^(NSDictionary *result) {
            NSLog(@"%@",result);
            [self stopAiv];
            if ([result objectForKey:@"data"])
            {
                
                NSDictionary *data = [result objectForKey:@"data"];
                googleSearchNextPageToken = [data objectForKey:@"nextPageToken"];
                [self.addressDataSource removeAllObjects];
                if (self.provincePoiInfo)
                {
                    [self.addressDataSource addObject:self.provincePoiInfo];
                }
                for (NSDictionary *p in [data objectForKey:@"POIs"])
                {
                    POI *poiInfo = [[POI alloc]init];
                    [poiInfo configureWithGoogleSearchResult:p];
                    [self.addressDataSource addObject:poiInfo];
                }
                [self.tableView reloadData];
            }
            else if ([result objectForKey:@"error"])
            {
                [SVProgressHUD showErrorWithStatus:[result objectForKey:@"error"]];
            }
        }];
    }
    else
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
}

#pragma mark - search With keyword
-(void)searchAddressWithKeyword:(NSString *)keyword
{
    _search = [[AMapSearchAPI alloc]initWithSearchKey:GAODE_SDK_KEY Delegate:self];
    
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
    [self stopAiv];
    NSLog(@"on place search Done %@",response);
    if (self.searchControllerWasActive)
    {
        [self.searchAddressDataSource removeAllObjects];
        for (AMapPOI *p in response.pois) {
            POI *poiInfo = [[POI alloc]init];
            [poiInfo configureWithGaodeSearchResult:p];
            [self.searchAddressDataSource addObject:poiInfo];
        }
    }
    else
    {
        //通过AMapPlaceSearchResponse对象处理搜索结果
        [self.addressDataSource removeAllObjects];
        if (self.provincePoiInfo)
        {
            [self.addressDataSource addObject:self.provincePoiInfo];
        }
        for (AMapPOI *p in response.pois) {
            if (p.weight <0.20)
            {
                continue;
            }
            POI *poiInfo = [[POI alloc]init];
            [poiInfo configureWithGaodeSearchResult:p];
            [self.addressDataSource addObject:poiInfo];
        }
        
        
        
    }
    [self.tableView reloadData];
    
}
#pragma mark -tableview delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.historyAddressViewActive)
    {
        return self.historyAddressDataSource.count +1;
    }
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
        if (self.addressDataSource.count >0)
        {
            return self.addressDataSource.count+2;
        }
        return 1;
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
    if (self.historyAddressViewActive)
    {
        if (indexPath.row == 0 )
        {
            cell = [[UITableViewCell alloc]init];
            cell.textLabel.text = @"返回";
            cell.imageView.image = [UIImage imageNamed:@"back_arrow.png"];
            [cell.textLabel setFont:WZ_FONT_LARGE_SIZE];
            [cell.textLabel setTextColor:THEME_COLOR_LIGHT_GREY];
        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"addressInfoCell" forIndexPath:indexPath];
            if (!cell)
            {
                cell = [[AddressTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"addressInfoCell"];
            }
            
            POI *poiInfo = [self.historyAddressDataSource objectAtIndex:(indexPath.row-1)];
            cell.addressLabel.text = [NSString stringWithFormat:@"%@",poiInfo.name];
            cell.detailAddressLabel.text =[NSString stringWithFormat:@"%@%@",poiInfo.city,poiInfo.address];
            [cell setAppearance];
        }
    }
    else if (self.searchControllerWasActive)
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
        if (indexPath.row == 1)
        {
            cell = [[AddressTableViewCell alloc]init];
            cell.textLabel.text = @"不显示位置";
            [cell.textLabel setFont:WZ_FONT_LARGE_BOLD_SIZE];
            [cell.textLabel setTextColor:THEME_COLOR_DARK];
            if (self.poiInfo == nil)
            {
                self.currentAddressTableSelectedIndex = indexPath;
            }
        }
        if (indexPath.row == 0)
        {
            cell = [[UITableViewCell alloc]init];
            cell.textLabel.text = @"查看历史位置";
            cell.imageView.image = [UIImage imageNamed:@"history"];
            [cell.textLabel setFont:WZ_FONT_LARGE_SIZE];
            [cell.textLabel setTextColor:THEME_COLOR_LIGHT_GREY];
        }
        
        if (self.provincePoiInfo && indexPath.row == 2)
        {
            cell = [[AddressTableViewCell alloc]init];
            if (self.provincePoiInfo.type == POI_TYPE_GAODE)
            {
                cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",self.provincePoiInfo.city,self.provincePoiInfo.district];
            }
            else if (self.provincePoiInfo.type == POI_TYPE_GOOGLE)
            {
                cell.textLabel.text = [NSString stringWithFormat:@"%@",self.provincePoiInfo.name];
            }
            else
            {
                cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",self.provincePoiInfo.city,self.provincePoiInfo.district];
            }
            
            [cell.textLabel setFont:WZ_FONT_LARGE_BOLD_SIZE];
            if ([self.poiInfo.uid isEqualToString:self.provincePoiInfo.uid])
            {
                self.currentAddressTableSelectedIndex = indexPath;
            }
        }
        else if (self.provincePoiInfo && indexPath.row >2)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"addressInfoCell" forIndexPath:indexPath];
            if (!cell)
            {
               cell = [[AddressTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"addressInfoCell"];
            }
            POI *poiInfo = [self.addressDataSource objectAtIndex:(indexPath.row-2)];
            if ([self.poiInfo.uid isEqualToString:poiInfo.uid])
            {
                self.currentAddressTableSelectedIndex = indexPath;
            }
            cell.addressLabel.text = [NSString stringWithFormat:@"%@",poiInfo.name];
            cell.detailAddressLabel.text =[NSString stringWithFormat:@"%@%@",poiInfo.city,poiInfo.address];
            [cell setAppearance];
            //return cell;
        }
        else if (!self.provincePoiInfo && indexPath.row >1)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"addressInfoCell" forIndexPath:indexPath];
            if (!cell)
            {
                cell = [[AddressTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"addressInfoCell"];
            }
            POI *poiInfo = [self.addressDataSource objectAtIndex:(indexPath.row-2)];
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
        else if (indexPath.row == 0)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    if (self.historyAddressViewActive)
    {
        if (indexPath.row == 0)
        {
            [self hideHistoryAddressTableView];
        }
        else
        {
            self.currentAddressTableSelectedIndex = nil;
            POI *poiInfo = [self.historyAddressDataSource objectAtIndex:(indexPath.row -1)];
            self.poiInfo = poiInfo;
            [self hideHistoryAddressTableView];
            
            if ([self.delegate respondsToSelector:@selector(finishSelectAddress:)])
            {
                [self.delegate finishSelectAddress:self.poiInfo];
            }
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }
    else if (self.searchControllerWasActive)
    {
        if (self.searchAddressDataSource.count == 0)
        {
            return;
        }
        POI *poiInfo = [self.searchAddressDataSource objectAtIndex:(indexPath.row)];
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
        if (indexPath.row == 0)
        {
            if (!_historyAddressTableView)
            {
                [self initHistoryAddressTableView];
            }
            if (!_historyAddressDataSource)
            {
                NSInteger userId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
                [[POISearchAPI sharedInstance]getUserPOIHistory:userId whenComplete:^(NSDictionary *returnData) {
                    if ([returnData objectForKey:@"data"])
                    {
                        self.historyAddressDataSource = [returnData objectForKey:@"data"];
                        [self.historyAddressTableView reloadData];
                    }
                    else if ([returnData objectForKey:@"msg"])
                    {
                        [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"msg"]];
                    }
                }];
            }
            [self showHistoryAddressTableView];
        }
        else if (indexPath.row >2)
        {
            POI *poiInfo = [self.addressDataSource objectAtIndex:(indexPath.row -2)];
            // self.whatsGoingOnItem.imageDescription = @"";
            self.poiInfo = poiInfo;
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
        else if(indexPath.row == 1)
        {
            self.poiInfo = nil;
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

    }
    // self.currentAddressTableSelectedIndex = indexPath;
    
    
}

#pragma mark - action

-(void)switchLocation:(UIButton *)sender
{
    if (sender.selected)
    {
        sender.selected = NO;
        [self searchCurrentAddress];
        
    }
    else
    {
        if (self.location)
        {
            [self searchAddressWithLocation:self.location];
            sender.selected = YES;
        }
        else
        {
            [self searchCurrentAddress];
        }
    }
   
}
-(void)backBarButtonClick:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - aiv
-(void)startAiv
{
    if (!_tableViewAiv)
    {
        _tableViewAiv = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _tableViewAiv.center = self.view.center;
        [self.view addSubview:_tableViewAiv];
    }
    if (![_tableViewAiv  isAnimating])
    {
        [_tableViewAiv startAnimating];
    }
    if (!_locationButtonAiv)
    {
        _locationButtonAiv = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _locationButtonAiv.center = self.locationButton.center;
        [self.view addSubview:_locationButtonAiv];
    }
    [self.locationButton setHidden:YES];
    if (![_locationButtonAiv isAnimating])
    {
        [_locationButtonAiv startAnimating];
    }
}
-(void)stopAiv
{
    if ([_tableViewAiv isAnimating])
    {
        [_tableViewAiv stopAnimating];
    }
    if ([_locationButtonAiv isAnimating])
    {
        [_locationButtonAiv stopAnimating];
    }
    [self.locationButton setHidden:NO];
}


@end
