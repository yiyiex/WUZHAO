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
#import "SearchResultViewController.h"
#import "SearchResultTableViewController2.h"
#import "QDYHTTPClient.h"

#import "SVProgressHUD.h"

#import "User.h"
#import "WhatsGoingOn.h"
#import "macro.h"

#define SEGUEFIRST @"segueForSuggestPhotos"
#define SEGUESECOND @"segueForSuggestAddress"
#define SEGUETHIRD @"segueForSuggestUsers"

@interface SearchViewController () <UISearchBarDelegate,UISearchControllerDelegate,UISearchResultsUpdating,CommonContainerViewControllerDelegate>
@property (nonatomic, strong) CommonContainerViewController *containerViewController;
@property (nonatomic, strong) PhotosCollectionViewController *suggestPhotoCollectionViewController;
@property (nonatomic, strong) UserListTableViewController *suggestUserListViewConstroller;
@property (nonatomic,strong) NSMutableArray *suggestPhotoData;
@property (nonatomic,strong) NSMutableArray *suggestUserListData;

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
    
   // [self initSwipGesture];
    [self initSearchControllerAndSegmentController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.navigationItem.title = @"发现";
    self.tabBarController.navigationController.navigationBarHidden = NO;
    self.tabBarController.navigationItem.rightBarButtonItem = self.searchButton;
    self.tabBarController.navigationItem.hidesBackButton = YES;

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
    /*
    _segmentControl.sectionTitles = @[@"照片",@"地点",@"用户"];
    _segmentControl.selectedSegmentIndex = 0;
    _segmentControl.backgroundColor = [UIColor whiteColor];
    _segmentControl.titleTextAttributes = @{NSForegroundColorAttributeName : THEME_COLOR_LIGHT_GREY,NSFontAttributeName:WZ_FONT_COMMON_SIZE};
    _segmentControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : THEME_COLOR_DARK_GREY,NSFontAttributeName:WZ_FONT_COMMON_BOLD_SIZE};
    [_segmentControl setSelectionIndicatorColor:THEME_COLOR_DARK_GREY];
    _segmentControl.selectionIndicatorHeight = 2.0f;
    
    _segmentControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    _segmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationUp;
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
     */
    self.searchButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearchResultView)];
    
    //[self.navigationItem setTitle:@"发现"];
    self.tabBarController.navigationItem.title = @"发现";
    self.tabBarController.navigationItem.rightBarButtonItem = self.searchButton;
    
}
-(void)showSearchResultView
{
    /*
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Search" bundle:nil];
    
    SearchResultViewController *searchResult = [storyboard instantiateViewControllerWithIdentifier:@"SearchResult"]; 
     */
    SearchResultTableViewController2 *searchResult = [[SearchResultTableViewController2 alloc]init];
    [self.navigationController pushViewController:searchResult animated:YES];
}
-(void)initSwipGesture
{
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipToRight:)];
    [recognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:recognizer];
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipToLeft:)];
    [recognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:recognizer];
}
-(void)swipToRight:(UISwipeGestureRecognizer *)gesture
{
    if (self.containerViewController.currentSegueIdentifier == [self.containerViewController.ChildrenName firstObject])
    {
        return;
    }
    else
    {
        // NSLog(@"swip to right");
        for (int i = 1;i <self.containerViewController.ChildrenName.count;i++)
        {
            if ([self.containerViewController.ChildrenName[i] isEqualToString:self.containerViewController.currentSegueIdentifier])
            {
                self.containerViewController.currentSegueIdentifier = self.containerViewController.ChildrenName[i-1];
                [self.containerViewController performSegueWithIdentifier:self.containerViewController.currentSegueIdentifier sender:nil];
                                [self.segmentControl setSelectedSegmentIndex:self.segmentControl.selectedSegmentIndex-1 animated:YES];
                break;
            }
        }
    }
}
-(void)swipToLeft:(UISwipeGestureRecognizer *)gesture
{
    if (self.containerViewController.currentSegueIdentifier == [self.containerViewController.ChildrenName lastObject])
    {
        return;
    }
    else
    {
        // NSLog(@"swip to left");
        for (int i = 0;i <self.containerViewController.ChildrenName.count-1;i++)
        {
            if ([self.containerViewController.ChildrenName[i] isEqualToString:self.containerViewController.currentSegueIdentifier])
            {
                self.containerViewController.currentSegueIdentifier = self.containerViewController.ChildrenName[i+1];
                [self.containerViewController performSegueWithIdentifier:self.containerViewController.currentSegueIdentifier sender:nil];
                [self.segmentControl setSelectedSegmentIndex:self.segmentControl.selectedSegmentIndex+1 animated:YES];
                break;
            }
        }
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedContainer"])
    {
        self.containerViewController = segue.destinationViewController;
        self.containerViewController.delegate = self;
        self.containerViewController.ChildrenName = @[SEGUEFIRST,SEGUESECOND,SEGUETHIRD];
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

-(void)finishLoadChildController:(UIViewController *)childController
{
    if ([childController isKindOfClass: [PhotosCollectionViewController class]])
    {
        self.suggestPhotoCollectionViewController = (PhotosCollectionViewController *)childController;
        [self.suggestPhotoCollectionViewController.collectionView setBackgroundColor:[UIColor whiteColor]];
        [self setSuggestPhotoCollectionData];
        
    }
    else if( [childController isKindOfClass:[UserListTableViewController class]])
    {
        self.suggestUserListViewConstroller = (UserListTableViewController *)childController;
        [self.suggestUserListViewConstroller setUserListStyle:UserListStyle3];
        [self setSuggestUserListData];
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
                    [self.suggestPhotoCollectionViewController.collectionView reloadData];
                }
                else if ([returnData objectForKey:@"error"])
                {
                    [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
                }
            });

        }];
    });


}
-(void)setSuggestUserListData
{
    self.suggestUserListData = [[User userList]mutableCopy];
    [self.suggestUserListViewConstroller setDatasource:self.suggestUserListData];
    [self.suggestUserListViewConstroller.tableView reloadData];
}
-(void)getLatestData
{
    [self setSuggestPhotoCollectionData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark -HMSegment action
/*
- (void)segmentValueChanged
{
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
    
}*/


@end
