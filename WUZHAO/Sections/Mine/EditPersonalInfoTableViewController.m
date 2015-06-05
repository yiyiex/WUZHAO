//
//  EditPersonalInfoTableViewController.m
//  WUZHAO
//
//  Created by yiyi on 15-1-19.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "EditPersonalInfoTableViewController.h"
#import "LaunchViewController.h"

#import "VPImageCropperViewController.h"

#import "SetPasswordTableViewController.h"
#import "FeedbackViewController.h"

#import "UIImage+Resize.h"
#import "PhotoCommon.h"
#import "CameraUtility.h"

#import "UIImageView+WebCache.h"
#import "UIImageView+ChangeAppearance.h"
#import "UILabel+ChangeAppearance.h"
#import "UIButton+ChangeAppearance.h"
#import "SVProgressHUD.h"

#import "NSString+Verify.h"

#import "QDYHTTPClient.h"
#import "QiniuSDK.h"
#import "macro.h"


#define ORIGINAL_MAX_WIDTH 640.0f
@interface EditPersonalInfoTableViewController ()<VPImageCropperDelegate ,UIActionSheetDelegate ,UIImagePickerControllerDelegate>

@end

@implementation EditPersonalInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self setNavigationItem];
    
    
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUserInfo:(User *)userInfo
{
    if (_userInfo)
        _userInfo = [[User alloc]init];
    _userInfo = userInfo;
}

-(void)setNavigationItem
{
    //[self.navigationController setNavigationBarHidden:NO];
    self.title = @"编辑个人信息";
    //左侧取消按钮
    //UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    //self.navigationItem.leftBarButtonItem = cancelButton;
    //右侧保存按钮
    UIButton *save = [[UIButton alloc]init];
    save.titleLabel.text = @"完成";
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savaButtonPressed)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarItem;
}
-(void)initView
{
    //头像区
    [self.avatarImageView setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.userInfo.avatarImageURLString]];
    [self.avatarImageView setRoundConerWithRadius:self.avatarImageView.frame.size.width/2];
    
    //基本信息区
   // self.nickNameCell.imageView.image = [UIImage imageNamed:@"default"];
    UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(12, 10, 40, 30)];
    name.text = @"名字";
    [name setDarkGreyLabelAppearance];
    [self.nickNameCell addSubview:name];
    self.nickNameTextField = [[UITextField alloc]initWithFrame:CGRectMake(60, 10, WZ_APP_SIZE.width-68, 30)];
    //[self.nickNameTextField setFont:WZ_FONT_COMMON_SIZE];
    [self.nickNameCell addSubview:self.nickNameTextField];
    //self.nickNameTextView = [[UITextView alloc]initWithFrame:CGRectMake(80,10, WZ_APP_SIZE.width-90, 28)];
    if ([self.userInfo.UserName isEqualToString:@""])
    {
        self.nickNameTextField.placeholder = @"输入名字";
    }
    else
    {
        self.nickNameTextField.text = self.userInfo.UserName;
    }

    UILabel *jianjie = [[UILabel alloc]initWithFrame:CGRectMake(12, 10, 40, 30)];
    jianjie.text = @"简介";
    [jianjie setDarkGreyLabelAppearance];
    [self.selfDescriptionCell addSubview:jianjie];
    //self.selfDescriptionCell.imageView.image = [UIImage imageNamed:@"default"];
    self.selfDescriptionTextView = [[PlaceholderTextView alloc]initWithFrame:CGRectMake(60, 8, WZ_APP_SIZE.width-68, 70)];
    [self.selfDescriptionTextView setFont:WZ_FONT_COMMON_SIZE];
    [self.selfDescriptionCell addSubview:self.selfDescriptionTextView];
    [self.selfDescriptionCell sizeToFit];
    if ([self.userInfo.selfDescriptions isEqualToString:@""])
    {
        self.selfDescriptionTextView.placeholder = @"输入个人简介";
       // self.selfDescriptionTextView.placeholder = @"个人简介";
    }
    else
    {
        self.selfDescriptionTextView.text = self.userInfo.selfDescriptions;
    }
    

    
    // [self.selfDescriptionTextField sizeToFit];
    /*
    self.emailCell.imageView.image = [UIImage imageNamed:@"default"];
    self.emailTextField = [[UITextField alloc]initWithFrame:CGRectMake(100, 10, 300, 30)];
    [self.emailTextField setFont:WZ_FONT_COMMON_SIZE];
    [self.emailCell addSubview:self.emailTextField];
    if (self.userInfo.email)
    {
        self.emailTextField.text = self.userInfo.email;
    }
    else
    {
        self.emailTextField.placeholder = @"邮箱";
    }
    
    self.phoneNumCell.imageView.image = [UIImage imageNamed:@"default"];
    self.phoneNumTextField = [[UITextField alloc]initWithFrame:CGRectMake(100, 10, 200, 30)];
    [self.phoneNumCell addSubview:self.phoneNumTextField];
    if (self.userInfo.phoneNum)
    {
        self.phoneNumTextField.text = self.userInfo.phoneNum;
    }
    else
    {
        self.phoneNumTextField.placeholder = @"手机";
    }*/
    
    //修改密码区
    [self.changePwdCell.textLabel setFont:WZ_FONT_COMMON_SIZE];
    self.changePwdCell.textLabel.text = @"修改密码";
    
    //吐槽区
    [self.feedBackCell.textLabel setFont:WZ_FONT_COMMON_SIZE];
    self.feedBackCell.textLabel.text = @"我要吐槽";
    
    
    //退出区
    [self.logoutCell setBackgroundColor:[UIColor whiteColor]];
    self.logoutCell.textLabel.text = @"退 出";
    self.logoutCell.textLabel.textAlignment = NSTextAlignmentCenter;
    [self.logoutCell.textLabel setFont:WZ_FONT_LARGE_BOLD_SIZE];
    [self.logoutCell.textLabel setTextColor:THEME_COLOR_DARK];
    
    
    //gesture
    [self.changePwdCell setUserInteractionEnabled:YES];
    UITapGestureRecognizer *passwordCellClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(passwordCellClick:)];
    [self.changePwdCell addGestureRecognizer:passwordCellClick];
    
    [self.feedBackCell setUserInteractionEnabled:YES];
    UITapGestureRecognizer *feedbackCellClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(feedbackCellClick:)];
    [self.feedBackCell addGestureRecognizer:feedbackCellClick];
    
    [self.logoutCell setUserInteractionEnabled:YES];
    UITapGestureRecognizer *logoutCellClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(logoutCellClick:)];
    [self.logoutCell addGestureRecognizer:logoutCellClick];
    
    [self.tableView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tableviewTouch:)];
    [self.tableView addGestureRecognizer:tapGesture];
    UISwipeGestureRecognizer *swipDownGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(tableviewSwipeDown:)];
    [swipDownGesture setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.tableView addGestureRecognizer:swipDownGesture];
    UISwipeGestureRecognizer *swipUpGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(tableviewSwipeUp:)];
    [swipUpGesture setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.tableView addGestureRecognizer:swipUpGesture];
    


    

    
}

-(void)cancelButtonPressed
{
    [self.tableView reloadData];
}
-(void)savaButtonPressed
{
    if ([self.nickNameTextField.text isEqualToString:@""])
    {
        [SVProgressHUD showInfoWithStatus:@"请输入名字"];
        return;
    }
    if (![self.nickNameTextField.text isValidUsername])
    {
        [SVProgressHUD showInfoWithStatus:@"名字只可包含字母、汉子以及下划线"];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"数据提交中..."];
    
    User  *newUserInfo = [[User alloc]init];
    newUserInfo.UserID = self.userInfo.UserID;
    newUserInfo.avatarImageURLString = @"";
    newUserInfo.selfDescriptions = self.selfDescriptionTextView.text;
    newUserInfo.UserName = self.nickNameTextField.text;
    [[QDYHTTPClient sharedInstance]UpdatePersonalInfoWithUser:newUserInfo oldNick:self.userInfo.UserName whenComplete:^(NSDictionary *returnData) {
        if ([returnData objectForKey:@"data"])
        {
            [SVProgressHUD showSuccessWithStatus:@"更新个人信息成功"];
            self.userInfo.UserName = newUserInfo.UserName;
            self.userInfo.selfDescriptions = newUserInfo.selfDescriptions;
        }
        else if ([returnData objectForKey:@"error"])
        {
            [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
        }
    }];
    
   

}
- (void)logout
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"logOut" object:nil];

}

-(void)editAvator
{
    UIActionSheet *choiceSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册中选取", nil];
    [choiceSheet showInView:self.view];
    
}
#pragma mark - Table view data source

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section ==0 && indexPath.row == 0)
    {
        NSLog(@"selected the row avator");
        [self editAvator];
    
    }

    if (indexPath.section == 2)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
        SetPasswordTableViewController *setPasswordController = [storyboard instantiateViewControllerWithIdentifier:@"setPassword"];
        [self.navigationController pushViewController:setPasswordController animated:YES];
    }
    if (indexPath.section == 3)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
        FeedbackViewController *feedbackController = [storyboard instantiateViewControllerWithIdentifier:@"feedback"];
        [self.navigationController pushViewController:feedbackController animated:YES];
    }
    
    else if (indexPath.section == 4)
    {
        [self logout];
    }
    
}


#pragma mark ---VPImageCropperDelegate
-(void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage
{
    UIImage *newAvatorImage = [PhotoCommon imageByScalingToMaxSize:editedImage];
    self.avatarImageView.image = newAvatorImage;
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[QDYHTTPClient sharedInstance]GetQiNiuTokenWithUserId:self.userInfo.UserID type:2 whenComplete:^(NSDictionary *returnData) {
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
                         [[QDYHTTPClient sharedInstance]PostAvatorWithUserId:self.userInfo.UserID avatorName:[data objectForKey:@"imageName"] whenComplete:^(NSDictionary *returnData)
                         {
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 if ([returnData objectForKey:@"data"])
                                 {
                                     //上传图片成功
                                         [SVProgressHUD showInfoWithStatus:@"上传头像成功"];
                                         
                                         [[QDYHTTPClient sharedInstance]GetPersonalSimpleInfoWithUserId:self.userInfo.UserID whenComplete:^(NSDictionary *returnData) {
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
        [self.tableView reloadData];
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

#pragma mark - touches delegate
-(void)resignFirstResponderOfView:(UIView *)view
{
    if ([self.nickNameTextField isFirstResponder])
    {
        [self.nickNameTextField resignFirstResponder];
    }
    if ([self.selfDescriptionTextView isFirstResponder])
    {
        [self.selfDescriptionTextView resignFirstResponder];
    }
    
}
-(void)passwordCellClick:(UIGestureRecognizer *)gesture
{
    UIView *view = gesture.view;
    if (view == self.changePwdCell)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
        SetPasswordTableViewController *setPasswordController = [storyboard instantiateViewControllerWithIdentifier:@"setPassword"];
        [self.navigationController pushViewController:setPasswordController animated:YES];
    }
}
-(void)feedbackCellClick:(UIGestureRecognizer *)gesture
{
    UIView *view = gesture.view;
    if (view == self.feedBackCell)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
        FeedbackViewController *feedbackController = [storyboard instantiateViewControllerWithIdentifier:@"feedback"];
        [self.navigationController pushViewController:feedbackController animated:YES];
    }
    
}
-(void)logoutCellClick:(UIGestureRecognizer *)gesture
{
    UIView *view = gesture.view;
    if (view == self.logoutCell)
    {
        [self logout];
    }
}



-(void)tableviewTouch:(UIGestureRecognizer *)gesture
{
    UIView *view = gesture.view;
    [self resignFirstResponderOfView:view];
}
-(void)tableviewSwipeDown:(UIGestureRecognizer *)gesture
{
    [self resignFirstResponderOfView:self.view];
}
-(void)tableviewSwipeUp:(UIGestureRecognizer *)gesture
{
    [self resignFirstResponderOfView:self.view];
}








@end