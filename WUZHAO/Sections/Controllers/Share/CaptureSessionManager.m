//
//  CaptureSessionManage.m
//  WUZHAO
//
//  Created by yiyi on 14-12-18.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "CaptureSessionManager.h"

#import <ImageIO/ImageIO.h>
#import <UIKit/UIKit.h>

#import "UIImage+Resize.h"
#import "PhotoCommon.h"


#define WUZHAO_APP_SIZE [[UIScreen mainScreen] applicationFrame].size
@interface CaptureSessionManager()
@property (nonatomic,strong) UIView *preview;
@end

@implementation CaptureSessionManager

-(instancetype) init
{
    self = [super init];
    if (self)
    {
        _scaleNum = 1.f;
        _preScaleNum = 1.f;
        

    }
    return self;
}

-(void)configureWithParentLayer:(id)parent previewRect:(CGRect)previewRect
{
    self.preview = parent;
    
    //队列
    [self createQueue];
    //session
    [self addSession];
    
    //previewLayer
    [self addVideoPreviewLayerWithRect:previewRect];
    [self.preview.layer addSublayer:self.previewLayer];
    
    //input
    [self addVideoInputFrontCamera:NO];
    
    //output
    [self addStillImageOutput];
    
    
    
    
}

-(void)createQueue
{
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    self.sessionQueue =sessionQueue;
}


-(void)addSession
{
    AVCaptureSession *tmpSession = [[AVCaptureSession alloc]init];
    self.session = tmpSession;
}

//设置摄像预览界面
-(void)addVideoPreviewLayerWithRect:(CGRect)previewRect
{
    AVCaptureVideoPreviewLayer *preview = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame = previewRect;
    self.previewLayer = preview;
    
}

-(void)addVideoInputFrontCamera:(BOOL)front
{
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *device in devices) {
        
        NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                NSLog(@"Device position : back");
                backCamera = device;
                
            }  else {
                NSLog(@"Device position : front");
                frontCamera = device;
            }
        }
    }
    
    NSError *error = nil;
    
    if (front) {
        AVCaptureDeviceInput *frontFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if (!error) {
            if ([_session canAddInput:frontFacingCameraDeviceInput]) {
                [_session addInput:frontFacingCameraDeviceInput];
                self.inputDevice = frontFacingCameraDeviceInput;
                
            } else {
                NSLog(@"Couldn't add front facing video input");
            }
        }
    } else {
        AVCaptureDeviceInput *backFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        if (!error) {
            if ([_session canAddInput:backFacingCameraDeviceInput]) {
                [_session addInput:backFacingCameraDeviceInput];
                self.inputDevice = backFacingCameraDeviceInput;
            } else {
                NSLog(@"Couldn't add back facing video input");
            }
        }
    }
}

-(void)addStillImageOutput
{
    AVCaptureStillImageOutput *tmpOutput = [[AVCaptureStillImageOutput alloc]init];
    NSDictionary *outputSettings = [[NSDictionary alloc]initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey , nil];//输出jpeg
    tmpOutput.outputSettings = outputSettings;
    [_session addOutput:tmpOutput];
    self.stillImageOutput = tmpOutput;
}

#pragma mark - actions
/**
 *  拍照
 */
- (void)takePicture:(DidCapturePhotoBlock)block {
    AVCaptureConnection *videoConnection = [self findVideoConnection];
    
    //	UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    //	AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
    //    [videoConnection setVideoOrientation:avcaptureOrientation];
    //[videoConnection setVideoScaleAndCropFactor:_scaleNum];
    
    NSLog(@"about to request a capture from: %@", _stillImageOutput);
    
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        CFDictionaryRef exifAttachments = CMGetAttachment(imageDataSampleBuffer, kCGImagePropertyExifDictionary, NULL);
        if (exifAttachments) {
            NSLog(@"attachements: %@", exifAttachments);
        } else {
            NSLog(@"no attachments");
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        NSLog(@"originImage:%@", [NSValue valueWithCGSize:image.size]);
        //        [SCCommon saveImageToPhotoAlbum:image];
        
        CGFloat squareLength = WUZHAO_APP_SIZE.width;
        CGFloat headHeight = _previewLayer.bounds.size.height - squareLength;//_previewLayer的frame是(0, 44, 320, 320 + 44)
        CGSize size = CGSizeMake(squareLength * 2, squareLength * 2);
        
        UIImage *scaledImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:size interpolationQuality:kCGInterpolationHigh];
        NSLog(@"scaledImage:%@", [NSValue valueWithCGSize:scaledImage.size]);
        
        CGRect cropFrame = CGRectMake((scaledImage.size.width - size.width) / 2, (scaledImage.size.height - size.height) / 2 + headHeight, size.width, size.height);
        NSLog(@"cropFrame:%@", [NSValue valueWithCGRect:cropFrame]);
        UIImage *croppedImage = [scaledImage croppedImage:cropFrame];
        NSLog(@"croppedImage:%@", [NSValue valueWithCGSize:croppedImage.size]);
        
        
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        if (orientation != UIDeviceOrientationPortrait) {
            
            CGFloat degree = 0;
            if (orientation == UIDeviceOrientationPortraitUpsideDown) {
                degree = 180;// M_PI;
            } else if (orientation == UIDeviceOrientationLandscapeLeft) {
                degree = -90;// -M_PI_2;
            } else if (orientation == UIDeviceOrientationLandscapeRight) {
                degree = 90;// M_PI_2;
            }
            croppedImage = [croppedImage rotatedByDegrees:degree];
        }
        
        //        self.imageView.image = croppedImage;
        /*
        //block、delegate、notification 3选1，传值
        if (block) {
            block(croppedImage);
        } else if ([_delegate respondsToSelector:@selector(didCapturePhoto:)]) {
            [_delegate didCapturePhoto:croppedImage];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kCapturedPhotoSuccessfully object:croppedImage];
        }*/
    }];
}

- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}

/**
 *  切换前后摄像头
 *
 *  @param isFrontCamera YES:前摄像头  NO:后摄像头
 */
- (void)switchCamera:(BOOL)isFrontCamera {
    if (!_inputDevice) {
        return;
    }
    [_session beginConfiguration];
    
    [_session removeInput:_inputDevice];
    
    [self addVideoInputFrontCamera:isFrontCamera];
    
    [_session commitConfiguration];
}

/**
 *  切换闪光灯模式
 *  （切换顺序：最开始是auto，然后是off，最后是on，一直循环）
 *  @param sender: 闪光灯按钮
 */
- (void)switchFlashMode:(UIButton*)sender {
    
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (!captureDeviceClass) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"您的设备没有拍照功能" delegate:nil cancelButtonTitle:NSLocalizedString(@"Sure", nil) otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    NSString *imgStr = @"";
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    if ([device hasFlash]) {
        //        if (!sender) {//设置默认的闪光灯模式
        //            device.flashMode = AVCaptureFlashModeAuto;
        //        } else {
        if (device.flashMode == AVCaptureFlashModeOff) {
            device.flashMode = AVCaptureFlashModeOn;
            imgStr = @"flashing_on.png";
            
        } else if (device.flashMode == AVCaptureFlashModeOn) {
            device.flashMode = AVCaptureFlashModeAuto;
            imgStr = @"flashing_auto.png";
            
        } else if (device.flashMode == AVCaptureFlashModeAuto) {
            device.flashMode = AVCaptureFlashModeOff;
            imgStr = @"flashing_off.png";
            
        }
        //        }
        
        if (sender) {
            [sender setImage:[UIImage imageNamed:imgStr] forState:UIControlStateNormal];
        }
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"您的设备没有闪光灯功能" delegate:nil cancelButtonTitle:@"噢T_T" otherButtonTitles: nil];
        [alert show];
    }
    [device unlockForConfiguration];
}

/**
 *  显示/隐藏网格
 *
 *  @param toShow 显示或隐藏
 */
- (void)switchGrid:(BOOL)toShow {
    
    if (!toShow) {
        NSArray *layersArr = [NSArray arrayWithArray:_preview.layer.sublayers];
        for (CALayer *layer in layersArr) {
            if (layer.frame.size.width == 1 || layer.frame.size.height == 1) {
                [layer removeFromSuperlayer];
            }
        }
        return;
    }
    
    CGFloat headHeight = _previewLayer.bounds.size.height - WUZHAO_APP_SIZE.width;
    CGFloat squareLength = WUZHAO_APP_SIZE.width;
    CGFloat eachAreaLength = squareLength / 3;
    
    for (int i = 0; i < 4; i++) {
        CGRect frame = CGRectZero;
        if (i == 0 || i == 1) {//画横线
            frame = CGRectMake(0, headHeight + (i + 1) * eachAreaLength, squareLength, 1);
        } else {
            frame = CGRectMake((i + 1 - 2) * eachAreaLength, headHeight, 1, squareLength);
        }
        [PhotoCommon drawALineWithFrame:frame andColor:[UIColor whiteColor] inLayer:_preview.layer];
    }
}

#pragma mark ---------------private--------------
- (AVCaptureConnection*)findVideoConnection {
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _stillImageOutput.connections) {
        for (AVCaptureInputPort *port in connection.inputPorts) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    return videoConnection;
}

@end
