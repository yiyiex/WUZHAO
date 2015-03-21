//
//  PhotoPickerCollectionViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/3/19.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface PhotoPickerCollectionViewController : UIViewController


@property (nonatomic,strong) IBOutlet UIButton *dismissButton;

@property (nonatomic,strong) PHFetchResult *fetchResult;


@end
