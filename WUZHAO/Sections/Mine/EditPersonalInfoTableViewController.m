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

#import "UIImage+Resize.h"

#import "UIImageView+WebCache.h"
#import "UIImageView+ChangeAppearance.h"
#import "UIButton+ChangeAppearance.h"
#import "SVProgressHUD.h"

#import "QDYHTTPClient.h"
#import "QiniuSDK.h"


#define ORIGINAL_MAX_WIDTH 640.0f
@interface EditPersonalInfoTableViewController ()<VPImageCropperDelegate ,UIActionSheetDelegate ,UIImagePickerControllerDelegate>

@end

@implementation EditPersonalInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTablePerform];
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editPwd"])
    {
        
    }
}

-(void)setUserInfo:(User *)userInfo
{
    if (_userInfo)
        _userInfo = [[User alloc]init];
    _userInfo = userInfo;
}

-(void)setNavigationItem
{
    self.title = @"编辑个人信息";
    //左侧取消按钮
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    //右侧保存按钮
    UIButton *save = [[UIButton alloc]init];
    save.titleLabel.text = @"完成";
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savaButtonPressed)];
    self.navigationItem.rightBarButtonItem = saveButton;
}
-(void)setTablePerform
{
    [self.avatorInfoCell.imageView sd_setImageWithURL:[NSURL URLWithString:self.userInfo.avatarImageURLString] placeholderImage:[UIImage imageNamed:@"defaultAvator"]];
    
    [self.avatorInfoCell.imageView setRoundConerWithRadius:self.avatorInfoCell.imageView.frame.size.width/2];
    
    self.nickNameCell.imageView.image = [UIImage imageNamed:@"default"];
    
    self.nickNameTextField = [[UITextField alloc]initWithFrame:CGRectMake(100, 10, 250, 30)];

    
    [self.nickNameCell addSubview:self.nickNameTextField];
    if (self.userInfo.UserName)
    {
        self.nickNameTextField.text = self.userInfo.UserName;
    }
    else
    {
        self.nickNameTextField.placeholder = @"昵称";
    }

    self.selfDescriptionCell.imageView.image = [UIImage imageNamed:@"default"];
    self.selfDescriptionTextField = [[UITextField alloc]initWithFrame:CGRectMake(100, 10, 250, 30)];
    [self.selfDescriptionCell addSubview:self.selfDescriptionTextField];
   
    self.selfDescriptionTextField.text =@"我是哈利小球";
    // [self.selfDescriptionTextField sizeToFit];
    
    self.emailCell.imageView.image = [UIImage imageNamed:@"default"];
    self.emailTextField = [[UITextField alloc]initWithFrame:CGRectMake(100, 10, 300, 30)];
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
    }
    
    
    self.changePwdCell.textLabel.text = @"修改密码";
    
    
    [self.logoutButton setBigButtonAppearance];
    [self.logoutButton setThemeBackGroundAppearance];
    [self.logoutButton setTitle:@"退出登录" forState:UIControlStateNormal];
    

    
}

-(void)cancelButtonPressed
{
    [self.tableView reloadData];
}
-(void)savaButtonPressed
{
    [SVProgressHUD showInfoWithStatus:@"数据提交中....."];
   /* User  *newUserInfo = [[User alloc]init];
    newUserInfo.UserID = self.userInfo.UserID;
    newUserInfo.avatarImageURLString = @"";
    newUserInfo.selfDescriptions = self.selfDescriptionTextField.text;
    newUserInfo.UserName = self.nickNameTextField.text;
    newUserInfo.email = self.emailTextField.text;
    newUserInfo.phoneNum = self.phoneNumTextField.text;
    
    [[AFHTTPAPIClient sharedInstance]PostPersonalInfoWithUser:newUserInfo complete:^(NSDictionary * result, NSError *error) {
        if (error)
        {
            [SVProgressHUD showErrorWithStatus:@"服务器异常"];
        }
        else
        {
            [SVProgressHUD showInfoWithStatus:@"保存成功"];
        }
    }];*/

}
- (IBAction)logOutButtonPressed:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"token"];
    UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Launch" bundle:nil];
    LaunchViewController *launchViewController = [loginStoryboard instantiateViewControllerWithIdentifier:@"launchView"];
    [self showViewController:launchViewController sender:nil];
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
        //go to set password
    }
}
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark ---VPImageCropperDelegate
-(void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage
{
    UIImage *newAvatorImage = [self imageByScalingToMaxSize:editedImage];
    self.avatorInfoCell.imageView.image = newAvatorImage;
    [self.avatorInfoCell.imageView setRoundConerWithRadius:self.avatorInfoCell.imageView.frame.size.width/2];
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        
        //TO DO
        //upload avator to the server
        //
        
        
        [[QDYHTTPClient sharedInstance]GetQiNiuTokenWithUserId:self.userInfo.UserID type:2 whenComplete:^(NSDictionary *returnData) {
            NSDictionary *data;
            if ([returnData objectForKey:@"data"])
            {
                data = [returnData objectForKey:@"data"];
                NSLog(@"%@",data);
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:@"获取token失败"];
                return ;
            }
            QNUploadManager *upLoadManager = [[QNUploadManager alloc]init];
            NSData *imageData = UIImageJPEGRepresentation(newAvatorImage, 0.6f);
            [upLoadManager putData:imageData key:[data objectForKey:@"imageName"] token:[data objectForKey:@"uploadToken"] complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp)
             {
                 NSLog(@"%@",info);
                 if (info.error)
                 {
                     [SVProgressHUD showErrorWithStatus:@"上传图片失败"];
                 }
                 else
                 {
                     [[QDYHTTPClient sharedInstance]PostAvatorWithUserId:self.userInfo.UserID avatorName:[data objectForKey:@"imageName"] whenComplete:^(NSDictionary *returnData) {
                         if ([returnData objectForKey:@"data"])
                         {
                             //上传图片成功
                         }
                         else if ([returnData objectForKey:@"error"])
                         {
                             [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
                         }
                     }];
                     
                 }
                 
                 
             } option:nil];
        }];
    
        
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
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos])
        {
            UIImagePickerController *controller = [[UIImagePickerController alloc]init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ( [self isFrontCameraAvailable])
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
        if ([self isPhotoLibraryAvailable])
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
        avatorImage = [self imageByScalingToMaxSize:avatorImage];
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

#pragma mark ----camera utility 
-(BOOL) isCameraAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
}
-(BOOL) isRearCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}
-(BOOL) isFrontCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}
-(BOOL) doesCameraSupportTakingPhotos
{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:
            UIImagePickerControllerSourceTypeCamera];
}
-(BOOL) isPhotoLibraryAvailable
{
    return  [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
}
-(BOOL) canUserPickPhotosFromPhotoLibrary
{
    return  [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
-(BOOL) canUserPickMovieFromPhotoLibrary
{
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeVideo sourceType:UIImagePickerControllerSourceTypePhotoLibrary ];
}

-(BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType
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



#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
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
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
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