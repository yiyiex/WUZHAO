//
//  MyPhotoDetailViewController.m
//  Dtest3
//
//  Created by yiyi on 14-11-10.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "MyPhotoDetailViewController.h"
#import "UIImageView+WebCache.h"


@interface MyPhotoDetailViewController ()

- (void)configureView;
@end

@implementation MyPhotoDetailViewController
@synthesize detailPhotoView = _detailPhotoView;
@synthesize whatsGoingOnItem = _whatsGoingOnItem;
- (void)viewDidLoad {
    [super viewDidLoad];
    //[self.view addSubview:_detailPhotoView];
    [self configureView:_whatsGoingOnItem];
    // Do any additional setup after loading the view.
}
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   // self.detailPhoto.image = self.myImage;

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureView:(WhatsGoingOn *)whatsGoinOnItem
{
    _whatsGoingOnItem = whatsGoinOnItem;
    self.likeLabel.text = [NSString stringWithFormat:@"%@ 次赞", whatsGoinOnItem.likeCount];
    if (whatsGoinOnItem.attributedComment)
    {
        self.commentLabel.attributedText = whatsGoinOnItem.attributedComment;
    }
    else
    {
        self.commentLabel.attributedText = [self.commentLabel filterLinkWithContent:whatsGoinOnItem.comment];
    }
    if (whatsGoinOnItem.imageUrlString)
    {
        __block UIActivityIndicatorView *activityIndicator;
        __weak UIImageView *weakImageView = self.detailPhotoView;
        [self.detailPhotoView sd_setImageWithURL:whatsGoinOnItem.imageUrlString
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
}

/*
- (UIImageView *)detailPhotoView
{
    if (!_detailPhotoView)
    {
        _detailPhotoView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 200, 400, 400)];
        _detailPhotoView.contentMode = UIViewContentModeScaleToFill;
        _detailPhotoView.backgroundColor = [UIColor redColor];
        
    }
    return _detailPhotoView;
}
 */


    
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
