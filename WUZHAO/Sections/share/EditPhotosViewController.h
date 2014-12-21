//
//  EditPhotosViewController.h
//  WUZHAO
//
//  Created by yiyi on 14-12-19.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditPhotosViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITabBarDelegate, UIActionSheetDelegate, UIScrollViewDelegate>
@property (nonatomic,strong) UIImage *editImage;

@property (nonatomic,weak) IBOutlet UIScrollView *editScrollView;
@property (nonatomic,weak) IBOutlet UIImageView *editImageView;


@end
