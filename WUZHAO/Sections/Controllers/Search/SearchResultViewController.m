//
//  SearchResultViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/4/7.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "SearchResultViewController.h"
#import "UserListTableViewCell.h"
#import "PureLayout.h"
#import "UIImageView+WebCache.h"
#import "macro.h"

@interface SearchResultViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UIScrollViewAccessibilityDelegate,UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@end

@implementation SearchResultViewController
/*
@synthesize searchAddressListTableView;
@synthesize searchAddressListData;
@synthesize searchUserListTableView;
@synthesize searchUserListData;
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
-(void)initView
{
    self.searchStatus = SEARCHSTATUSNOTBEGIN;
   /*
    _segmentControl.sectionTitles = @[@"地点",@"用户"];
    _segmentControl.selectedSegmentIndex = 1;
    _segmentControl.backgroundColor = [UIColor whiteColor];
    _segmentControl.titleTextAttributes = @{NSForegroundColorAttributeName : THEME_COLOR_LIGHT_GREY,NSFontAttributeName:WZ_FONT_COMMON_SIZE};
    _segmentControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : THEME_COLOR_DARK_GREY,NSFontAttributeName:WZ_FONT_COMMON_BOLD_SIZE};
    [_segmentControl setSelectionIndicatorColor:THEME_COLOR_DARK_GREY];
    _segmentControl.selectionIndicatorHeight = 2.0f;
    
    _segmentControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    _segmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationUp;
    [_segmentControl addTarget:self action:@selector(segmentValueChanged) forControlEvents:UIControlEventValueChanged];
    

    float tableHeight = self.scrollView.bounds.size.height+10;
    float tableWidth = WZ_DEVICE_BOUNDS.size.width;

    searchUserListTableView = [[UITableView alloc]initWithFrame:CGRectMake(tableWidth, 0, tableWidth, tableHeight)];
    [searchUserListTableView registerNib:[UINib nibWithNibName:@"UserListTableViewCell" bundle:nil] forCellReuseIdentifier:@"UserListTableViewCellWithFollowButton"];
    searchUserListTableView.estimatedRowHeight = 80;
    searchUserListTableView.rowHeight = UITableViewAutomaticDimension;
    searchAddressListTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, tableWidth, tableHeight)];
     [searchAddressListTableView registerNib:[UINib nibWithNibName:@"UserListTableViewCell" bundle:nil] forCellReuseIdentifier:@"UserListTableViewCellWithFollowButton"];
    searchAddressListTableView.estimatedRowHeight = 80;
    searchAddressListTableView.rowHeight = UITableViewAutomaticDimension;
    [self.scrollView addSubview:self.searchUserListTableView];
    [self.scrollView addSubview:self.searchAddressListTableView];
    
    self.scrollView.contentSize = CGSizeMake(tableWidth*2, tableHeight);
    [self.scrollView setContentOffset:CGPointMake(WZ_APP_SIZE.width, 0)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.directionalLockEnabled =YES;
    self.scrollView.delegate = self;
    
    self.searchAddressListTableView.scrollEnabled = NO;
    self.searchUserListTableView.scrollEnabled = NO;
    
    NSLog(@"scrollview size---%f,%f,%f,%f",_scrollView.frame.origin.x,_scrollView.frame.origin.y,_scrollView.frame.size.width,_scrollView.frame.size.height);
    NSLog(@"scrollview size---%f,%f,%f,%f",searchAddressListTableView.frame.origin.x,searchAddressListTableView.frame.origin.y,searchAddressListTableView.frame.size.width,searchAddressListTableView.frame.size.height);
     NSLog(@"userlistTableView size---%f,%f,%f,%f",searchUserListTableView.frame.origin.x,searchUserListTableView.frame.origin.y,searchUserListTableView.frame.size.width,searchUserListTableView.frame.size.height);

    
    [self.searchUserListTableView setDelegate:self];
    [self.searchUserListTableView setDataSource:self];
    [self.searchAddressListTableView setDelegate:self];
    [self.searchAddressListTableView setDelegate:self];

    self.searchUserListData = [[User userList]mutableCopy];
    self.searchType = SEARCHTABLEDATAUSER;
    [self.searchUserListTableView reloadData];
 
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - searchbar Delegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    
}

#pragma mark - scrollview delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"content offset %f",self.scrollView.contentOffset.x);
    if (scrollView.contentOffset.x <self.scrollView.contentSize.width/4)
    {
        [self.segmentControl setSelectedSegmentIndex:0 animated:YES];
    }
    else if (scrollView.contentOffset.x > self.scrollView.contentSize.width/3)
    {
         [self.segmentControl setSelectedSegmentIndex:1 animated:YES];
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
            if (self.searchStatus == SEARCHSTATUSNOTBEGIN)
            {
                UITableViewCell *cell = [[UITableViewCell alloc]init];
                cell.textLabel.text = @"搜索用户...";
                return cell;
            }
            else if (self.searchStatus == SEARCHSTATUSEND)
            {
                UITableViewCell *cell = [[UITableViewCell alloc]init];
                cell.textLabel.text = @"无用户搜索结果";
                return cell;
            }
            else if (self.searchStatus == SEARCHSTATUSERROR)
            {
                UITableViewCell *cell = [[UITableViewCell alloc]init];
                cell.textLabel.text = @"搜索失败";
                return cell;
            }
        }
        else
        {
            UserListTableViewCell *cell =(UserListTableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"UserListTableViewCellWithFollowButton"];
            User *userData = [self.searchUserListData objectAtIndex:indexPath.row];
            [cell configWithUser:userData style:UserListStyle2];
            return cell;
        }
    }
    if (self.searchType == SEARCHTABLEDATAUSER)
    {
        if (self.searchAddressListData.count == 0 && indexPath.row ==0)
        {
            if (self.searchStatus == SEARCHSTATUSNOTBEGIN)
            {
                UITableViewCell *cell = [[UITableViewCell alloc]init];
                cell.textLabel.text = @"搜索地址...";
                return cell;
            }
            else if (self.searchStatus == SEARCHSTATUSEND)
            {
                UITableViewCell *cell = [[UITableViewCell alloc]init];
                cell.textLabel.text = @"无地址搜索结果";
                return cell;
            }
            else if (self.searchStatus == SEARCHSTATUSERROR)
            {
                UITableViewCell *cell = [[UITableViewCell alloc]init];
                cell.textLabel.text = @"搜索失败";
                return cell;
            }
        }
        else
        {
            UserListTableViewCell *cell =(UserListTableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"UserListTableViewCellWithFollowButton"];
            User *userData = [self.searchAddressListData objectAtIndex:indexPath.row];
            [cell configWithUser:userData style:UserListStyle2];
            return cell;
        }
    }
    
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchType == SEARCHTABLEDATAUSER)
    {
        return self.searchUserListData.count;
    }
    else if (self.searchType == SEARCHTABLEDATAADDRESS)
    {
        return self.searchAddressListData.count;
    }
    return 0;
}


- (void)segmentValueChanged
{
    self.searchType = self.segmentControl.selectedSegmentIndex;
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

}*/

@end
