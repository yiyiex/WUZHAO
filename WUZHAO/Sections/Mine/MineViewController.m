//
//  MineViewController.m
//  Dtest3
//
//  Created by yiyi on 14-11-6.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "MineViewController.h"

#import "PhotosCollectionViewController.h"
#import "FootPrintTableViewController.h"

#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"



#import "AFHTTPAPIClient.h"
#import "macro.h"


#define SEGUEFIRST @"segueForPhotosColletion"
#define SEGUESECOND @"segueForAddressTable"
#define SEGUETHIRD @"segueForThird"
#define SEGUEFORTH @"segueForForth"

@interface MineViewController () <CommonContainerViewControllerDelegate>

@property (nonatomic, strong) CommonContainerViewController *containerViewController;

@property (nonatomic, weak) PhotosCollectionViewController *myPhotoCollectionViewController;
@property (nonatomic, weak) FootPrintTableViewController *myFootPrintViewController;

@property (nonatomic, strong) NSMutableArray * myPhotosCollectionDatasource;
@property (nonatomic, strong) NSMutableArray * myAddressListDatasource;



@end

@implementation MineViewController


static NSString * const minePhotoCell = @"minePhotosCell";
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [_mineButton setTitle:@"正在加载" forState:UIControlStateNormal];
    
    [self setPersonalInfo];
    
    self.selectToShowTabbar.selectedItem = [self.selectToShowTabbar.items objectAtIndex:0];
   
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.navigationController.navigationBarHidden = NO;
    self.tabBarController.navigationItem.title = @"个人主页";
    self.tabBarController.navigationItem.hidesBackButton = YES;
   // self.hidesBottomBarWhenPushed = YES;
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"showBar" object:nil];
    [self SetPhotosCollectionData];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setUserInfo:(User *)userInfo
{
    if (!_userInfo)
    {
        _userInfo = [[User alloc]init];
    }
    _userInfo = [userInfo mutableCopy];
    
    
}

-(void)setPersonalInfo
{

    if (!_userInfo)
    {
        _userInfo = [[User alloc]init];
        _userInfo.UserID = [[NSUserDefaults standardUserDefaults] integerForKey:@"userId"];
        _userInfo.UserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    }
    [[AFHTTPAPIClient sharedInstance]GetPersonalInfoWithUserId:_userInfo.UserID whenComplete:^(NSDictionary *returnData) {
        if ([returnData objectForKey:@"data"])
        {
            User *user = [returnData objectForKey:@"data"];
            [self setUserInfo:user];
            [self updateUI];
            [self SetPhotosCollectionData];
        }
        else if ([returnData objectForKey:@"error"])
        {
            [SVProgressHUD showErrorWithStatus:@"获取个人信息失败"];
        }
    }];

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"embedContainer"])
    {
        self.containerViewController = segue.destinationViewController;
        self.containerViewController.delegate = self;
        self.containerViewController.ChildrenName = @[SEGUEFIRST,SEGUESECOND,SEGUETHIRD,SEGUEFORTH];
    }
}


#pragma mark -----tapbar----------
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSString *segueIdentifier = SEGUEFIRST;
    if (item.tag == 1)
    {
        segueIdentifier = SEGUEFIRST;
        
    }
    else if (item.tag == 2)
    {
        segueIdentifier = SEGUESECOND;
    }
    [self.containerViewController swapViewControllersWithIdentifier:segueIdentifier];
    
}

#pragma mark ----- commonContainerViewController delegate

-(void)finishLoadChildController:(UIViewController *)childController
{
    if ([childController isKindOfClass: [PhotosCollectionViewController class]])
    {
        self.myPhotoCollectionViewController = (PhotosCollectionViewController *)childController;
       // [self SetPhotosCollectionData];
        
    }
    else if( [childController isKindOfClass:[FootPrintTableViewController class]])
    {
        self.myFootPrintViewController = (FootPrintTableViewController *)childController;
        //[self SetAddressListData];
    }
}

#pragma mark ----- control the model



-(void) updateUI
{
    [self.avator sd_setImageWithURL:[NSURL URLWithString:self.userInfo.avatarImageURLString] placeholderImage:[UIImage imageNamed:@"defaultAvator"]];
    self.userNameLabel.text = self.userInfo.UserName;
    self.photosNumLabel.text =[NSString stringWithFormat:@"%lu", self.userInfo.photosNumber ? (unsigned long)self.userInfo.photosNumber:0];
    self.followersNumLabel.text =[NSString stringWithFormat:@"%lu", self.userInfo.numFollowers ? (unsigned long)self.userInfo.numFollowers:0];
    self.followsNumLabel.text = [NSString stringWithFormat:@"%lu", self.userInfo.numFollows ? (unsigned long)self.userInfo.numFollows:0];
    self.selfDescriptionLabel.text = self.userInfo.selfDescriptions ? self.userInfo.selfDescriptions:@"";
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([ud objectForKey:@"userId"])
    {
        NSInteger uid = [ud integerForKey:@"userId"];
        if (uid == self.userInfo.UserID)
        {
            [self.mineButton setTitle:@"编辑个人信息" forState:UIControlStateNormal];
        }
        else
        {
            [self.mineButton setTitle:@"关注" forState:UIControlStateNormal];
        }
    }
    else
    {
        [self.mineButton setTitle:@"  " forState:UIControlStateNormal];
        [self.mineButton setBackgroundColor:[UIColor grayColor]];
        
    }
}
-(void)SetPhotosCollectionData
{
    if (!_myPhotosCollectionDatasource)
    {
        _myPhotosCollectionDatasource = [[NSMutableArray alloc]init];
    }
    
    if (self.userInfo.photoList)
    {
        [_myPhotosCollectionDatasource removeAllObjects];
        for (NSDictionary *i in self.userInfo.photoList)
        {
            WhatsGoingOn *item = [[WhatsGoingOn alloc]init];
            item.postId = [(NSNumber *)[i objectForKey:@"post_id"] integerValue];
            item.imageUrlString = [i objectForKey:@"photo"];
            [_myPhotosCollectionDatasource addObject:item];
        }
        
    }
    //_myPhotosCollectionDatasource = [[WhatsGoingOn newDataSource]mutableCopy];
    [self.myPhotoCollectionViewController setDatasource:_myPhotosCollectionDatasource];
    [self.myPhotoCollectionViewController loadData];

}

-(void)SetAddressListData
{
    //根据个人信息，获取更多信息
    if (!_myAddressListDatasource)
    {
    /*
    
     [AFHTTPAPIClient sharedInstance]GetPersonalPhotosListWithUserId:self.userInfo.UserID complete:^(NSDictionary *result, NSError *error) {
     if (result)
     {
     //self.dataSource = [result mutableCopy];
     //set more info to userInfo
     //....
     }
     else if (error)
     {
     [SVProgressHUD showErrorWithStatus:@"请求失败,请检查连接"];
     
     }
     }];
     
     */

    }
    _myAddressListDatasource = [[FootPrint newData]mutableCopy];
    [self.myFootPrintViewController setDatasource:_myAddressListDatasource];
    [self.myFootPrintViewController loadData];
}

- (IBAction)MineButtonClick:(id)sender {
    if ( [sender isKindOfClass:[UIButton class]])
    {
        UIButton *myBtn = (UIButton *)sender;
        if ([myBtn.titleLabel.text  isEqualToString:@"编辑个人信息"])
        {
            [self performSegueWithIdentifier:@"editPersonInfo" sender:self];
        }
        
    }
}
@end
