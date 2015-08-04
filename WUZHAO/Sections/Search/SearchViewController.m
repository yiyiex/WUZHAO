    //
//  SearchViewController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-15.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "SearchViewController.h"
#import "CommonContainerViewController.h"
#import "PhotosCollectionViewController.h"
#import "UserListTableViewController.h"
#import "AddressSuggestViewController.h"
#import "SearchResultViewController.h"
#import "SearchResultTableViewController2.h"

#import "UIViewController+Basic.h"

#import "QDYHTTPClient.h"

#import "SVProgressHUD.h"

#import "User.h"
#import "WhatsGoingOn.h"
#import "SuggestAddress.h"
#import "macro.h"

#define SEGUEFIRST @"segueForSuggestPhotos"
#define SEGUESECOND @"segueForSuggestAddress"
#define SEGUETHIRD @"segueForSuggestUsers"

@interface SearchViewController () <UISearchBarDelegate,UISearchControllerDelegate,UISearchResultsUpdating,CommonContainerViewControllerDelegate,UserListViewControllerDataSource,AddressSuggestViewControllerDataSource,PhotoCollectionViewControllerDataSource>
@property (nonatomic, strong) CommonContainerViewController *containerViewController;
@property (nonatomic, strong) PhotosCollectionViewController *suggestPhotoCollectionViewController;
@property (nonatomic, strong) AddressSuggestViewController *suggestAddressViewController;
@property (nonatomic, strong) UserListTableViewController *suggestUserListViewConstroller;

@property (nonatomic, strong) NSMutableArray *suggestPhotoData;
@property (nonatomic, strong) NSMutableArray *suggestAddressData;
@property (nonatomic, strong) NSMutableArray *suggestUserListData;

@property (nonatomic, strong) SearchResultViewController *searchResultTableView;
@property (nonatomic, strong) NSMutableArray *searchResult;

@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIBarButtonItem *searchButton;


//for state restoration
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarItem;
    
    [self initSearchControllerAndSegmentController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"发 现";
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.rightBarButtonItem = self.searchButton;
    self.navigationItem.hidesBackButton = YES;
}
- (void)viewDidAppear:(BOOL)animated {
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


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

-(void)initSearchControllerAndSegmentController
{
    
    _segmentControl.sectionTitles = @[@"照 片 ",@"地 点 ",@"用 户 "];
 
    _segmentControl.backgroundColor = [UIColor whiteColor];
    _segmentControl.titleTextAttributes = @{NSForegroundColorAttributeName : THEME_COLOR_LIGHT_GREY,NSFontAttributeName:WZ_FONT_COMMON_SIZE};
    _segmentControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : THEME_COLOR_DARK,NSFontAttributeName:WZ_FONT_COMMON_BOLD_SIZE};
    [_segmentControl setSelectionIndicatorColor:THEME_COLOR_DARK_BIT_PARENT];
    _segmentControl.selectionIndicatorHeight = 2.50f;
    
    _segmentControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    _segmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    [_segmentControl addTarget:self action:@selector(segmentValueChanged) forControlEvents:UIControlEventValueChanged];

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
    self.tabBarController.navigationItem.rightBarButtonItem = self.searchButton;
    
    _segmentControl.selectedSegmentIndex = 0;
    
}
-(void)showSearchResultView
{
    SearchResultTableViewController2 *searchResult = [[SearchResultTableViewController2 alloc]init];
    [self pushToViewController:searchResult animated:YES hideBottomBar:YES];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedContainer"])
    {
        self.containerViewController = segue.destinationViewController;
        self.containerViewController.delegate = self;
        self.containerViewController.ChildrenName = @[SEGUEFIRST,SEGUESECOND,SEGUETHIRD];
        self.containerViewController.isInteractive = YES;
    }
}


-(CommonContainerViewController *)containerViewController
{
    if (!_containerViewController)
    {
        _containerViewController = [[CommonContainerViewController alloc]initWithChildren:@[SEGUEFIRST,SEGUESECOND,SEGUETHIRD]];
        
    }
    return _containerViewController;
}



#pragma mark- searchbar delegate

#pragma mark -------UISearchResultsUpdating----------------
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    self.searchResultTableView.searchUserListData = [[User userList]mutableCopy];
    self.searchResultTableView.searchType = 0;
    [self.searchResultTableView.searchUserListTableView reloadData];
}

#pragma mark - commonContainerViewController delegate

-(void)beginLoadChildController:(UIViewController *)childController
{
    if ([childController isKindOfClass: [PhotosCollectionViewController class]])
    {
        self.suggestPhotoCollectionViewController = (PhotosCollectionViewController *)childController;
       // [self.containerViewController.interactiveTransitionGestureRecognizer requireGestureRecognizerToFail:self.suggestPhotoCollectionViewController.collectionView.panGestureRecognizer];
        //[self.suggestPhotoCollectionViewController.collectionView.panGestureRecognizer requireGestureRecognizerToFail:self.containerViewController.interactiveTransitionGestureRecognizer];
        self.suggestPhotoCollectionViewController.dataSource = self;
        [self.suggestPhotoCollectionViewController.collectionView setBackgroundColor:[UIColor whiteColor]];
        if (!self.suggestPhotoData)
        {
            [self setSuggestPhotoCollectionData];
        }
        else
        {
            [self.suggestPhotoCollectionViewController setDatasource:self.suggestPhotoData];
            [self.suggestPhotoCollectionViewController loadData];
        }
        
    }
    else if ([childController isKindOfClass:[AddressSuggestViewController class]])
    {
        self.suggestAddressViewController = (AddressSuggestViewController *)childController;
        //[self.containerViewController.interactiveTransitionGestureRecognizer requireGestureRecognizerToFail:self.suggestAddressViewController.tableView.panGestureRecognizer];
        //[self.suggestAddressViewController.tableView.panGestureRecognizer requireGestureRecognizerToFail:self.containerViewController.interactiveTransitionGestureRecognizer];
        self.suggestAddressViewController.dataSource = self;
        if (!self.suggestAddressData)
        {
            [self setSuggestAddressListData];
        }
        else
        {
            
            self.suggestAddressViewController.datasource = self.suggestAddressData;
            [self.suggestAddressViewController loadData];
        }
        
    }
    else if( [childController isKindOfClass:[UserListTableViewController class]])
    {
        self.suggestUserListViewConstroller = (UserListTableViewController *)childController;
        // [self.suggestUserListViewConstroller.tableView.panGestureRecognizer requireGestureRecognizerToFail:self.containerViewController.interactiveTransitionGestureRecognizer];
        //[self.containerViewController.interactiveTransitionGestureRecognizer requireGestureRecognizerToFail:self.suggestUserListViewConstroller.tableView.panGestureRecognizer];
        self.suggestUserListViewConstroller.dataSource = self;
        [self.suggestUserListViewConstroller setUserListStyle:UserListStyle3];
        if (!self.suggestUserListData)
        {
            [self setSuggestUserListData];
        }
        else
        {
            [self.suggestUserListViewConstroller setDatasource:self.suggestUserListData];
            [self.suggestUserListViewConstroller loadData];
        }
    }
}

-(void)finishLoadChildController:(UIViewController *)childController
{
    [self.segmentControl setUserInteractionEnabled:YES];
    if ([childController isKindOfClass: [PhotosCollectionViewController class]])
    {
        [self.segmentControl setSelectedSegmentIndex:0 animated:YES];
    }
    else if ([childController isKindOfClass:[AddressSuggestViewController class]])
    {
        [self.segmentControl setSelectedSegmentIndex:1 animated:YES];
    }
    else if( [childController isKindOfClass:[UserListTableViewController class]])
    {
        [self.segmentControl setSelectedSegmentIndex:2 animated:YES];
    }
   
}

-(void)setSuggestPhotoCollectionData
{
    NSInteger userId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[QDYHTTPClient sharedInstance]explorephotoWithUserId:userId whenComplete:^(NSDictionary *returnData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([returnData objectForKey:@"data"])
                {
                    self.suggestPhotoData = [[returnData objectForKey:@"data"]mutableCopy];
                    [self.suggestPhotoCollectionViewController setDatasource:self.suggestPhotoData];
                    [self.suggestPhotoCollectionViewController loadData];
                    
                }
                else if ([returnData objectForKey:@"error"])
                {
                    [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
                }
            });

        }];
    });


}
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
}
-(void)setSuggestUserListData
{
    //self.suggestUserListData = [[User userList]mutableCopy];
    [[QDYHTTPClient sharedInstance]exploreUserWhenComplete:^(NSDictionary *returnData) {
        if ([returnData objectForKey:@"data"])
        {
            self.suggestUserListData = [[returnData objectForKey:@"data"]mutableCopy];
            [self.suggestUserListViewConstroller setDatasource:self.suggestUserListData];
            [self.suggestUserListViewConstroller loadData];
            
        }
        else if ([returnData objectForKey:@"error"])
        {
            [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
        }
    }];

}
-(void)getLatestData
{
    if ([self.containerViewController.currentViewController isKindOfClass:[PhotosCollectionViewController class]])
    {
        [self setSuggestPhotoCollectionData];
    }
    else if ([self.containerViewController.currentViewController isKindOfClass:[AddressSuggestViewController class]])
    {
        [self setSuggestAddressListData];
    }
    else if ([self.containerViewController.currentViewController isKindOfClass:[UserListTableViewController class]])
    {
        [self setSuggestUserListData];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - userlist delegate
-(void )updateUserListDatasource:(UserListTableViewController *)userList
{
    [self setSuggestUserListData];
}
#pragma mark - address suggest delegate
-(void)updateAddressDatasource:(AddressSuggestViewController *)addressList
{
    [self setSuggestAddressListData];
}
#pragma mark - photoCollection delegate
-(void)updatePhotoCollectionDatasource:(PhotosCollectionViewController *)collectionView
{
    [self setSuggestPhotoCollectionData];
}


#pragma mark -HMSegment action
- (void)segmentValueChanged
{
    [self.segmentControl setUserInteractionEnabled:NO];
    NSString *swapIdentifier ;
    switch (self.segmentControl.selectedSegmentIndex) {
        case 0:
            swapIdentifier = SEGUEFIRST;
            break;
        case 1:
            swapIdentifier = SEGUESECOND;
            break;
        case 2:
            swapIdentifier = SEGUETHIRD;
            break;
        default:
            swapIdentifier = SEGUEFIRST;
            break;
    }
    [self.containerViewController swapViewControllersWithIdentifier:swapIdentifier];
}

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
