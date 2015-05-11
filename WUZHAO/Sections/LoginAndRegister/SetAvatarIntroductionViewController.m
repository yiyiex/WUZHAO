//
//  SetAvatarIntroductionViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/5/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "SetAvatarIntroductionViewController.h"
#import "MainTabBarViewController.h"
#import "macro.h"
#import "UILabel+ChangeAppearance.h"
#import "UIImageView+ChangeAppearance.h"
#import "UIButton+ChangeAppearance.h"
#import "VPImageCropperViewController.h"
#import "CameraUtility.h"
#import "PhotoCommon.h"

#import "QDYHTTPClient.h"
#import "SVProgressHUD.h"
#import "QiniuSDK.h"



@interface SetAvatarIntroductionViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,VPImageCropperDelegate>

@end

@implementation SetAvatarIntroductionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)initView
{
    [self.view setUserInteractionEnabled:YES];
    
    [self.navigationItem setHidesBackButton:YES];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"跳过" style:UIBarButtonItemStylePlain target:self action:@selector(jumpTopNext:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    [self.intruductionLabel setBoldReadOnlyLabelAppearance];
    [self.intruductionLabel setFont:WZ_FONT_LARGE_BOLD_SIZE];
    
    float avatarImageViewWidth = self.avatarImageView.frame.size.width;
    [self.avatarImageView setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    [self.avatarImageView setRoundConerWithRadius:self.avatarImageView.frame.size.width/2];
    
    self.avatarLabel = [[UILabel alloc]initWithFrame:CGRectMake(avatarImageViewWidth/20, avatarImageViewWidth/8*3, avatarImageViewWidth/10*9, avatarImageViewWidth/4)];
    [self.avatarLabel setText:@"点击设置头像"];
    [self.avatarLabel setFont:WZ_FONT_COMMON_SIZE];
    [self.avatarLabel setTextColor:THEME_COLOR_LIGHT_GREY];
    [self.avatarImageView addSubview:self.avatarLabel];
    
    UITapGestureRecognizer *avatarClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarClickAction:)];
    [self.avatarLabel setUserInteractionEnabled:YES];
    [self.avatarLabel addGestureRecognizer:avatarClick];
    [self.avatarImageView setUserInteractionEnabled:YES];
    [self.avatarImageView addGestureRecognizer:avatarClick];
    
    
    [self.selfDescriptionTextView setPlaceholder:@"设置一句话签名"];
    [self.selfDescriptionTextView setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    
    [self.nextButton setTitle:@"保存并进入Place" forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(nextButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.nextButton setThemeBackGroundAppearance];
    [self.nextButton setBigButtonAppearance];
    
    [self.nextButton setEnabled:NO];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)jumpTopNext:(UIGestureRecognizer *)gesture
{
    //进入主页
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MainTabBarViewController *main = [mainStoryboard instantiateViewControllerWithIdentifier:@"mainTabBarController"];
    [self.navigationController pushViewController:main animated:YES];
    return ;
}
-(void)avatarClickAction:(UITapGestureRecognizer *)gesture
{
    UIActionSheet *choiceSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}

-(void)nextButtonClick:(id)sender
{
    //保存签名
    if (self.selfDescriptionTextView.text)
    {
        [SVProgressHUD showWithStatus:@"数据提交中..."];
        
        User  *newUserInfo = [[User alloc]init];
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        newUserInfo.UserID = [ud integerForKey:@"userId"];
        newUserInfo.avatarImageURLString = [ud objectForKey:@"avatarUrl"];
        newUserInfo.selfDescriptions = self.selfDescriptionTextView.text;
        newUserInfo.UserName = [ud objectForKey:@"userName"];
        [[QDYHTTPClient sharedInstance]UpdatePersonalInfoWithUser:newUserInfo oldNick:newUserInfo.UserName whenComplete:^(NSDictionary *returnData) {
            if ([returnData objectForKey:@"data"])
            {
                [SVProgressHUD dismiss];
                
                 //进入主页
                 UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                 MainTabBarViewController *main = [mainStoryboard instantiateViewControllerWithIdentifier:@"mainTabBarController"];
                 [self.navigationController pushViewController:main animated:YES];
                 return ;
                
                
            }
            else if ([returnData objectForKey:@"error"])
            {
                
                [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
            }
        }];
    }
   
    
}

#pragma mark ---VPImageCropperDelegate
-(void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage
{
    UIImage *newAvatorImage = [PhotoCommon imageByScalingToMaxSize:editedImage];
    self.avatarImageView.image = newAvatorImage;
    [self.avatarLabel setHidden:YES];
    [self.nextButton setThemeBackGroundAppearance];
    [self.nextButton setEnabled:YES];
    NSInteger userId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[QDYHTTPClient sharedInstance]GetQiNiuTokenWithUserId:userId type:2 whenComplete:^(NSDictionary *returnData) {
                NSDictionary *data;
                if ([returnData objectForKey:@"data"])
                {
                    data = [returnData objectForKey:@"data"];
                    NSLog(@"%@",data);
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showErrorWithStatus:@"获取token失败"];
                        return ;
                    });
                    
                }
                QNUploadManager *upLoadManager = [[QNUploadManager alloc]init];
                NSData *imageData = UIImageJPEGRepresentation(newAvatorImage, 0.6f);
                [upLoadManager putData:imageData key:[data objectForKey:@"imageName"] token:[data objectForKey:@"uploadToken"] complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp)
                 {
                     NSLog(@"%@",info);
                     if (info.error)
                     {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [SVProgressHUD showErrorWithStatus:@"上传图片失败"];
                         });
                     }
                     else
                     {
                         [[QDYHTTPClient sharedInstance]PostAvatorWithUserId:userId avatorName:[data objectForKey:@"imageName"] whenComplete:^(NSDictionary *returnData)
                          {
                              
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  if ([returnData objectForKey:@"data"])
                                  {
                                      //上传图片成功
                                     // [SVProgressHUD showInfoWithStatus:@"上传头像成功"];
                                      
                                      [[QDYHTTPClient sharedInstance]GetPersonalSimpleInfoWithUserId:userId whenComplete:^(NSDictionary *returnData) {
                                          NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                          if ([returnData objectForKey:@"data"])
                                          {
                                              User *user = [returnData objectForKey:@"data"];
                                              
                                              [userDefaults setObject:user.UserName forKey:@"userName"];
                                              [userDefaults setObject:user.avatarImageURLString forKey:@"avatarUrl"];
                                          }
                                          else
                                          {
                                              NSLog(@"更新个人信息失败");
                                          }
                                      }];
                                      
                                  }
                                  else if ([returnData objectForKey:@"error"])
                                  {
                                      [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
                                  }
                                  
                              });
                              
                              
                          }];
                         
                     }
                     
                     
                 } option:nil];
            }];
        });
        
        
        
    }];
    
}
-(void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController
{
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        //do nothing
    }];
}
#pragma mark ---UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSMutableArray *mediaTypes = [[NSMutableArray alloc]init];
    [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
    if (buttonIndex ==0)
    {
        NSLog(@"select camera");
        if ([CameraUtility isCameraAvailable] && [CameraUtility doesCameraSupportTakingPhotos])
        {
            UIImagePickerController *controller = [[UIImagePickerController alloc]init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ( [CameraUtility isFrontCameraAvailable])
            {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller animated:YES completion:^{
                NSLog(@"camera view controller is presented");
            }];
        }
    }
    else if (buttonIndex == 1)
    {
        NSLog(@"select photo library");
        if ([CameraUtility isPhotoLibraryAvailable])
        {
            UIImagePickerController *controller = [[UIImagePickerController alloc]init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller animated:YES completion:^{
                NSLog(@"picker view controller  is presented");
            }];
        }
    }
    else if (buttonIndex == 2)
    {
       
    }
}

#pragma mark ----UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *avatorImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        avatorImage = [PhotoCommon imageByScalingToMaxSize:avatorImage];
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc]initWithImage:avatorImage cropFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgCropperVC.delegate = self;
        [self presentViewController:imgCropperVC animated:YES completion:^{
            
            
            //to do
            
            
        }];
    }];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}



@end
