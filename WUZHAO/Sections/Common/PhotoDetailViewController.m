//
//  PhotoDetailViewController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-17.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "UIImageView+WebCache.h"

@interface PhotoDetailViewController ()

@end

@implementation PhotoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView:self.whatsGoingOnItem];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureView:(WhatsGoingOn *)whatsGoinOnItem
{
    NSLog(@"set the detail page");
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
    if (whatsGoinOnItem.adddresMark)
    {
        //self.addressLabel = [[JTImageLabel alloc]init];
        self.addressLabel.textLabel.text = whatsGoinOnItem.adddresMark;
        // self.addressLabel.textLabel.numberOfLines = 1;
        self.addressLabel.imageView.image = [UIImage imageNamed:@"location"];
        self.addressLabel.textLabel.textAlignment = NSTextAlignmentLeft;
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
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
