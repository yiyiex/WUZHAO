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

+(void)saveImageToPhotoAlbumWithInfo:(NSDictionary *)info image:(UIImage *)image;

+ (UIImage*)createImageWithColor:(UIColor*)color size:(CGSize)imageSize;

+(UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color;

+(NSDictionary *)getImageInfo:(UIImage *)image;

+(NSDictionary *)getImageInfoFromUrl:(NSURL *)url;

+(NSData *)setImageInfo:(NSDictionary *)info image:(UIImage *)image scale:(float)scale ;

+ (void)drawALineWithFrame:(CGRect)frame andColor:(UIColor*)color inLayer:(CALayer*)parentLayer;

+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage;

+ (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize;

+ (UIImage *)composeTwoImage:(UIImage *)leftImage rightImage:(UIImage *)rightImage;

+(UIImage *)addImage:(UIImage *)subImage toImage:(UIImage *)parentImage atPosition:(CGPoint)position;

+(UIImage *)generateIconWithImage:(UIImage *)iconImage logo:(UILabel *)logoLabel;
@end
