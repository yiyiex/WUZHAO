//
//  SearchResultViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/4/7.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "SearchResultViewController.h"
#import "UserListTableViewCell.h"
#import "AddressTableViewCell.h"

#import "AddressViewController.h"

#import "PureLayout.h"
#import "UIViewController+Basic.h"
#import "UIImageView+WebCache.h"
#import "TableViewScrollNotSwipe.h"
#import "QDYHTTPClient.h"
#import "SVProgressHUD.h"
#import "macro.h"

@interface SearchResultViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UIScrollViewAccessibilityDelegate,UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIActivityIndicatorView *searchUserAiv;
@property (nonatomic, strong) UIActivityIndicatorView *searchAddressAiv;
@end

@implementation SearchResultViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    [self initNavigationItem];
    [self initView];
  
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNavigationItem
{
    self.navigationItem.titleView = self.searchBar;
    [self setBackItem];
    //self.navigationItem.hidesBackButton = YES;
    //self.tabBarController.navigationItem.hidesBackButton = YES;
}
-(UISearchBar *)searchBar
{
    if (!_searchBar)
    {
        _searchBar = [[UISearchBar alloc]init];
        [_searchBar setBarStyle:UIBarStyleDefault];
        [_searchBar setPlaceholder:@"搜索用户"];
       // [_searchBar setShowsCancelButton:YES];
        _searchBar.delegate = self;
    }
    return _searchBar;
}
-(NSMutableArray *)searchAddressListData
{
    if (!_searchAddressListData)
    {
        _searchAddressListData = [[NSMutableArray alloc]init];
    }
    return _searchAddressListData;
}
-(NSMutableArray *)searchUserListData
{
    if (!_searchUserListData)
    {
        _searchUserListData = [[NSMutableArray alloc]init];
    }
    return _searchUserListData;
}

-(UIActivityIndicatorView *)searchAddressAiv
{
    if (!_searchAddressAiv)
    {
        _searchAddressAiv = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _searchAddressAiv;
}
-(UIActivityIndicatorView *)searchUserAiv
{
    if (!_searchUserAiv)
    {
        _searchUserAiv = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _searchUserAiv;
}

-(void)initView
{
    self.searchStatus = SEARCHSTATUSNOTBEGIN;
    _segmentControl.sectionTitles = @[@"地点",@"用户"];
    _segmentControl.selectedSegmentIndex = 1;
    _segmentControl.backgroundColor = [UIColor whiteColor];
    _segmentControl.titleTextAttributes = @{NSForegroundColorAttributeName : THEME_COLOR_LIGHT_GREY,NSFontAttributeName:WZ_FONT_COMMON_SIZE};
    _segmentControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : THEME_COLOR_DARK_GREY,NSFontAttributeName:WZ_FONT_COMMON_BOLD_SIZE};
    [_segmentControl setSelectionIndicatorColor:THEME_COLOR_DARK_BIT_PARENT];
    _segmentControl.selectionIndicatorHeight = 2.0f;
    
    _segmentControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    _segmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    [_segmentControl addTarget:self action:@selector(segmentValueChanged) forControlEvents:UIControlEventValueChanged];
    
    CGRect scrollFrame = CGRectMake(0, 44+64, WZ_APP_SIZE.width, self.view.frame.size.height - 44-64);
    self.scrollView = [[ScrollViewOnlyHorizonScroll alloc]initWithFrame:scrollFrame];
    [self.view addSubview:self.scrollView];
    
    float tableHeight = self.scrollView.frame.size.height;
    float tableWidth = WZ_APP_SIZE.width;

    //user search list
    self.searchUserListTableView = [[UITableView alloc]initWithFrame:CGRectMake(tableWidth, 0, tableWidth, tableHeight)];
    self.searchUserListTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleWidth;
    [self.searchUserListTableView registerNib:[UINib nibWithNibName:@"UserListTableViewCell" bundle:nil] forCellReuseIdentifier:@"UserListTableViewCellWithFollowButton"];
    [self.searchUserListTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"defaultCell"];
    self.searchUserListTableView.estimatedRowHeight = 64;
    self.searchUserListTableView.rowHeight = 64;;
    
    //address search list
    self.searchAddressListTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, tableWidth, tableHeight)];
    self.searchAddressListTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleWidth;
    [self.searchAddressListTableView registerNib:[UINib nibWithNibName:@"AddressTableViewCell" bundle:nil] forCellReuseIdentifier:@"addressInfoCell"];
    [self.searchAddressListTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"defaultCell"];
    self.searchAddressListTableView.estimatedRowHeight = 40;
    self.searchAddressListTableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.scrollView addSubview:self.searchUserListTableView];
    [self.scrollView addSubview:self.searchAddressListTableView];
    self.scrollView.contentSize = CGSizeMake(tableWidth*2, tableHeight);
    [self.scrollView setContentOffset:CGPointMake(WZ_APP_SIZE.width, 0)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.directionalLockEnabled =YES;
    self.scrollView.delegate = self;
    
    [self.searchUserListTableView setDelegate:self];
    [self.searchUserListTableView setDataSource:self];
    [self.searchAddressListTableView setDelegate:self];
    [self.searchAddressListTableView setDataSource:self];
    
    self.searchType = SEARCHTABLEDATAUSER;
    [self.searchUserListTableView reloadData];
    [self.searchAddressListTableView reloadData];
 
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self.searchBar resignFirstResponder];
}
#pragma mark - loaddata
-(void)reloadAllDatas
{
    [self.searchUserListTableView reloadData];
    [self.searchUserListTableView setContentOffset:CGPointMake(0, 0)];
    [self.searchAddressListTableView reloadData];
    [self.searchAddressListTableView setContentOffset:CGPointMake(0, 0)];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
#pragma mark - searchbar Delegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    if ([searchBar.text isEqualToString:@""])
    {
        self.searchStatus = SEARCHSTATUSNOTBEGIN;
        [self.searchUserListData removeAllObjects];
        [self.searchAddressListData removeAllObjects];
        [self reloadAllDatas];
        
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchStatus = SEARCHSTATUSNOTBEGIN;
    [self.searchUserListData removeAllObjects];
    [self.searchAddressListData removeAllObjects];
    [self reloadAllDatas];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([searchBar.text isEqualToString: @""])
        return;
    self.searchStatus = SEARCHSTATUSING;
    [self.searchUserListData removeAllObjects];
    [self.searchAddressListData removeAllObjects];
    [self reloadAllDatas];
    NSString *searchString = searchBar.text;
    if (self.searchType == SEARCHTABLEDATAUSER)
    {
        [[QDYHTTPClient sharedInstance]searchWithType:@"user" keyword:searchString whenComplete:^(NSDictionary *returnData) {
            if ([returnData objectForKey:@"data"])
            {
                self.searchUserListData = [[returnData objectForKey:@"data"]mutableCopy];
                self.searchStatus = SEARCHSTATUSEND;
                [self.searchUserListTableView reloadData];
            }
            else if ([returnData objectForKey:@"error"])
            {
                self.searchStatus = SEARCHSTATUSERROR;
                [self.searchUserListTableView reloadData];
            }
        }];
    }
    else if (self.searchType == SEARCHTABLEDATAADDRESS)
    {
        [[QDYHTTPClient sharedInstance]searchWithType:@"poi" keyword:searchString whenComplete:^(NSDictionary *returnData) {
            if ([returnData objectForKey:@"data"])
            {
                self.searchAddressListData = [[returnData objectForKey:@"data"]mutableCopy];
                self.searchStatus = SEARCHSTATUSEND;
                [self.searchAddressListTableView reloadData];
            }
            else if ([returnData objectForKey:@"error"])
            {
                self.searchStatus = SEARCHSTATUSERROR;
                [self.searchAddressListTableView reloadData];
            }
        }];
    }

    
    
}


#pragma mark - scrollview delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[UITableView class]])
    {
        [self.searchBar resignFirstResponder];
        return;
    }
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"content offset %f",self.scrollView.contentOffset.x);
    if ([scrollView isKindOfClass:[UITableView class]])
    {
        [self.searchBar resignFirstResponder];
        return;
    }
    if (scrollView.contentOffset.x <=self.scrollView.contentSize.width/4)
    {
        [self.segmentControl setSelectedSegmentIndex:0 animated:YES];
        [self segmentValueChanged];
    }
    else if (scrollView.contentOffset.x > self.scrollView.contentSize.width/4)
    {
        [self.segmentControl setSelectedSegmentIndex:1 animated:YES];
        [self segmentValueChanged];
    }
}

#pragma mark - tableview delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell;
    if (self.searchType == SEARCHTABLEDATAUSER)
    {
        if (self.searchUserListData.count == 0 && indexPath.row ==0)
        {
            UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"defaultCell" forIndexPath:indexPath] ;
            [self.searchUserAiv stopAnimating];
            [self.searchUserAiv removeFromSuperview];
            if (self.searchStatus == SEARCHSTATUSNOTBEGIN)
            {
                cell.textLabel.text = @"搜索用户...";
            }
            else if (self.searchStatus == SEARCHSTATUSING)
            {
                [cell addSubview:self.searchUserAiv];
                CGPoint aivCenter = CGPointMake(140, cell.contentView.center.y);
                [self.searchUserAiv setCenter:aivCenter];
                [self.searchUserAiv startAnimating];
                cell.textLabel.text = @"正在搜索...";
             
            }
            else if (self.searchStatus == SEARCHSTATUSEND)
            {
                cell.textLabel.text = @"无用户搜索结果";
            }
            else if (self.searchStatus == SEARCHSTATUSERROR)
            {
                cell.textLabel.text = @"搜索失败";
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else
        {
            UserListTableViewCell *cell =(UserListTableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"UserListTableViewCellWithFollowButton"];
            User *userData = [self.searchUserListData objectAtIndex:indexPath.row];
            [cell configWithUser:userData style:UserListStyle2];
            UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarTapped:)];
            [cell.avatorImageView setUserInteractionEnabled:YES];
            [cell.avatorImageView addGestureRecognizer:avatarTap];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    if (self.searchType == SEARCHTABLEDATAADDRESS)
    {
        if (self.searchAddressListData.count == 0 && indexPath.row ==0)
        {
            UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"defaultCell" forIndexPath:indexPath] ;
            [self.searchAddressAiv stopAnimating];
            [self.searchAddressAiv removeFromSuperview];
            if (self.searchStatus == SEARCHSTATUSNOTBEGIN)
            {
                cell.textLabel.text = @"搜索地址...";
            }
            else if (self.searchStatus == SEARCHSTATUSING)
            {
                
                [cell addSubview:self.searchAddressAiv];
                CGPoint aivCenter = CGPointMake(140, cell.contentView.center.y);
                [self.searchAddressAiv setCenter:aivCenter];
                [self.searchAddressAiv startAnimating];
                cell.textLabel.text = @"正在搜索...";
             
            }
            else if (self.searchStatus == SEARCHSTATUSEND)
            {
                cell.textLabel.text = @"该地址下无照片,去发布第一张吧！";
            }
            else if (self.searchStatus == SEARCHSTATUSERROR)
            {
                cell.textLabel.text = @"搜索失败";
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else
        {
            AddressTableViewCell *cell =(AddressTableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"addressInfoCell"];
            POI *poiData = [self.searchAddressListData objectAtIndex:indexPath.row];
            cell.addressLabel.text = [NSString stringWithFormat:@"%@",poiData.name];
            cell.detailAddressLabel.text =[NSString stringWithFormat:@"%@%@",poiData.city,poiData.address];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchType == SEARCHTABLEDATAADDRESS)
    {
        if (self.searchAddressListData.count >0)
        {
            POI *poi = self.searchAddressListData[indexPath.row];
            [self goToPOIPhotoListWithPoi:poi];
        }
        
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchType == SEARCHTABLEDATAUSER)
    {
        if (self.searchUserListData.count > 0)
        {
            return self.searchUserListData.count;
        }
        else
        {
            return 1;
        }
    }
    else if (self.searchType == SEARCHTABLEDATAADDRESS)
    {
        if (self.searchAddressListData.count > 0)
        {
            return self.searchAddressListData.count;
        }
        else
        {
            return 1;
        }
    }
    return 0;
}




- (void)segmentValueChanged
{
    self.searchType = self.segmentControl.selectedSegmentIndex;
    [self searchBarSearchButtonClicked:self.searchBar];
    if (self.searchType == SEARCHTABLEDATAADDRESS)
    {
        [self.searchAddressListTableView reloadData];
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    
    else if (self.searchType == SEARCHTABLEDATAUSER)
    {
        [self.searchUserListTableView reloadData];
        [self.scrollView setContentOffset:CGPointMake(WZ_APP_SIZE.width, 0) animated:YES];
    }
}
-(void)updateSearchResultWithData:(NSDictionary *)returnData
{

    if ([returnData objectForKey:@"error"])
    {
        self.searchStatus = SEARCHSTATUSERROR;
    }
    else
    {
        self.searchStatus = SEARCHSTATUSEND;
        NSArray *data = [returnData objectForKey:@"data"];
        if (self.searchType == SEARCHTABLEDATAUSER)
        {
            self.searchUserListData = [data mutableCopy];
            [self.searchUserListTableView reloadData];
        }
        if (self.searchType == SEARCHTABLEDATAADDRESS)
        {
            self.searchAddressListData = [data mutableCopy];
            [self.searchAddressListTableView reloadData];
        }
    }

}



#pragma mark - gesture and action
-(void)avatarTapped:(UIGestureRecognizer *)gesture
{
    UIImageView *avatar = (UIImageView *)gesture.view;
    UserListTableViewCell *cell = (UserListTableViewCell *)avatar.superview.superview;
    NSIndexPath *indexpath = [self.searchUserListTableView indexPathForCell:cell];
    User *user = self.searchUserListData[indexpath.row];
    [self goToPersonalPageWithUserInfo:user];
  
}

#pragma mark - transition

-(void)goToPersonalPageWithUserInfo:(User *)user
{
    UIStoryboard *personalStoryboard= [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
    MineViewController *personalViewCon = [personalStoryboard instantiateViewControllerWithIdentifier:@"personalPage"];
    [personalViewCon setUserInfo:user];
    [self pushToViewController:personalViewCon animated:YES hideBottomBar:YES];
}
-(void)goToPOIPhotoListWithPoi:(POI *)poi
{
    UIStoryboard *addressStoryboard = [UIStoryboard storyboardWithName:@"Address" bundle:nil];
    AddressViewController *addressViewCon = [addressStoryboard instantiateViewControllerWithIdentifier:@"addressPage"];
    addressViewCon.poiId = poi.poiId;
    addressViewCon.poiName = poi.name;
    addressViewCon.poiLocation = poi.locationArray;
    addressViewCon.recommendFirstPostId = 0;
    [self pushToViewController:addressViewCon animated:YES hideBottomBar:YES];
}

@end
