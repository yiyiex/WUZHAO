//
//  MyPhotoDetailViewController.h
//  Dtest3
//
//  Created by yiyi on 14-11-10.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WhatsGoingOn.h"

#import "WPHotspotLabel.h"
@interface MyPhotoDetailViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIImageView * detailPhotoView;
@property (nonatomic, strong) IBOutlet UILabel *likeLabel;
@property (nonatomic, strong) IBOutlet WPHotspotLabel *commentLabel;

@property (nonatomic, weak) UIImage *myImage;


@property (nonatomic, weak) WhatsGoingOn *whatsGoingOnItem;


- (void)configureView:(WhatsGoingOn *)whatsGoinOnItem;
@end
