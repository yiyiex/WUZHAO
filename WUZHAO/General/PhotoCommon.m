//
//  PhotoCommon.m
//  WUZHAO
//
//  Created by yiyi on 14-12-22.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "macro.h"
#import "PhotoCommon.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>



#define ORIGINAL_MAX_WIDTH 640.0f
@implementation PhotoCommon


/**
 *  UIColor生成UIImage
 *
 *  @param color     生成的颜色
 *  @param imageSize 生成的图片大小
 *
 *  @return 生成后的图片
 */
+ (UIImage*)createImageWithColor:(UIColor*)color size:(CGSize)imageSize {
    CGRect rect=CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+(UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color
{
    UIImage *img = [UIImage imageNamed:name];
    
    UIGraphicsBeginImageContext(img.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, img.size
                             .width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context, kCGPathFill);
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return coloredImg;
}

//画一条线
+ (void)drawALineWithFrame:(CGRect)frame andColor:(UIColor*)color inLayer:(CALayer*)parentLayer {
    CALayer *layer = [CALayer layer];
    layer.frame = frame;
    layer.backgroundColor = color.CGColor;
    [parentLayer addSublayer:layer];
}

#pragma mark -------------save image to local---------------
//保存照片至本机

+ (void)saveImageToPhotoAlbum:(UIImage*)image {
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

+(void)saveImageToPhotoAlbumWithInfo:(NSDictionary *)info image:(UIImage *)image
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
    CGImageRef imageRef = image.CGImage;
    
    //方向校正
    if ([info objectForKey:@"Orientation"])
    {
        [info setValue:@(UIImageOrientationUp) forKey:@"Orientation"];
    }
    if ( [info objectForKey:@"{TIFF}"])
    {
        NSDictionary *tiff = [info objectForKey:@"{TIFF}"];
        if ([tiff objectForKey:@"Orientation"])
        {
            [[info objectForKey:@"{TIFF}"] setValue:@(UIImageOrientationUp) forKey:@"Orientation"];
        }
    }
    NSLog(@"%@",info);
    [library writeImageToSavedPhotosAlbum:imageRef metadata:info completionBlock:^(NSURL *assetURL, NSError *error) {
        NSLog(@"%@",assetURL);
        NSLog(@"%@",error);
    }];
}
+(NSDictionary *)getImageInfo:(UIImage *)image
{
    NSData *jpeg = UIImageJPEGRepresentation(image, 1.0f);
    CGImageSourceRef sourceRef = CGImageSourceCreateWithData((CFDataRef)jpeg, NULL);
    NSMutableDictionary *metaData = [(NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(sourceRef, 0, NULL)) mutableCopy];
    return metaData;
}
+(NSDictionary *)getImageInfoFromUrl:(NSURL *)url
{
    NSData *jpeg = [NSData dataWithContentsOfURL:url];
    CGImageSourceRef sourceRef = CGImageSourceCreateWithData((CFDataRef)jpeg, NULL);
    NSMutableDictionary *metaData = [(NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(sourceRef, 0, NULL)) mutableCopy];
    return metaData;
}
+(NSData *)setImageInfo:(NSDictionary *)info image:(UIImage *)image scale:(float)scale
{
    if (scale <=0 || scale >=1)
    {
        scale = 1.0f;
    }
    NSData *jpeg = UIImageJPEGRepresentation(image, scale);
    CGImageSourceRef sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)jpeg, NULL);
    
    CFStringRef UTI = CGImageSourceGetType(sourceRef);
    if (!UTI)
    {
        UTI = (__bridge CFStringRef)@"public.jpeg";
    }
    NSMutableDictionary *metaData = [(NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(sourceRef, 0, NULL)) mutableCopy];
    
    if ([info objectForKey:(NSString *)kCGImagePropertyGPSDictionary])
    {
        [metaData setObject:[info objectForKey:(NSString *)kCGImagePropertyGPSDictionary] forKey:(NSString *)kCGImagePropertyGPSDictionary];
    }
    if ([info objectForKey:(NSString *)kCGImagePropertyTIFFDictionary])
    {
        [metaData setObject:[info objectForKey:(NSString *)kCGImagePropertyTIFFDictionary] forKey:(NSString *)kCGImagePropertyTIFFDictionary];
    }
    if ([info objectForKey:(NSString *)kCGImagePropertyExifDictionary])
    {
        [metaData setObject:[info objectForKey:(NSString *)kCGImagePropertyExifDictionary] forKey:(NSString *)kCGImagePropertyExifDictionary];
    }
    NSMutableData *dest_data = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dest_data, UTI, 1, NULL);
    if (!destination)
    {
        NSLog(@"could not create image destination ");
    }
    CGImageDestinationAddImageFromSource(destination, sourceRef, 0, (__bridge CFDictionaryRef)metaData);
    BOOL success = NO;
    success = CGImageDestinationFinalize(destination);
    if (!success)
    {
        NSLog(@"could not create data from image destination");
        return nil;
    }
    else
    {
       // CGImageSourceRef newRef = CGImageSourceCreateWithData((__bridge CFDataRef)dest_data, NULL);
       // NSMutableDictionary *newMeta = [(NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(newRef, 0, NULL)) mutableCopy];
        return dest_data;
    }
}

+(void)saveImageToPhotoAlbumWithLocation:(CLLocation *)location image:(UIImage *)image
{
    NSData *jpeg = UIImageJPEGRepresentation(image, 1.0f);
    CGImageSourceRef sourceRef = CGImageSourceCreateWithData((CFDataRef)jpeg, NULL);
    NSMutableDictionary *metaData = [(NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(sourceRef, 0, NULL)) mutableCopy];
    NSMutableDictionary *GPSDictionary = [[metaData objectForKey:(NSString *)kCGImagePropertyGPSDictionary]mutableCopy];
    if (!GPSDictionary)
    {
        GPSDictionary = [NSMutableDictionary dictionary];
    }
    [GPSDictionary setValue:[NSNumber numberWithFloat:location.coordinate.latitude] forKey:(NSString *)kCGImagePropertyGPSLatitude];
    [GPSDictionary setValue:[NSNumber numberWithFloat:location.coordinate.longitude] forKey:(NSString *)kCGImagePropertyGPSLongitude];
    [metaData setObject:GPSDictionary forKey:(NSString *)kCGImagePropertyGPSDictionary];
    
    CFStringRef UTI = CGImageSourceGetType(sourceRef);
    if (!UTI)
    {
        UTI = (__bridge CFStringRef)@"public.jpeg";
    }
    NSMutableData *dest_data = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)dest_data, UTI, 1, NULL);
    if (!destination)
    {
        NSLog(@"could not create image destination ");
    }
    CGImageDestinationAddImageFromSource(destination, sourceRef, 0, (CFDictionaryRef)metaData);
    
    BOOL success = NO;
    success = CGImageDestinationFinalize(destination);
    if (!success)
    {
        NSLog(@"could not create data from image destination");
    }
    else
    {
        UIImage *newImage = [UIImage imageWithData:dest_data];
        
        [self saveImageToPhotoAlbum:newImage];
    }
    
    
}

+ (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error != NULL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出错了!" message:@"保存照片失败" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        NSLog(@"保存成功");
    }
}

#pragma mark image scale utility
+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [PhotoCommon imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

+ (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}


@end
