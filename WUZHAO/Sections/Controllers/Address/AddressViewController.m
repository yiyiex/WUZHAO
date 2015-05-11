//
//  AddressViewController.m
//  WUZHAO
//
//  Created by yiyi on 15-1-4.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "AddressViewController.h"
#import "CommonContainerViewController.h"
#import "PhotosCollectionViewController.h"

#import "QDYHTTPClient.h"

#define SEGUEFIRST @"photoCollectionViewSegue"
#define SEGUESECOND @"sharedPeopleTableViewSegue"

@interface AddressViewController () <CommonContainerViewControllerDelegate>
@property (nonatomic, strong) CommonContainerViewController *containerViewController;
@property (nonatomic,strong) PhotosCollectionViewController *photoCollectionViewCon;
@property (nonatomic,strong) NSMutableArray *photoCollectionDatasource;
@property (nonatomic) BOOL shouldRefresh;
@end

@implementation AddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    if ([self.view respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self.view setLayoutMargins:UIEdgeInsetsZero];
    }
    self.shouldRefresh = true;
    [self.containerViewController swapViewControllersWithIdentifier:SEGUEFIRST];
    [self getLatestAddressPhoto];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedContainer"])
    {
        
        self.containerViewController = (CommonContainerViewController *)segue.destinationViewController;
        self.containerViewController.delegate = self;
        self.containerViewController.ChildrenName = @[SEGUEFIRST,SEGUESECOND];
        
    }
}

-(CommonContainerViewController *)containerViewController
{
    if (!_containerViewController)
    {
        _containerViewController = [[CommonContainerViewController alloc]initWithChildren:@[SEGUEFIRST,SEGUESECOND]];
        _containerViewController.delegate = self;
    }
    return _containerViewController;
}

-(void)finishLoadChildController:(UIViewController *)childController
{
    if ([childController isKindOfClass: [PhotosCollectionViewController class]])
    {
        self.photoCollectionViewCon = (PhotosCollectionViewController *)childController;
        [self.photoCollectionViewCon.collectionView setBackgroundColor:[UIColor whiteColor]];
        [self setPhotoCollectionData];
        
    }
}

-(void)setPhotoCollectionData
{
    [self.photoCollectionViewCon setDatasource:self.photoCollectionDatasource];
    [self.photoCollectionViewCon.collectionView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)getLatestAddressPhoto
{
    if (self.poiId <=0)
        return;
    if (self.poiName)
    {
        [self.navigationItem setTitle:self.poiName];
    }
    self.shouldRefresh = false;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[QDYHTTPClient sharedInstance]GetPOIInfoWithPoiId:self.poiId whenComplete:^(NSDictionary *returnData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([returnData objectForKey:@"data"])
                {
                    self.photoCollectionDatasource = [[returnData objectForKey:@"data"]mutableCopy];
                    [self setPhotoCollectionData];
                    //[self.photoCollectionViewCon loadData];
                }
                else if ([returnData objectForKey:@"error"])
                {
                    
                    
                }
                self.shouldRefresh = true;
            });

        }];
    });

}

@end
