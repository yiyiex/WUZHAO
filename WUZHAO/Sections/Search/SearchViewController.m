//
//  SearchViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/8/9.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "SearchViewController.h"
#import "PhotosSuggestViewController.h"
#import "UserListTableViewController.h"
#import "AddressSuggestViewController.h"
#import "SearchResultViewController.h"
#import "SearchResultTableViewController2.h"

#import "HMSegmentedControl.h"

#import "UIViewController+Basic.h"

#import "QDYHTTPClient.h"
#import "SVProgressHUD.h"
#import "macro.h"

typedef NS_ENUM(NSInteger, ChildViewIndex)
{
    ChildViewIndexPhotos,
    //ChildViewIndexAddress,
    ChildViewIndexUsers
    
};

@interface SearchViewController ()<UISearchBarDelegate,UISearchControllerDelegate,UISearchResultsUpdating,PagerViewControllerDelegate,UserListViewControllerDataSource>
@property (nonatomic, strong) PhotosSuggestViewController *suggestPhotosViewController;
@property (nonatomic, strong) NSMutableArray *suggestPhotoData;

@property (nonatomic, strong) UserListTableViewController *suggestUserListViewConstroller;
@property (nonatomic, strong) NSMutableArray *suggestUserListData;

@property (nonatomic, strong) AddressSuggestViewController *suggestAddressViewController;
@property (nonatomic, strong) NSMutableArray *suggestAddressData;

@property (nonatomic, strong) SearchResultViewController *searchResultTableView;
@property (nonatomic, strong) NSMutableArray *searchResult;

@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIBarButtonItem *searchButton;

@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;




@end

@implementation SearchViewController
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setTitle:@"发 现"];
    }
    return self;
}
-(instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setTitle:@"发 现"];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setTitle:@"发 现"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSearchController];
    [self initSegmentController];
    
    [self setBackItem];
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // restore the searchController's active state
    if (self.searchControllerWasActive) {
        self.searchController.active = self.searchControllerWasActive;
        _searchControllerWasActive = NO;
        if (self.searchControllerSearchFieldWasFirstResponder) {
            [self.searchController.searchBar becomeFirstResponder];
            _searchControllerSearchFieldWasFirstResponder = NO;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)initSegmentController
{
    //self.segmentedControl.sectionTitles = @[@"照 片 ",@"用 户 "];
    
    self.segmentedControl.backgroundColor = [UIColor whiteColor];
    self.segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : THEME_COLOR_LIGHT_GREY,NSFontAttributeName:WZ_FONT_COMMON_SIZE};
    self.segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : THEME_COLOR_DARK,NSFontAttributeName:WZ_FONT_COMMON_BOLD_SIZE};
    [self.segmentedControl setSelectionIndicatorColor:THEME_COLOR_DARK_BIT_PARENT];
    self.segmentedControl.selectionIndicatorHeight = 2.50f;
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
}
-(void)initSearchController
{
    
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Search" bundle:nil];
    _searchResultTableView = [storyboard instantiateViewControllerWithIdentifier:@"SearchResult"];
    
    _searchController = [[UISearchController alloc]initWithSearchResultsController:_searchResultTableView];
    
    self.searchController.searchResultsUpdater = self;
    
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleDefault;
    
    [self.searchController.searchBar sizeToFit];
    //self.navigationItem.titleView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    self.searchController.delegate = self;
    
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    
    self.searchButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearchResultView)];
    
    //[self.navigationItem setTitle:@"发现"];
    //self.tabBarController.navigationItem.title = @"发现";
    self.navigationItem.rightBarButtonItem = self.searchButton;
    

    
}

-(void)showSearchResultView
{
    UIStoryboard *searchStoryboard = [UIStoryboard storyboardWithName:@"Search" bundle:nil];
    SearchResultViewController *searchResult = [searchStoryboard instantiateViewControllerWithIdentifier:@"SearchResult"];
    
    //SearchResultViewController *searchResult = [[SearchResultViewController alloc]init];
    [self pushToViewController:searchResult animated:YES hideBottomBar:YES];
}

#pragma mark -------UISearchResultsUpdating----------------
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    self.searchResultTableView.searchUserListData = [[User userList]mutableCopy];
    self.searchResultTableView.searchType = 0;
    [self.searchResultTableView.searchUserListTableView reloadData];
}



#pragma mark - pagerViewController delegate
-(NSArray *)childViewControllersForPagerViewController:(PagerViewController *)pagerViewController
{
    UIStoryboard *searchStoryboard = [UIStoryboard storyboardWithName:@"Search" bundle:nil];
    self.suggestPhotosViewController = [searchStoryboard instantiateViewControllerWithIdentifier:@"SuggestPhotos"];
    self.suggestAddressViewController = [searchStoryboard instantiateViewControllerWithIdentifier:@"SuggestAddress"];
    UIStoryboard *userStoryboard = [UIStoryboard storyboardWithName:@"UserList" bundle:nil];
    self.suggestUserListViewConstroller = [userStoryboard instantiateViewControllerWithIdentifier:@"userListTableView"];
    self.suggestUserListViewConstroller.userListStyle = UserListStyle3;
    WEAKSELF_WZ
    self.suggestUserListViewConstroller.getLatestDataBlock = ^()
    {
        __strong typeof (weakSelf_WZ) strongSelf = weakSelf_WZ;
        strongSelf.suggestUserListViewConstroller.shouldRefreshData = NO;
        [[QDYHTTPClient sharedInstance]exploreUserWhenComplete:^(NSDictionary *returnData) {
            strongSelf.suggestUserListViewConstroller.shouldRefreshData = YES;
            if ([returnData objectForKey:@"data"])
            {
                strongSelf.suggestUserListData = [[returnData objectForKey:@"data"]mutableCopy];
                [strongSelf.suggestUserListViewConstroller setDatasource:strongSelf.suggestUserListData];
                [strongSelf.suggestUserListViewConstroller loadData];
                
            }
            else if ([returnData objectForKey:@"error"])
            {
                [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
            }
        }];
        
    };
    
    return @[self.suggestPhotosViewController,self.suggestUserListViewConstroller];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - control the model
-(void)setSuggestPhotoCollectionData
{
    [self.suggestPhotosViewController getLatestData];
}
/*
-(void)setSuggestAddressListData
{
    // self.suggestAddressData = [[SuggestAddress newDatas]mutableCopy];
    [[QDYHTTPClient sharedInstance]explorePlaceWhenComplete:^(NSDictionary *returnData) {
        if ([returnData objectForKey:@"data"])
        {
            self.suggestAddressData = [[returnData objectForKey:@"data"]mutableCopy];
            [self.suggestAddressViewController setDatasource:self.suggestAddressData];
            [self.suggestAddressViewController loadData];
            
        }
        else if ([returnData objectForKey:@"error"])
        {
            [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
        }
    }];
}*/
-(void)setSuggestUserListData
{
    //self.suggestUserListData = [[User userList]mutableCopy];
    
    [self.suggestUserListViewConstroller getLatestDataAnimated];
    
}

-(void)getLatestData
{
    if (self.currentIndex == ChildViewIndexPhotos)
    {
        [self setSuggestPhotoCollectionData];
    }
    /*
    else if (self.currentIndex == ChildViewIndexAddress)
    {
        [self setSuggestAddressListData];
        
    }*/
    else if (self.currentIndex == ChildViewIndexUsers)
    {
        [self setSuggestUserListData];
    }
}
-(void)loadChildViewData
{
    if (self.currentIndex == ChildViewIndexPhotos)
    {
  
    }
    /*
    else if (self.currentIndex == ChildViewIndexAddress)
    {
        if (self.suggestAddressData.count <=0 || !self.suggestAddressData)
        {
            [self setSuggestAddressListData];
        }
    }*/
    else if (self.currentIndex == ChildViewIndexUsers)
    {
        if (self.suggestUserListData.count <=0 || !self.suggestUserListData)
        {
            [self setSuggestUserListData];
        }
    }
}
#pragma mark - userlist delegate
-(void )updateUserListDatasource:(UserListTableViewController *)userList
{
    [self setSuggestUserListData];
}

#pragma mark - search with type

-(void)searchWithType:(NSString *)searchType keyWord:(NSString *)keyword
{
    [[QDYHTTPClient sharedInstance]searchWithType:searchType keyword:keyword whenComplete:^(NSDictionary *returnData) {
        if (returnData)
        {
            [self.searchResultTableView updateSearchResultWithData:returnData];
        }
    }];
    
}

@end
