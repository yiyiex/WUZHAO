//
//  UIImage+Resize.h
//  WUZHAO
//
//  Created by yiyi on 14-12-22.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)



- (UIImage *)croppedImage:(CGRect)bounds;

- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality;

- (CGAffineTransform)transformForOrientation:(CGSize)newSize;

- (UIImage *)fixOrientation;

- (UIImage *)rotatedByDegrees:(CGFloat)degrees;

- (void)setRoundCornerWithRadius:(float)radius;

@end