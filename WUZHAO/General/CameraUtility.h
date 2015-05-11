//
//  CameraUtility.h
//  WUZHAO
//
//  Created by yiyi on 15/5/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CameraUtility : NSObject
+(BOOL) isCameraAvailable;
+(BOOL) isRearCameraAvailable;
+(BOOL) isFrontCameraAvailable;
+(BOOL) doesCameraSupportTakingPhotos;
+(BOOL) isPhotoLibraryAvailable;
+(BOOL) canUserPickPhotosFromPhotoLibrary;
+(BOOL) canUserPickMovieFromPhotoLibrary;

+(BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType;
@end
