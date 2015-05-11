//
//  CameraUtility.m
//  WUZHAO
//
//  Created by yiyi on 15/5/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "CameraUtility.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation CameraUtility
#pragma mark ----camera utility
+(BOOL) isCameraAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
}
+(BOOL) isRearCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}
+(BOOL) isFrontCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}
+(BOOL) doesCameraSupportTakingPhotos
{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:
            UIImagePickerControllerSourceTypeCamera];
}
+(BOOL) isPhotoLibraryAvailable
{
    return  [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
}
+(BOOL) canUserPickPhotosFromPhotoLibrary
{
    return  [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
+(BOOL) canUserPickMovieFromPhotoLibrary
{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeVideo sourceType:UIImagePickerControllerSourceTypePhotoLibrary ];
}

+(BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType
{
    __block BOOL result = NO;
    if ( [paramMediaType length]==0)
    {
        return  NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ( [mediaType isEqualToString:paramMediaType])
        {
            result = YES;
            *stop  = YES;
        }
    }];
    return result;
}
@end
