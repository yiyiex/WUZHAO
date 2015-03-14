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

#import "User.h"
#import "WhatsGoingOn.h"
#import "macro.h"

#define SEGUEFIRST @"segueForSuggestPhotos"
#define SEGUESECOND @"segueForSuggestAddress"
#define SEGUETHIRD @"segueForSuggestUsers"

@interface SearchViewController () <UISearchBarDelegate,UISearchControllerDelegate,UISearchResultsUpdating,UITableViewDataSource,UITableViewDataSource ,CommonContainerViewControllerDelegate>
@property (nonatomic, strong) CommonContainerViewController *containerViewController;
@property (nonatomic, strong) PhotosCollectionViewController *suggestPhotoCollectionViewController;
@property (nonatomic, strong) UserListTableViewController *suggestUserListViewConstroller;
@property (nonatomic,strong) NSMutableArray *suggestPhotoData;
@property (nonatomic,strong) NSMutableArray *suggestUserListData;

@property (nonatomic, strong) UITableViewController *searchResultTableView;
@property (nonatomic, strong) UISearchController *searchController;

//for state restoration
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _searchResultTableView = [[UITableViewController alloc]init];
    [_searchResultTableView.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"tableCell"];
    _searchController = [[UISearchController alloc]initWithSearchResultsController:_searchResultTableView];
    
    self.searchController.searchResultsUpdater = self;
    
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
    [self.searchController.searchBar sizeToFit];
   // self.navigationItem.titleView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    self.searchResultTableView.tableView.delegate = self;
    self.searchResultTableView.tableView.dataSource = self;
    
    self.searchController.delegate = self;
    
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.searchController.searchBar.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.navigationController.navigationBarHidden = NO;
    self.tabBarController.navigationItem.titleView = self.searchController.searchBar;
    self.tabBarController.navigationItem.hidesBackButton = YES;

    //self.navigationItem.hidesBackButton = YES;
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
    self.tabBarController.navigationItem.titleView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
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

#pragma mark --------UISearchBarDelegate-----------
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    [searchBar resignFirstResponder];
}

#pragma mark -------UISearchControllerDelegate----------

// Called after the search controller's search bar has agreed to begin editing or when
// 'active' is set to YES.
// If you choose not to present the controller yourself or do not implement this method,
// a default presentation is performed on your behalf.
//
// Implement this method if the default presentation is not adequate for your purposes.
//
- (void)presentSearchController:(UISearchController *)searchController {
    
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    //NSLog(@"willPresentSearchController");
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    //NSLog(@"didPresentSearchController");
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    //NSLog(@"willDismissSearchController");
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    //NSLog(@"didDismissSearchController");
}

#pragma  mark ---------UITableView delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableCell"];
    
    cell.textLabel.text = @"test";
    cell.detailTextLabel.text =@"已有多少张照片";
    
    return cell;
}

#pragma mark -------UISearchResultsUpdating----------------
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
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
    self.suggestPhotoData = [[WhatsGoingOn newDataSource]mutableCopy];
    [self.suggestPhotoCollectionViewController setDatasource:self.suggestPhotoData];
    [self.suggestPhotoCollectionViewController loadData];
}
-(void)setSuggestUserListData
{
    self.suggestUserListData = [[User userList]mutableCopy];
    [self.suggestUserListViewConstroller setDatasource:self.suggestUserListData];
    [self.suggestUserListViewConstroller.tableView reloadData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark ------------UISegment delegate-----------------
- (IBAction)segmentIndexChanged:(id)sender {
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



@end
