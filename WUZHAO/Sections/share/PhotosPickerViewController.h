//
//  PhotosPickerViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/7/1.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotosPickerViewController : UIViewController

@property (nonatomic, strong) UIButton *backButton;
@property (strong, nonatomic) NSMutableArray *imagesAndInfo;

@property (nonatomic, copy) void(^selectedImagesBlock)(NSMutableArray *imagesAndInfo);

@end
