//
//  PhotoCommon.h
//  WUZHAO
//
//  Created by yiyi on 14-12-19.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PhotoCommon : NSObject

+(void)saveImageToPhotoAlbum:(UIImage *)image;

+ (UIImage*)createImageWithColor:(UIColor*)color size:(CGSize)imageSize;

+ (void)drawALineWithFrame:(CGRect)frame andColor:(UIColor*)color inLayer:(CALayer*)parentLayer;

@end
