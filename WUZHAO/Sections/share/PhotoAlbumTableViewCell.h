//
//  PhotoAlbumTableViewCell.h
//  WUZHAO
//
//  Created by yiyi on 15/7/1.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface PhotoAlbumTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *albumLastImageView;
@property (nonatomic, strong) IBOutlet UILabel *albumNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *albumPhotoNumLabel;
@end
