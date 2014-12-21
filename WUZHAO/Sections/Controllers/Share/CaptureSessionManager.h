//
//  CaptureSessionManage.h
//  WUZHAO
//
//  Created by yiyi on 14-12-18.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@protocol CaptureSessionManager;

typedef void(^DidCapturePhotoBlock)(UIImage *stillImage);


@interface CaptureSessionManager : NSObject

@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic,strong) AVCaptureDeviceInput *inputDevice;
@property (nonatomic,strong) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic,assign) id <CaptureSessionManager> delegate;

//pinch
@property (nonatomic, assign) CGFloat preScaleNum;
@property (nonatomic, assign) CGFloat scaleNum;

-(void)configureWithParentLayer:(id)parent previewRect:(CGRect)previewRect;

-(void)takePicture:(DidCapturePhotoBlock)block;;
-(void)switchCamera:(BOOL)isFrontCamera;
-(void)switchFlashMode:(id)sender;
-(void)switchGrid:(BOOL)toShow;
@end

@protocol SCCaptureSessionManager <NSObject>

@optional
- (void)didCapturePhoto:(UIImage*)stillImage;

@end
