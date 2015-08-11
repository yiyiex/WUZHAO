//
//  PhotosSuggestViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/8/9.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//
#define SEGUEFIRST @"SeguePhotos"

#import "PhotosSuggestViewController.h"
#import "CommonContainerViewController.h"
#import "PhotosSuggestCollectionViewController.h"
#import "SubjectViewController.h"
#import "Subject.h"
#import "QDYHTTPClient.h"
#import "SVProgressHUD.h"
#import "macro.h"
#import "UIImageView+WebCache.h"
#import "UIViewController+Basic.h"

#define bannerHeight 120

@interface PhotosSuggestViewController ()<CommonContainerViewControllerDelegate>
@property (nonatomic, strong) CommonContainerViewController *containerViewController;
@property (nonatomic, strong) PhotosSuggestCollectionViewController *photosCollectionViewController;


@end

@implementation PhotosSuggestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getLatestSubjects];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CommonContainerViewController *)containerViewController
{
    if (!_containerViewController)
    {
        _containerViewController = [[CommonContainerViewController alloc]initWithChildren:@[SEGUEFIRST]];
        
        _containerViewController.delegate = self;
    }
    return _containerViewController;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedContainer"])
    {
        self.containerViewController = (CommonContainerViewController *)segue.destinationViewController;
        self.containerViewController.delegate = self;
        self.containerViewController.ChildrenName = @[SEGUEFIRST];
    }
}

#pragma mark - commoncontainerView delegate
-(void)beginLoadChildController:(UIViewController *)childController
{
    if ([childController isKindOfClass: [PhotosSuggestCollectionViewController class]])
    {
        self.photosCollectionViewController = (PhotosSuggestCollectionViewController *)childController;
        [self getLatestSuggestPhotos];
    }
    
}
-(void)finishLoadChildController:(UIViewController *)childController
{
    if ([childController isKindOfClass: [PhotosSuggestCollectionViewController class]])
    {
        
    }
}

-(void)getLatestData
{
    [self getLatestSuggestPhotos];
    [self getLatestSubjects];
}

-(void)getLatestSubjects
{
    if (self.photosCollectionViewController)
    {
        [self.photosCollectionViewController getLatestSubjects];
    }

}

-(void)getLatestSuggestPhotos
{
    if (self.photosCollectionViewController)
    {
        [self.photosCollectionViewController getLatestDataAnimated];
    }
}



#pragma mark - pagerViewController item delegate
-(NSString *)titleForPagerViewController:(PagerViewController *)pagerViewController
{
    return @"照片";
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
