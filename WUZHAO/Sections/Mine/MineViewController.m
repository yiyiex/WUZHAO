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

#import "UserListTableViewController.h"

#import "UIImageView+WebCache.h"
#import "UIImageView+ChangeAppearance.h"
#import "UIButton+ChangeAppearance.h"


#import "SVProgressHUD.h"



#import "QDYHTTPClient.h"
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
    [self configGesture];
    
    self.selectToShowTabbar.selectedItem = [self.selectToShowTabbar.items objectAtIndex:0];
   
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.navigationController.navigationBarHidden = NO;
    if ([self.userInfo.UserName isEqualToString:@""])
    {
        self.tabBarController.navigationItem.title = @"个人主页";
    }
    else
    {
        self.tabBarController.navigationItem.title = self.userInfo.UserName;
    }
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
    [[QDYHTTPClient sharedInstance]GetPersonalInfoWithUserId:_userInfo.UserID whenComplete:^(NSDictionary *returnData) {
        if ([returnData objectForKey:@"data"])
        {
            User *user = [returnData objectForKey:@"data"];
            NSLog(@"userinfo %@",user);
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

#pragma mark - gesture and action
-(void)configGesture
{
    self.rightHeaderView.userInteractionEnabled = YES;
    self.followersNumLabel.userInteractionEnabled = YES;
    self.followsNumLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *photoListClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(photoListShow:)];
    [self.photosNumLabel addGestureRecognizer:photoListClick];
    UITapGestureRecognizer *followsCilck = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(followsShow:)];
    [self.followsNumLabel addGestureRecognizer:followsCilck];
    //[self.followsLabel addGestureRecognizer:followsCilck];
    UITapGestureRecognizer *followersClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(followersShow:)];
    NSLog(@"add gesture");
    [self.followersNumLabel addGestureRecognizer:followersClick];
    
}

-(void)photoListShow:(UITapGestureRecognizer *)gesture
{
    
}

-(void)followsShow:(UITapGestureRecognizer *)gesture
{
    NSInteger userId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    [[QDYHTTPClient sharedInstance]GetPersonalFollowsListWithUserId:userId whenComplete:^(NSDictionary *returnData) {
        NSLog(@"%@",[returnData objectForKey:@"data"]);
        
        UIStoryboard *userListStoryBoard = [UIStoryboard storyboardWithName:@"UserList" bundle:nil];
        UserListTableViewController *followsList = [userListStoryBoard instantiateViewControllerWithIdentifier:@"userListTableView"];
        [followsList setUserListStyle:UserListStyle2];
        [followsList setDatasource:[returnData objectForKey:@"data"]];
        [followsList setTitle:@"我关注的"];
        [self.navigationController showViewController:followsList sender:self];
    }];

    
}

-(void)followersShow:(UITapGestureRecognizer *)gesture

{
    NSInteger userId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    [[QDYHTTPClient sharedInstance]GetPersonalFollowersListWithUserId:userId whenComplete:^(NSDictionary *returnData) {
        NSLog(@"%@",[returnData objectForKey:@"data"]);
        UIStoryboard *userListStoryBoard = [UIStoryboard storyboardWithName:@"UserList" bundle:nil];
        UserListTableViewController *followsList = [userListStoryBoard instantiateViewControllerWithIdentifier:@"userListTableView"];
        [followsList setUserListStyle:UserListStyle2];
        [followsList setDatasource:[returnData objectForKey:@"data"]];
        [followsList setTitle:@"关注我的"];
        [self.navigationController showViewController:followsList sender:self];
    }];
    
}
- (IBAction)MineButtonClick:(id)sender {
    if ( [sender isKindOfClass:[UIButton class]])
    {
        UIButton *myBtn = (UIButton *)sender;
        if ([myBtn.titleLabel.text  isEqualToString:@"编辑个人信息"])
        {
            [self performSegueWithIdentifier:@"editPersonInfo" sender:self];
        }
        else if ([myBtn.titleLabel.text  isEqualToString:@"关注"])
        {
            NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
            [[QDYHTTPClient sharedInstance]followUser:self.userInfo.UserID withUserId:myUserId whenComplete:^(NSDictionary *result) {
                if ([result objectForKey:@"data"])
                {
                    //[SVProgressHUD showInfoWithStatus:@"关注成功"];
                    [myBtn setTitle:@"已关注" forState:UIControlStateNormal];
                    
                }
                else if ([result objectForKey:@"error"])
                {
                    [SVProgressHUD showErrorWithStatus:[result objectForKey:@"error"]];
                }
            }];
        }
        else if ([myBtn.titleLabel.text  isEqualToString:@"已关注"])
        {
            NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
            [[QDYHTTPClient sharedInstance]unFollowUser:self.userInfo.UserID withUserId:myUserId whenComplete:^(NSDictionary *result) {
                if ([result objectForKey:@"data"])
                {
                    //[SVProgressHUD showInfoWithStatus:@"关注成功"];
                    [myBtn setTitle:@"关注" forState:UIControlStateNormal];
                    
                }
                else if ([result objectForKey:@"error"])
                {
                    [SVProgressHUD showErrorWithStatus:[result objectForKey:@"error"]];
                }
            }];
        }
        
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"embedContainer"])
    {
        self.containerViewController = segue.destinationViewController;
        self.containerViewController.delegate = self;
        self.containerViewController.ChildrenName = @[SEGUEFIRST,SEGUESECOND,SEGUETHIRD,SEGUEFORTH];
    }
}


#pragma mark -tapbar
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
#pragma mark - commonContainerViewController delegate

-(void)finishLoadChildController:(UIViewController *)childController
{
    if ([childController isKindOfClass: [PhotosCollectionViewController class]])
    {
        self.myPhotoCollectionViewController = (PhotosCollectionViewController *)childController;
        [self.myPhotoCollectionViewController.collectionView setBackgroundColor:[UIColor whiteColor]];
        [self SetPhotosCollectionData];
        
    }
    else if( [childController isKindOfClass:[FootPrintTableViewController class]])
    {
        self.myFootPrintViewController = (FootPrintTableViewController *)childController;
        [self SetAddressListData];
    }
}

#pragma mark - control the model



-(void) updateUI
{
    //set navigation title
    [self.tabBarController.navigationItem setTitle:self.userInfo.UserName];
    [self.navigationItem setTitle:self.userInfo.UserName];
    
    
    [self.avator setRoundConerWithRadius:self.avator.frame.size.width/2];
    
    [self.avator sd_setImageWithURL:[NSURL URLWithString:self.userInfo.avatarImageURLString] placeholderImage:[UIImage imageNamed:@"default"]];
    
    [self.mineButton setNormalButtonAppearance];
    [self.mineButton setThemeBackGroundAppearance];

    self.photosNumLabel.text =[NSString stringWithFormat:@"%lu", self.userInfo.photosNumber ? (unsigned long)self.userInfo.photosNumber:0];
    self.followersNumLabel.text =[NSString stringWithFormat:@"%lu", self.userInfo.numFollowers ? (unsigned long)self.userInfo.numFollowers:0];
    self.followsNumLabel.text = [NSString stringWithFormat:@"%lu", self.userInfo.numFollows ? (unsigned long)self.userInfo.numFollows:0];
    self.selfDescriptionLabel.text = self.userInfo.selfDescriptions ? [self.userInfo.selfDescriptions stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"]:@"";
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
        //NSLog(@"photolist %@",self.userInfo.photoList);
        [_myPhotosCollectionDatasource removeAllObjects];
        for (NSDictionary *i in self.userInfo.photoList)
        {
            WhatsGoingOn *item = [[WhatsGoingOn alloc]init];
            item.postId = [(NSNumber *)[i objectForKey:@"post_id"] integerValue];
            item.imageUrlString = [i objectForKey:@"photoUrl"];
            item.postTime = [i objectForKey:@"time"];
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

-(void)getFollowsList
{

}


@end
