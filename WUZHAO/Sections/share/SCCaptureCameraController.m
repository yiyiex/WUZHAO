//
//  SCCaptureCameraController.m
//  SCCaptureCameraDemo
//
//  Created by Aevitx on 14-1-16.
//  Copyright (c) 2014年 Aevitx. All rights reserved.
//

#import "SCCaptureCameraController.h"
#import "SCSlider.h"
#import "PhotoCommon.h"
#import "SVProgressHUD.h"

#import "SCNavigationController.h"
#import "WZFilterUIViewController.h"
#import "AddImageInfoViewController.h"

#import "CaptureItemContainerUIView.h"

#import "VPImageCropperViewController.h"


//static void * CapturingStillImageContext = &CapturingStillImageContext;
//static void * RecordingContext = &RecordingContext;
//static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

#define SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE      0   //对焦框是否一直闪到对焦完成

#define SWITCH_SHOW_DEFAULT_IMAGE_FOR_NONE_CAMERA   1   //没有拍照功能的设备，是否给一张默认图片体验一下

//height
#define CAMERA_TOPVIEW_HEIGHT   44  //title
#define CAMERA_MENU_VIEW_HEIGH  44  //menu

//color
#define bottomContainerView_UP_COLOR     [UIColor colorWithRed:233/255.0f green:233/255.0f blue:233/255.0f alpha:1.f]       //bottomContainerView的上半部分
#define bottomContainerView_DOWN_COLOR   [UIColor colorWithRed:15/255.0f green:15/255.0f blue:15/255.0f alpha:1.f]       //bottomContainerView的下半部分
#define DARK_GREEN_COLOR        [UIColor colorWithRed:15/255.0f green:15/255.0f blue:15/255.0f alpha:1.f]    //深绿色
#define LIGHT_GREEN_COLOR       [UIColor colorWithRed:233/255.0f green:233/255.0f blue:233/255.0f alpha:.8f]    //浅绿色


//对焦
#define ADJUSTINT_FOCUS @"adjustingFocus"
#define LOW_ALPHA   0.7f
#define HIGH_ALPHA  1.0f

//typedef enum {
//    bottomContainerViewTypeCamera    =   0,  //拍照页面
//    bottomContainerViewTypeAudio     =   1   //录音页面
//} BottomContainerViewType;

@interface SCCaptureCameraController ()  <VPImageCropperDelegate,UIImagePickerControllerDelegate>
{
    int alphaTimes;
    CGPoint currTouchPoint;
}

@property (nonatomic, strong) SCCaptureSessionManager *captureManager;

@property (nonatomic, strong) IBOutlet CaptureItemContainerUIView *topContainerView;//顶部view
@property (nonatomic, strong) IBOutlet UILabel *topLbl;//顶部的标题

@property (nonatomic, strong) IBOutlet CaptureItemContainerUIView *bottomContainerView;//除了顶部标题、拍照区域剩下的所有区域
@property (nonatomic, strong) IBOutlet CaptureItemContainerUIView *cameraMenuView;//网格、闪光灯、前后摄像头等按钮
@property (nonatomic, strong) NSMutableSet *cameraBtnSet;

@property (nonatomic, strong) IBOutlet UIView *doneCameraUpView;
@property (nonatomic, strong) IBOutlet UIView *doneCameraDownView;

//对焦
@property (nonatomic, strong) UIImageView *focusImageView;

@property (nonatomic, strong) SCSlider *scSlider;

//@property (nonatomic) id runtimeErrorHandlingObserver;
//@property (nonatomic) BOOL lockInterfaceRotation;

@property (nonatomic, strong) UIImage *stillImage;

@end

@implementation SCCaptureCameraController

#pragma mark -------------life cycle---------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        alphaTimes = -1;
        currTouchPoint = CGPointZero;
        
        _cameraBtnSet = [[NSMutableSet alloc] init];
    }
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"showBar" object:nil];
    //navigation bar
   /* if (self.navigationController && !self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }*/
    self.tabBarController.navigationController.navigationBarHidden = YES;
    //status bar
    if (!self.navigationController) {
        _isStatusBarHiddenBeforeShowCamera = [UIApplication sharedApplication].statusBarHidden;
        if ([UIApplication sharedApplication].statusBarHidden == NO) {
            //iOS7，需要plist里设置 View controller-based status bar appearance 为NO
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        }
    }
    
    //notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationOrientationChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:kNotificationOrientationChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endPostImage) name:@"finishPostImage" object:nil];
    //session manager
    SCCaptureSessionManager *manager = [[SCCaptureSessionManager alloc] init];
    
    //AvcaptureManager
    if (CGRectEqualToRect(_previewRect, CGRectZero)) {
        self.previewRect = CGRectMake(0, 0, WZ_APP_SIZE.width, WZ_APP_SIZE.width + CAMERA_TOPVIEW_HEIGHT);
    }
    [manager configureWithParentLayer:self.view previewRect:_previewRect];
    self.captureManager = manager;
    
    [self addShotButtons];
    [self addSelectPhotoButtons];
    [self addMenuViewButtons];
    [self addFocusView];
    [self addCameraCover];
    [self addPinchGesture];
    
    [_captureManager.session startRunning];
    
#if SWITCH_SHOW_DEFAULT_IMAGE_FOR_NONE_CAMERA
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [SVProgressHUD showErrorWithStatus:@"设备不支持拍照功能"];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CAMERA_TOPVIEW_HEIGHT, self.view.frame.size.width, self.view.frame.size.width)];
        imgView.clipsToBounds = YES;
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"default" ofType:@"jpg"]];
        [self.view addSubview:imgView];
    }
#endif
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     self.tabBarController.navigationController.navigationBarHidden = YES;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    if (!self.navigationController) {
        if ([UIApplication sharedApplication].statusBarHidden != _isStatusBarHiddenBeforeShowCamera) {
            [[UIApplication sharedApplication] setStatusBarHidden:_isStatusBarHiddenBeforeShowCamera withAnimation:UIStatusBarAnimationSlide];
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationOrientationChange object:nil];
    
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device && [device isFocusPointOfInterestSupported]) {
        [device removeObserver:self forKeyPath:ADJUSTINT_FOCUS context:nil];
    }
#endif
    
    self.captureManager = nil;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"addImageInfo"])
    {
        NSLog(@"began to the info page");
        AddImageInfoViewController *imageInfoCon = segue.destinationViewController;
        imageInfoCon.postImage = self.stillImage;
        
        
    }
}

#pragma mark - buttons

//拍照按钮
- (void)addShotButtons
{
    CGFloat downH = 0;
    CGFloat cameraBtnLength = 70;
    [self buildButton:CGRectMake((WZ_APP_SIZE.width - cameraBtnLength)/2, (_bottomContainerView.frame.size.height -downH - cameraBtnLength)/2, cameraBtnLength, cameraBtnLength)
        normalImgStr:@"shot.png"
    highlightImgStr:@"shot_h.png"
     selectedImgStr:@""
             action:@selector(takePictureBtnPressed:)
           parentView:_bottomContainerView];
}

-(void)addSelectPhotoButtons
{
    CGFloat downH = 0;
    CGFloat buttonLength = 40;
    [self buildButton:CGRectMake(50, (_bottomContainerView.frame.size.height -downH - buttonLength)/2, buttonLength, buttonLength) normalImgStr:@"" highlightImgStr:@"" selectedImgStr:@"" action:@selector(selectPhotoFromAlubm:) parentView:_bottomContainerView];
    
    
}
//拍照菜单栏上的按钮
//设置各状态显示以及响应方法 actionArr
- (void)addMenuViewButtons {
    NSMutableArray *normalArr = [[NSMutableArray alloc] initWithObjects:@"close_cha.png", @"camera_line.png", @"switch_camera.png", @"flashing_off.png", nil];
    NSMutableArray *highlightArr = [[NSMutableArray alloc] initWithObjects:@"close_cha_h.png", @"", @"", @"", nil];
    NSMutableArray *selectedArr = [[NSMutableArray alloc] initWithObjects:@"", @"camera_line_h.png", @"switch_camera_h.png", @"", nil];
    
    NSMutableArray *actionArr = [[NSMutableArray alloc] initWithObjects:@"dismissBtnPressed:", @"gridBtnPressed:", @"switchCameraBtnPressed:", @"flashBtnPressed:", nil];
    
    CGFloat eachW = WZ_APP_SIZE.width / actionArr.count;
    
    //叉与其他按钮的分割线
    [PhotoCommon drawALineWithFrame:CGRectMake(eachW, 10, 1, CAMERA_MENU_VIEW_HEIGH-20) andColor:THEME_COLOR_DARK_GREY inLayer:_cameraMenuView.layer];
    
    
    
    for (int i = 0; i < actionArr.count; i++) {
        CGFloat theH = _cameraMenuView.frame.size.height;
        UIView *parent = _cameraMenuView;
        UIButton * btn = [self buildButton:CGRectMake(eachW * i, 0, eachW, theH)
                              normalImgStr:[normalArr objectAtIndex:i]
                           highlightImgStr:[highlightArr objectAtIndex:i]
                            selectedImgStr:[selectedArr objectAtIndex:i]
                                    action:NSSelectorFromString([actionArr objectAtIndex:i])
                                parentView:parent];
        
        btn.showsTouchWhenHighlighted = YES;
        
        [_cameraBtnSet addObject:btn];
    }
}

- (UIButton*)buildButton:(CGRect)frame
            normalImgStr:(NSString*)normalImgStr
         highlightImgStr:(NSString*)highlightImgStr
          selectedImgStr:(NSString*)selectedImgStr
                  action:(SEL)action
              parentView:(UIView*)parentView {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    if (normalImgStr.length > 0) {
        [btn setImage:[UIImage imageNamed:normalImgStr] forState:UIControlStateNormal];
    }
    if (highlightImgStr.length > 0) {
        [btn setImage:[UIImage imageNamed:highlightImgStr] forState:UIControlStateHighlighted];
    }
    if (selectedImgStr.length > 0) {
        [btn setImage:[UIImage imageNamed:selectedImgStr] forState:UIControlStateSelected];
    }
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundColor:[UIColor clearColor]];
    [parentView addSubview:btn];
    
    return btn;
}

//对焦的框
- (void)addFocusView {
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"touch_focus_x.png"]];
    imgView.alpha = 0;
    [self.view addSubview:imgView];
    self.focusImageView = imgView;
    
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device && [device isFocusPointOfInterestSupported]) {
        [device addObserver:self forKeyPath:ADJUSTINT_FOCUS options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
#endif
}

//拍完照后的遮罩
- (void)addCameraCover {
    UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WZ_APP_SIZE.width, 0)];
    upView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:upView];
    self.doneCameraUpView = upView;
    
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, _bottomContainerView.frame.origin.y - 44, WZ_APP_SIZE.width, 0)];
    downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downView];
    self.doneCameraDownView = downView;
}

- (void)showCameraCover:(BOOL)toShow {
    
    [UIView animateWithDuration:0.38f animations:^{
        CGRect upFrame = _doneCameraUpView.frame;
        upFrame.size.height = (toShow ? WZ_APP_SIZE.width / 2 + CAMERA_TOPVIEW_HEIGHT : 0);
        _doneCameraUpView.frame = upFrame;
        
        CGRect downFrame = _doneCameraDownView.frame;
        downFrame.origin.y = (toShow ? WZ_APP_SIZE.width / 2 + CAMERA_TOPVIEW_HEIGHT : _bottomContainerView.frame.origin.y -44);
        downFrame.size.height = (toShow ? WZ_APP_SIZE.width / 2 : 0);
        _doneCameraDownView.frame = downFrame;
    }];
}

//伸缩镜头的手势
- (void)addPinchGesture {
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinch];
    
    //横向
    //    CGFloat width = _previewRect.size.width - 100;
    //    CGFloat height = 40;
    //    SCSlider *slider = [[SCSlider alloc] initWithFrame:CGRectMake((WZ_APP_SIZE.width - width) / 2, WZ_APP_SIZE.width + CAMERA_MENU_VIEW_HEIGH - height, width, height)];
    
    //竖向
    CGFloat width = 40;
    CGFloat height = _previewRect.size.height - 100;
    SCSlider *slider = [[SCSlider alloc] initWithFrame:CGRectMake(_previewRect.size.width - width, (_previewRect.size.height + CAMERA_MENU_VIEW_HEIGH - height) / 2, width, height) direction:SCSliderDirectionVertical];
    slider.alpha = 0.f;
    slider.minValue = MIN_PINCH_SCALE_NUM;
    slider.maxValue = MAX_PINCH_SCALE_NUM;
    
    WEAKSELF_WZ
    [slider buildDidChangeValueBlock:^(CGFloat value) {
        [weakSelf_WZ.captureManager pinchCameraViewWithScalNum:value];
    }];
    [slider buildTouchEndBlock:^(CGFloat value, BOOL isTouchEnd) {
        [weakSelf_WZ setSliderAlpha:isTouchEnd];
    }];
    
    [self.view addSubview:slider];
    
    self.scSlider = slider;
}

void c_slideAlpha() {
    
}

- (void)setSliderAlpha:(BOOL)isTouchEnd {
    if (_scSlider) {
        _scSlider.isSliding = !isTouchEnd;
        
        if (_scSlider.alpha != 0.f && !_scSlider.isSliding) {
            double delayInSeconds = 3.88;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                if (_scSlider.alpha != 0.f && !_scSlider.isSliding) {
                    [UIView animateWithDuration:0.3f animations:^{
                        _scSlider.alpha = 0.f;
                    }];
                }
            });
        }
    }
}

#pragma mark -------------touch to focus---------------
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
//监听对焦是否完成了
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:ADJUSTINT_FOCUS]) {
        BOOL isAdjustingFocus = [[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1] ];
        //        SCDLog(@"Is adjusting focus? %@", isAdjustingFocus ? @"YES" : @"NO" );
        //        SCDLog(@"Change dictionary: %@", change);
        if (!isAdjustingFocus) {
            alphaTimes = -1;
        }
    }
}

- (void)showFocusInPoint:(CGPoint)touchPoint {
    
    [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        
        int alphaNum = (alphaTimes % 2 == 0 ? HIGH_ALPHA : LOW_ALPHA);
        self.focusImageView.alpha = alphaNum;
        alphaTimes++;
        
    } completion:^(BOOL finished) {
        
        if (alphaTimes != -1) {
            [self showFocusInPoint:currTouchPoint];
        } else {
            self.focusImageView.alpha = 0.0f;
        }
    }];
}
#endif

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //    [super touchesBegan:touches withEvent:event];
    
    alphaTimes = -1;
    
    UITouch *touch = [touches anyObject];
    currTouchPoint = [touch locationInView:self.view];
    
    if (CGRectContainsPoint(_captureManager.previewLayer.bounds, currTouchPoint) == NO) {
        return;
    }
    
    [_captureManager focusInPoint:currTouchPoint];
    
    //对焦框
    [_focusImageView setCenter:currTouchPoint];
    _focusImageView.transform = CGAffineTransformMakeScale(2.0, 2.0);
    
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
    [UIView animateWithDuration:0.1f animations:^{
        _focusImageView.alpha = HIGH_ALPHA;
        _focusImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        [self showFocusInPoint:currTouchPoint];
    }];
#else
    [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        _focusImageView.alpha = 1.f;
        _focusImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f delay:0.5f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            _focusImageView.alpha = 0.f;
        } completion:nil];
    }];
#endif
}

#pragma mark -------------button actions---------------
//拍照页面，拍照按钮
- (void)takePictureBtnPressed:(UIButton*)sender {
#if SWITCH_SHOW_DEFAULT_IMAGE_FOR_NONE_CAMERA
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [SVProgressHUD showErrorWithStatus:@"设备不支持拍照功能T_T"];
        return;
    }
#endif
    
    sender.userInteractionEnabled = NO;
    
    [self showCameraCover:YES];
    
    __block UIActivityIndicatorView *actiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    actiView.center = CGPointMake(self.view.center.x, self.view.center.y - CAMERA_TOPVIEW_HEIGHT);
    [actiView startAnimating];
    [self.view addSubview:actiView];
    
    
    WEAKSELF_WZ
    [_captureManager takePicture:^(UIImage *stillImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [PhotoCommon saveImageToPhotoAlbum:stillImage];//存至本机
        });
        
        [actiView stopAnimating];
        [actiView removeFromSuperview];
        actiView = nil;
        
        double delayInSeconds = 2.f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            sender.userInteractionEnabled = YES;
            [weakSelf_WZ showCameraCover:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"hideBar" object:nil];
        });
        /*
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc]initWithImage:self.stillImage cropFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgCropperVC.delegate = self;
        [self presentViewController:imgCropperVC animated:YES completion:^{
            
            
            
        }];
         */
        
        //直接进入发布页面
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Share" bundle:nil];
        
        AddImageInfoViewController *addImageInfoCon = [storyboard instantiateViewControllerWithIdentifier:@"addImageInfo"];
        [addImageInfoCon setPostImage:stillImage];
        [self.navigationController pushViewController:addImageInfoCon animated:YES];
        
        //暂时屏蔽滤镜
       // WZFilterUIViewController *editor = [[WZFilterUIViewController alloc]initWithImage:stillImage delegate:self];
        //[self.navigationController showViewController:editor sender:self];
       // [self presentViewController:editor animated:YES completion:nil];
        
        
    }];
}

-(void)selectPhotoFromAlubm:(id)sender
{
    NSLog(@"select photo library");
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *controller = [[UIImagePickerController alloc]init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.delegate = self;
        [self presentViewController:controller animated:YES completion:^{
            NSLog(@"picker view controller  is presented");
        }];
    }
}
- (void)tmpBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//拍照页面，"X"按钮
- (void)dismissBtnPressed:(id)sender {
    NSLog(@"dismissButton Pressed");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishPostImage" object:nil];
   // [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    /*if (self.navigationController) {
        if (self.navigationController.viewControllers.count ==1) {
            
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }*/
}


//拍照页面，网格按钮
- (void)gridBtnPressed:(UIButton*)sender {
    NSLog(@"gird btn pressed");
    sender.selected = !sender.selected;
    [_captureManager switchGrid:sender.selected];
}

//拍照页面，切换前后摄像头按钮按钮
- (void)switchCameraBtnPressed:(UIButton*)sender {
    NSLog(@"switch btn pressed");
    sender.selected = !sender.selected;
    [_captureManager switchCamera:sender.selected];
}

//拍照页面，闪光灯按钮
- (void)flashBtnPressed:(UIButton*)sender {
    NSLog(@"flash btn pressed");
    [_captureManager switchFlashMode:sender];
}

#pragma mark -------------pinch camera---------------
//伸缩镜头
- (void)handlePinch:(UIPinchGestureRecognizer*)gesture {
    
    [_captureManager pinchCameraView:gesture];
    
    if (_scSlider) {
        if (_scSlider.alpha != 1.f) {
            [UIView animateWithDuration:0.3f animations:^{
                _scSlider.alpha = 1.f;
            }];
        }
        [_scSlider setValue:_captureManager.scaleNum shouldCallBack:NO];
        
        if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
            [self setSliderAlpha:YES];
        } else {
            [self setSliderAlpha:NO];
        }
    }
}


#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
        self.stillImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        UIImage *resizeImage = [self.captureManager resizeImage:self.stillImage];
        //UIImage *cropImage = [_captureManager cropAndResizeImage:self.stillImage withHead:0];
        //暂时屏蔽滤镜
       // WZFilterUIViewController *editor = [[WZFilterUIViewController alloc]initWithImage:self.stillImage delegate:self];
        //[self.navigationController showViewController:editor sender:self];
        //进入相片裁剪页面
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc]initWithImage:resizeImage cropFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        
        imgCropperVC.delegate = self;
        [self presentViewController:imgCropperVC animated:YES completion:^{
            

            
        }];


    }];
}
#pragma mark - VPImageCropperViewControllerDelegate
-(void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController
{
    [cropperViewController dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage
{
    self.stillImage = editedImage;
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        //直接进入发布页面
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Share" bundle:nil];
        
        AddImageInfoViewController *addImageInfoCon = [storyboard instantiateViewControllerWithIdentifier:@"addImageInfo"];
        [addImageInfoCon setPostImage:self.stillImage];
        [self.navigationController pushViewController:addImageInfoCon animated:YES];
    }];

    
}


#pragma mark - notification
- (void)orientationDidChange:(NSNotification*)noti {
    
    //    [_captureManager.previewLayer.connection setVideoOrientation:(AVCaptureVideoOrientation)[UIDevice currentDevice].orientation];
    
    if (!_cameraBtnSet || _cameraBtnSet.count <= 0) {
        return;
    }
    [_cameraBtnSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        UIButton *btn = ([obj isKindOfClass:[UIButton class]] ? (UIButton*)obj : nil);
        if (!btn) {
            *stop = YES;
            return ;
        }
        
        btn.layer.anchorPoint = CGPointMake(0.5, 0.5);
        CGAffineTransform transform = CGAffineTransformMakeRotation(0);
        switch ([UIDevice currentDevice].orientation) {
            case UIDeviceOrientationPortrait://1
            {
                transform = CGAffineTransformMakeRotation(0);
                break;
            }
            case UIDeviceOrientationPortraitUpsideDown://2
            {
                transform = CGAffineTransformMakeRotation(M_PI);
                break;
            }
            case UIDeviceOrientationLandscapeLeft://3
            {
                transform = CGAffineTransformMakeRotation(M_PI_2);
                break;
            }
            case UIDeviceOrientationLandscapeRight://4
            {
                transform = CGAffineTransformMakeRotation(-M_PI_2);
                break;
            }
            default:
                break;
        }
        [UIView animateWithDuration:0.3f animations:^{
            btn.transform = transform;
        }];
    }];
}



#pragma mark ---------rotate(only when this controller is presented, the code below effect)-------------
//<iOS6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOrientationChange object:nil];
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -----NSNotificationCenter selector
-(void)endPostImage
{
   // [self.navigationController popToViewController:self animated:YES];
    NSLog(@"%ld",[[self.navigationController childViewControllers]count]);
    if ([[self.navigationController childViewControllers]count]>2)
    {
        [self.navigationController popViewControllerAnimated:NO];
    }
   // [self.navigationController popViewControllerAnimated:NO];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
//iOS6+
- (BOOL)shouldAutorotate
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOrientationChange object:nil];
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    //    return [UIApplication sharedApplication].statusBarOrientation;
	return UIInterfaceOrientationPortrait;
}
#endif




@end
