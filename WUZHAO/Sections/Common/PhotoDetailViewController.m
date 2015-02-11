//  
//  PhotoDetailViewController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-17.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "PhotoDetailViewController.h"

#import "CommentTableViewCell.h"

#import "UIImageView+WebCache.h"

#import "WPAttributedStyleAction.h"
#import "NSString+WPAttributedMarkup.h"

#import "MineViewController.h"
#import "AddressViewController.h"
#import "CommentListViewController.h"

#import "User.h"

@interface PhotoDetailViewController ()
@end

@implementation PhotoDetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"照片详情"];
    
    [self configureView:self.whatsGoingOnItem];
  //  [self loadCommentTableViewData];
    //NSArray * userList = [[User userList]mutableCopy];
   

    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
- (void)configureView:(WhatsGoingOn *)whatsGoinOnItem
{
    _whatsGoingOnItem = whatsGoinOnItem;
    self.likeLabel.text = [NSString stringWithFormat:@"%lu 次赞", whatsGoinOnItem.likeCount];

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
    
    if (whatsGoinOnItem.comment)
    {
        self.commentContentLabel.attributedText = whatsGoinOnItem.attributedComment;
    }
    if (whatsGoinOnItem.adddresMark)
    {
        self.addressLabel.text = whatsGoinOnItem.adddresMark;
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
    
    self.commentList = whatsGoinOnItem.commentList;
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
