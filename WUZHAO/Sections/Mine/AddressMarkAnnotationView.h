//
//  AddressMarkAnnotationView.h
//  WUZHAO
//
//  Created by yiyi on 15/7/7.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

//#import <MAMapKit/MAMapKit.h>
#import <MapKit/MapKit.h>
#import "SWSnapshotStackView.h"

@interface AddressMarkAnnotationView : MKAnnotationView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) SWSnapshotStackView *snapshotStackView;
@property (nonatomic, strong) UILabel *imageNumLabel;

-(void)setImageWithImageUrl:(NSString*)url;
-(void)setPhotoNumber:(NSInteger )num;

@end
