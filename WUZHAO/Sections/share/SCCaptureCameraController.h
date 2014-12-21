//
//  SCCaptureCameraController.h
//  SCCaptureCameraDemo
//
//  Created by Aevitx on 14-1-16.
//  Copyright (c) 2014年 Aevitx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCCaptureSessionManager.h"

#import "CLImageEditor.h"

@interface SCCaptureCameraController : UIViewController< CLImageEditorDelegate,CLImageEditorTransitionDelegate>

@property (nonatomic, assign) CGRect previewRect;
@property (nonatomic, assign) BOOL isStatusBarHiddenBeforeShowCamera;


@end
