//
//  PhotoDetailViewController.h
//  WUZHAO
//
//  Created by yiyi on 14-12-17.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WhatsGoingOn.h"

#import "WPHotspotLabel.h"
#import "JTImageLabel.h"

@interface PhotoDetailViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIImageView * detailPhotoView;
@property (nonatomic, strong) IBOutlet UILabel *likeLabel;
@property (nonatomic, strong) IBOutlet WPHotspotLabel *commentLabel;
@property (nonatomic, strong) IBOutlet JTImageLabel *addressLabel;

@property (nonatomic, weak) UIImage *myImage;


@property (nonatomic, weak) WhatsGoingOn *whatsGoingOnItem;


- (void)configureView:(WhatsGoingOn *)whatsGoinOnItem;

//- (void)goToTheAddress:(User *)addressUser;
@end
