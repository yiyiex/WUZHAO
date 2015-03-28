//  
//  PhotoDetailViewController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-17.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "PhotosCollectionViewController.h"
#import "CommentTableViewCell.h"

#import "UIImageView+WebCache.h"

#import "WPAttributedStyleAction.h"
#import "NSString+WPAttributedMarkup.h"

#import "MineViewController.h"
#import "AddressViewController.h"
#import "CommentListViewController.h"

#import "UIImageView+ChangeAppearance.h"
#import "UIButton+ChangeAppearance.h"
#import "UILabel+ChangeAppearance.h"
#import "UIView+ChangeAppearance.h"


#import "QDYHTTPClient.h"
#import "SVProgressHUD.h"

#import "User.h"

@interface PhotoDetailViewController ()
@property (atomic) BOOL shoudRefreshData;
@property (nonatomic,strong) UIRefreshControl *refreshControl;
@end

@implementation PhotoDetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"照片详情"];
    self.shoudRefreshData = true;
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refreshByPullingTable:) forControlEvents:UIControlEventValueChanged];
   // [self setAppearance];
    
    [self configureView:self.whatsGoingOnItem];
    [self getLatestData];
  //  [self loadCommentTableViewData];
    //NSArray * userList = [[User userList]mutableCopy];
   

    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self setAppearance];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"hideBar" object:nil];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = NO;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getLatestData
{
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    if (self.shoudRefreshData)
    {
        self.shoudRefreshData = false;
        [[QDYHTTPClient sharedInstance]GetPhotoInfoWithPostId:self.whatsGoingOnItem.postId userId:self.whatsGoingOnItem.photoUser.UserID whenComplete:^(NSDictionary *returnData) {
            self.shoudRefreshData = true;
            if ([returnData objectForKey:@"data"])
            {
                self.whatsGoingOnItem = [returnData objectForKey:@"data"];
                [self configureView:self.whatsGoingOnItem];
                
            }
            else if ([returnData objectForKey:@"error"])
            {
                [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
            }
            if ([self.refreshControl isRefreshing])
            {
                [self.refreshControl endRefreshing];
            }
        }];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showCommentList"])
    {
        CommentListViewController *commentListViewCon = segue.destinationViewController;
        if (self.whatsGoingOnItem.commentList.count>0)
        {
            commentListViewCon.commentList = self.whatsGoingOnItem.commentList;
        }
    }
}

#pragma mark- set the content of the whole view
-(void)initView
{
    
}
-(void)setAppearance
{
    [self.userAvatarImageView setRoundConerWithRadius:self.userAvatarImageView.frame.size.width/2];
    [self.userAvatarImageView setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    [self.userNameLabel setDarkGreyLabelAppearance];
    [self.userDescriptionLabel setSmallReadOnlyLabelAppearance];
    [self.postTimeLabel setBoldReadOnlyLabelAppearance];
    
    [self.addressLabel setTextColor:THEME_COLOR_DARK_GREY];
    [self.descriptionLabel setTextColor:THEME_COLOR_DARK_GREY];

    [self.detailPhotoView setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    
    //[self.addressIcon setHidden:[self.addressLabel.text isEqualToString:@""]? YES:NO];
    //[self.descriptionIcon setHidden:[self.descriptionLabel.text isEqualToString:@""]? YES:NO];
    //[self.likeIcon setHidden:[self.likeLabel.text isEqualToString:@""]? YES:NO];
    //[self.commentIcon setHidden:[self.commentContentLabel.text isEqualToString:@""]? YES:NO];

    
    [self.commentContentLabel setBackgroundColor:[UIColor clearColor]];
    
    [self.zanButton setSmallButtonAppearance];
    [self.zanButton setGreyBackGroundAppearance];
    [self.commentButton setSmallButtonAppearance];
    [self.commentButton setGreyBackGroundAppearance];
    [self.moreButton setSmallButtonAppearance];
    [self.moreButton setGreyBackGroundAppearance];
    
    self.scrollView.contentSize = CGSizeMake(WZ_APP_SIZE.width, 200);
    
}

- (void)configureView:(WhatsGoingOn *)whatsGoinOnItem
{
    _whatsGoingOnItem = whatsGoinOnItem;
    [self.userAvatarImageView sd_setImageWithURL:[NSURL URLWithString:self.whatsGoingOnItem.photoUser.avatarImageURLString]];
    
    self.userNameLabel.text = self.whatsGoingOnItem.photoUser.UserName;
    self.userDescriptionLabel.text = [self.whatsGoingOnItem.photoUser.selfDescriptions stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    self.postTimeLabel.text = self.whatsGoingOnItem.postTime;
    
    self.likeLabel.text = [NSString stringWithFormat:@"%lu 次赞", (long)whatsGoinOnItem.likeCount];

    //评论内容显示样式
    NSDictionary *nameStyle = @{@"userName":[WPAttributedStyleAction styledActionWithAction:^{
        
        UIStoryboard *personalStoryboard= [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
        MineViewController *personalViewCon = [personalStoryboard instantiateViewControllerWithIdentifier:@"personalPage"];
        [self.navigationController pushViewController:personalViewCon animated:YES];

    }],
                                @"address":[WPAttributedStyleAction styledActionWithAction:^{
                                    NSLog(@"click the address");
                                    UIStoryboard *personalStoryboard= [UIStoryboard storyboardWithName:@"Address" bundle:nil];
                                    AddressViewController *addressViewCon = [personalStoryboard instantiateViewControllerWithIdentifier:@"addressPage"];
                                    [self.navigationController pushViewController:addressViewCon animated:YES];
                                }],
                                @"seeMore":[WPAttributedStyleAction styledActionWithAction:^{
                                    
                                    [self performSegueWithIdentifier:@"showCommentList" sender:nil];
                                }],
                                @"link": THEME_COLOR_DARK};
    
    _whatsGoingOnItem.attributedComment = [whatsGoinOnItem.comment attributedStringWithStyleBook:nameStyle];
    self.commentContentLabel.attributedText = whatsGoinOnItem.attributedComment;
    self.addressLabel.text = whatsGoinOnItem.poiName;
    self.descriptionLabel.text = whatsGoinOnItem.imageDescription;
    if (whatsGoinOnItem.likeCount >0)
    {
        self.likeLabel.text = [NSString stringWithFormat:@"%lu 次赞", (long)whatsGoinOnItem.likeCount];
    }
    else
    {
        self.likeLabel.text = @"";
    }
    if (whatsGoinOnItem.imageUrlString)
    {
        __block UIActivityIndicatorView *activityIndicator;
        __weak UIImageView *weakImageView = self.detailPhotoView;
        [self.detailPhotoView sd_setImageWithURL:[NSURL URLWithString:whatsGoinOnItem.imageUrlString]
                                placeholderImage:nil options:SDWebImageProgressiveDownload
                                        progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                            if (!activityIndicator)
                                            {
                                                [weakImageView addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
                                                activityIndicator.center = weakImageView.center;
                                            }
                                        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                            [activityIndicator removeFromSuperview];
                                            activityIndicator = nil;
                                        }];
    }
    [self.zanButton addTarget:self action:@selector(zanButtonClick:) forControlEvents:UIControlEventTouchUpInside];

    [self.commentButton addTarget:self action:@selector(commentButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.moreButton addTarget:self action:@selector(moreButtonCilck:) forControlEvents:UIControlEventTouchUpInside];
    [self setAppearance];
}

#pragma mark -gesture and action
-(void)zanButtonClick:(id)sender
{
    NSInteger userId = [[NSUserDefaults standardUserDefaults] integerForKey:@"userId"];
    if (!self.whatsGoingOnItem.isLike)
    {
        [[QDYHTTPClient sharedInstance]ZanPhotoWithUserId:userId postId:self.whatsGoingOnItem.poiId whenComplete:^(NSDictionary *returnData) {
            if ([returnData objectForKey:@"data"])
            {
                if ([self.zanButton.currentTitle isEqualToString:@"赞"])
                {
                    self.whatsGoingOnItem.likeCount += 1;
                    //[self.likeIcon setHidden:NO];
                    self.likeLabel.text = [NSString stringWithFormat:@"%lu 次赞",(long)self.whatsGoingOnItem.likeCount];
                    [self.zanButton setTitle:@"已赞" forState:UIControlStateNormal];
                    [self setAppearance];
                }
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
            }
        }];
        
    }
    else
    {
        [[QDYHTTPClient sharedInstance]CancelZanPhotoWithUserId:userId postId:self.whatsGoingOnItem.poiId whenComplete:^(NSDictionary *returnData) {
            if ([returnData objectForKey:@"data"])
            {
                if ([self.zanButton.currentTitle isEqualToString:@"已赞"])
                {
                    self.whatsGoingOnItem.likeCount -= 1;
                    if (self.whatsGoingOnItem.likeCount == 0)
                    {
                       // [self.likeIcon setHidden:YES];
                        self.likeLabel.text = @"";
                    }
                    else
                    {
                       // [self.likeIcon setHidden:NO];
                        self.likeLabel.text = [NSString stringWithFormat:@"%lu 次赞",(long)self.whatsGoingOnItem.likeCount];
                    }
                    [self.zanButton setTitle:@"赞" forState:UIControlStateNormal];
                    [self setAppearance];
                }
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
            }
        }];
    }

}
-(void)commentButtonClick:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"photoDetailAndComment" bundle:nil];
    CommentListViewController *detailAndCommentView = [storyboard instantiateViewControllerWithIdentifier:@"commentListView"];
    detailAndCommentView.poiItem = self.whatsGoingOnItem;
    [self.navigationController pushViewController:detailAndCommentView animated:YES];
}
-(void)moreButtonCilck:(UIButton *)sender
{
    NSInteger userId = [[NSUserDefaults standardUserDefaults] integerForKey:@"userId"];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"cancel click");
    }];
    [alertController addAction:cancelAction];
    
    if (userId == self.whatsGoingOnItem.photoUser.UserID)
    {
        UIAlertAction *delectAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            NSLog(@"delete pressed");
            //TO DO
            //删除该条记录
            UIAlertController *deleteWarningController = [UIAlertController alertControllerWithTitle:@"提醒" message:@"确定删除照片？" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                
            }];
            UIAlertAction *comfirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [[QDYHTTPClient sharedInstance]deletePhotoWithUserId:userId postId:self.whatsGoingOnItem.postId
                  whenComplete:^(NSDictionary *returnData)
                 {
                     [self.navigationController popViewControllerAnimated:YES];
                     [[NSNotificationCenter defaultCenter]postNotificationName:@"deleteMyPhoto" object:self userInfo:@{@"indexPath":self.cellIndexInCollection}];
                 }];
            }];
            [deleteWarningController addAction:cancelAction];
            [deleteWarningController addAction:comfirmAction];
            [self presentViewController:deleteWarningController animated:YES completion:nil];
            
        }];
        [alertController addAction:delectAction];
    }
    else
    {
        UIAlertAction *delectAction = [UIAlertAction actionWithTitle:@"举报不良内容" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            NSLog(@"举报 pressed");
            //TO DO
            //举报
        }];
        [alertController addAction:delectAction];
    }
    /*
     UIAlertAction *shareAction = [UIAlertAction actionWithTitle:@"复制共享网址" style:nil handler:^(UIAlertAction *action) {
     NSLog(@"share pressed");
     }];
     [alertController addAction:shareAction];
     */
    [self presentViewController:alertController animated:YES completion:^{
        
        
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

#pragma mark - action
-(void)refreshByPullingTable:(id)sender
{
    if (![self.refreshControl isRefreshing])
    {
        [self.refreshControl beginRefreshing];
    }
}

@end
