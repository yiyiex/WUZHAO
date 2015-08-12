//
//  FloatCaptureView.m
//  WUZHAO
//
//  Created by yiyi on 15/8/11.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "FloatCaptureView.h"


NSString * const CaptureViewDidReceiveTouchEventNotification = @"CaptureViewDidReceiveTouchEventNotification";
NSString * const CaptureViewDidTouchDownInsideNotification = @"CaptureViewDidTouchDownInsideNotification";

static const UIImage *CaptureViewImage;

@interface FloatCaptureView()
@property (nonatomic, strong) UIControl *overlayView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic) UIOffset centerOffset;
@end
@implementation FloatCaptureView

+(FloatCaptureView *)sharedInstance
{
    static dispatch_once_t once;
    static FloatCaptureView *sharedInstance;
    dispatch_once(&once, ^{
        CGRect frame = CGRectMake(0, 0, 48, 48);
        sharedInstance = [[FloatCaptureView alloc]initWithFrame:frame];
    });
    return sharedInstance;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
#pragma mark - getters
- (NSTimeInterval)displayDurationForString:(NSString*)string {
    return MIN((float)string.length*0.06 + 0.5, 5.0);
}

-(UIControl *)overlayView
{
    if (!_overlayView)
    {
        _overlayView = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, 48, 48)];
        _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _overlayView.backgroundColor = [UIColor clearColor];
        //_overlayView.userInteractionEnabled = NO;
    }
    return _overlayView;
}
-(UIImageView *)imageView
{
    if (!_imageView)
    {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 48, 48)];
        _imageView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin);
        UITapGestureRecognizer *imageViewTapped = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(captureViewTapped)];
        self.imageView.userInteractionEnabled = YES;
        [self.imageView addGestureRecognizer:imageViewTapped];
        self.imageView.image = [UIImage imageNamed:@"camera_float"];
        
    }
    if (!_imageView.superview)
    {
        [self addSubview:_imageView];
    }

    return _imageView;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
+(void)setHidden:(BOOL)hidden
{
    if (hidden)
    {
        [[self sharedInstance]hideViewWithAnimate];
    }
    else
    {
        [[self sharedInstance]showViewWithAnimate];
    }
}
-(void)showViewWithAnimate
{
    self.imageView.transform = CGAffineTransformScale(self.imageView.transform, 1.3, 1.3);
    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.imageView.alpha = 1.0f;
                         self.alpha = 1.0f;
                          self.imageView.transform = CGAffineTransformScale(self.imageView.transform, 1/1.3, 1/1.3);
                          }
                          completion:^(BOOL finished){
                              self.imageView.transform = CGAffineTransformIdentity;
                          }];
}
-(void)hideViewWithAnimate
{
   // self.imageView.transform = CGAffineTransformScale(self.imageView.transform, 1.3, 1.3);
    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.imageView.transform = CGAffineTransformScale(self.imageView.transform, 0.8f, 0.8f);
                     }
                     completion:^(BOOL finished){
                         self.alpha = 0.0f;
                         self.imageView.alpha = 0.0f;
                         self.imageView.transform = CGAffineTransformIdentity;
                         
                     }];
}
+(void)show
{
    [[self sharedInstance]showCaptureView];
}
-(void)showCaptureView
{
    if (!self.overlayView.superview)
    {
        NSEnumerator *frontToBackWindows = [[UIApplication sharedApplication].windows reverseObjectEnumerator];
        for (UIWindow *window in frontToBackWindows)
        {
            BOOL windowOnMainScreen = window.screen == [UIScreen mainScreen];
            BOOL windowIsVisiable = !window.hidden && window.alpha >0;
            BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
            if (windowOnMainScreen && windowIsVisiable && windowLevelNormal)
            {
                [window addSubview:self.overlayView];
                break;
            }
        }
    }
    else
    {
        [self.overlayView.superview bringSubviewToFront:self.overlayView];
    }
    if (!self.superview)
    {
        [self.overlayView addSubview:self];
    }
    [self positionView:nil];
    
    [self registerNotifications];
    
    
    self.imageView.transform = CGAffineTransformScale(self.imageView.transform, 1.3, 1.3);
    
    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.imageView.alpha = 1.0f;
                         self.alpha = 1.0f;
                         self.imageView.transform = CGAffineTransformScale(self.imageView.transform, 1/1.3, 1/1.3);
                     }
                     completion:^(BOOL finished){
                     }];
    
    [self setNeedsDisplay];

    
}
+(void)dismiss
{
    [[self sharedInstance]dismissCaptureView];
}
-(void)dismissCaptureView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.imageView.transform = CGAffineTransformScale(self.imageView.transform, 0.8f, 0.8f);
                     }
                     completion:^(BOOL finished){
                         self.alpha = 0.0f;
                         self.imageView.alpha = 0.0f;
                         
                         [_imageView removeFromSuperview];
                         _imageView = nil;
                         
                         [_overlayView removeFromSuperview];
                         _overlayView = nil;
                         
                     }];

}

+(void)setOffsetFromCenter:(UIOffset)offset
{
    
}

+(void)resetOffsetFromCenter
{
    
}

-(void)positionView:(NSNotification *)notification
{
    CGFloat keyboardHeight = 0.0f;
    double animationDuration = 0.0;
    self.frame = [UIScreen mainScreen].bounds;
    
#if !defined(SV_APP_EXTENSIONS)
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
#else
    UIInterfaceOrientation orientation = CGRectGetWidth(self.frame) > CGRectGetHeight(self.frame) ? UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationPortrait;
#endif
    // no transforms applied to window in iOS 8, but only if compiled with iOS 8 sdk as base sdk, otherwise system supports old rotation logic.
    BOOL ignoreOrientation = NO;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(operatingSystemVersion)]) {
        ignoreOrientation = YES;
    }
#endif
    
    if(notification) {
        NSDictionary* keyboardInfo = [notification userInfo];
        CGRect keyboardFrame = [[keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        animationDuration = [[keyboardInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        if(notification.name == UIKeyboardWillShowNotification || notification.name == UIKeyboardDidShowNotification) {
            if(ignoreOrientation || UIInterfaceOrientationIsPortrait(orientation))
                keyboardHeight = CGRectGetHeight(keyboardFrame);
            else
                keyboardHeight = CGRectGetWidth(keyboardFrame);
        }
    } else {
        keyboardHeight = self.visibleKeyboardHeight;
    }
    
    CGRect orientationFrame = self.bounds;
#if !defined(SV_APP_EXTENSIONS)
    CGRect statusBarFrame = UIApplication.sharedApplication.statusBarFrame;
#else
    CGRect statusBarFrame = CGRectZero;
#endif
    
    if(!ignoreOrientation && UIInterfaceOrientationIsLandscape(orientation)) {
        float temp = CGRectGetWidth(orientationFrame);
        orientationFrame.size.width = CGRectGetHeight(orientationFrame);
        orientationFrame.size.height = temp;
        
        temp = CGRectGetWidth(statusBarFrame);
        statusBarFrame.size.width = CGRectGetHeight(statusBarFrame);
        statusBarFrame.size.height = temp;
    }
    
    CGFloat activeHeight = CGRectGetHeight(orientationFrame);
    
    if(keyboardHeight > 0)
        activeHeight += CGRectGetHeight(statusBarFrame)*2;
    
    activeHeight -= keyboardHeight;
    
    CGFloat posY = floor(activeHeight *0.95);
    CGFloat posX = CGRectGetWidth(orientationFrame)/2;
    
    CGPoint newCenter;
    CGFloat rotateAngle;
    
    if (ignoreOrientation)
    {
        rotateAngle = 0.0;
        newCenter = CGPointMake(posX, posY);
    }
    else
    {
        switch (orientation) {
            case UIInterfaceOrientationPortraitUpsideDown:
                rotateAngle = M_PI;
                newCenter = CGPointMake(posX, CGRectGetHeight(orientationFrame)-posY);
                break;
            case UIInterfaceOrientationLandscapeLeft:
                rotateAngle = -M_PI/2.0f;
                newCenter = CGPointMake(posY, posX);
                break;
            case UIInterfaceOrientationLandscapeRight:
                rotateAngle = M_PI/2.0f;
                newCenter = CGPointMake(CGRectGetHeight(orientationFrame)-posY, posX);
                break;
            default:
                rotateAngle = 0.0;
                newCenter = CGPointMake(posX, posY);
                break;
        }
    }
    if (notification)
    {
        [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            [self moveToPoint:newCenter rotateAngle:rotateAngle];
            [self.imageView setNeedsDisplay];
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        [self moveToPoint:newCenter rotateAngle:rotateAngle];
        [self.imageView setNeedsDisplay];
    }
}
-(void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle
{
    self.overlayView.center = CGPointMake(newCenter.x+self.centerOffset.horizontal, newCenter.y + self.centerOffset.vertical);
    self.imageView.transform = CGAffineTransformMakeRotation(angle);
    
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionView:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionView:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionView:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionView:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionView:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
}

-(void)captureViewTapped
{
    self.imageView.transform = CGAffineTransformScale(self.imageView.transform, 1.3f, 1.3f);
    [UIView animateWithDuration:0.05
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.imageView.transform = CGAffineTransformScale(self.imageView.transform, 1.0f, 1.0f);
                     }
                     completion:^(BOOL finished){
                         self.imageView.transform = CGAffineTransformIdentity;
                      
                     }];
      [[NSNotificationCenter defaultCenter]postNotificationName:CaptureViewDidTouchDownInsideNotification object:nil];
    //[self.overlayView setUserInteractionEnabled:YES];

    //[self.overlayView setUserInteractionEnabled:NO];
}


- (CGFloat)visibleKeyboardHeight {
#if !defined(SV_APP_EXTENSIONS)
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if(![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    
    for (__strong UIView *possibleKeyboard in [keyboardWindow subviews]) {
        if ([possibleKeyboard isKindOfClass:NSClassFromString(@"UIPeripheralHostView")] || [possibleKeyboard isKindOfClass:NSClassFromString(@"UIKeyboard")]) {
            return CGRectGetHeight(possibleKeyboard.bounds);
        } else if ([possibleKeyboard isKindOfClass:NSClassFromString(@"UIInputSetContainerView")]) {
            for (__strong UIView *possibleKeyboardSubview in [possibleKeyboard subviews]) {
                if ([possibleKeyboardSubview isKindOfClass:NSClassFromString(@"UIInputSetHostView")]) {
                    return CGRectGetHeight(possibleKeyboardSubview.bounds);
                }
            }
        }
    }
#endif
    return 0;
}

@end
