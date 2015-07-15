//
//  AddressMarkAnnotationView.h
//  WUZHAO
//
//  Created by yiyi on 15/7/7.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@interface AddressMarkAnnotationView : MAAnnotationView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *imageNumLabel;

-(void)setImageWithImageUrl:(NSString*)url;
-(void)setPhotoNumber:(NSInteger )num;

@end
