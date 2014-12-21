//
//  MineViewController.h
//  Dtest3
//
//  Created by yiyi on 14-10-29.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareViewController : UIViewController
<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITabBarDelegate, UIActionSheetDelegate, UIScrollViewDelegate>
@property (nonatomic,weak) IBOutlet UIScrollView *editScrollView;
@property (nonatomic,weak) IBOutlet UIImageView *editImageView;

@end
