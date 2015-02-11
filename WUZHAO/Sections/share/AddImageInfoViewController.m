//
//  AddImageInfoViewController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-21.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "AddImageInfoViewController.h"
#import "AddressInfoList.h"

#import "AFHTTPAPIClient.h"
#import "SVProgressHUD.h"

#import "QiniuSDK.h"

@interface AddImageInfoViewController()
@property (nonatomic ,strong)  NSArray *addressDataSource;

@property (atomic) float progress;
@end

@implementation AddImageInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = NO;
    self.postImageView.image = self.postImage;
    [self.addressTableView reloadData];
}
#pragma mark =================datas===================
- (NSArray *) addressDataSource
{
    if (!_addressDataSource)
    {
        _addressDataSource = [[AddressInfoList newDataSource] mutableCopy];
    }
    return _addressDataSource;
}

-(UIImageView *)postImageView
{
    if (_postImage)
    {
        _postImageView.image = _postImage;
    }
    return _postImageView;
}

-(WhatsGoingOn *)whatsGoingOnItem
{
    if (!_whatsGoingOnItem)
    {
        _whatsGoingOnItem = [[WhatsGoingOn alloc]init];
    }
    return _whatsGoingOnItem;
}

#pragma mark ==============buttons

-(void)PostButtonPressed:(UIBarButtonItem *)sender
{
    
    if(self.postImageDescription.text)
    {
        self.whatsGoingOnItem.imageDescription = self.postImageDescription.text;
    }
    self.whatsGoingOnItem.imageUrlString = @"";
    self.whatsGoingOnItem.likeCount = 0;
    self.whatsGoingOnItem.comment = @"";
    //self.whatsGoingOnItem.photoUser =
    [self.postImageDescription resignFirstResponder];
    //发布照片信息,上传到七牛;上传成功后提示并转回主页
    [self uploadPhotoToQiNiu];

    //[[[UIAlertView alloc] initWithTitle:@"info" message:@"发布成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
 
    
}


-(void)uploadPhotoToQiNiu
{
    
    //获取token和filename请求
    [SVProgressHUD showWithStatus:@"图片上传中..."];
    NSInteger userId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    [[AFHTTPAPIClient sharedInstance] GetQiNiuTokenWithUserId:userId whenComplete:^(NSDictionary *result) {
        NSDictionary *data;
        if ([result objectForKey:@"data"])
        {
            data = [result objectForKey:@"data"];
            NSLog(@"%@",data);
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"获取token失败"];
        }
        QNUploadManager *upLoadManager = [[QNUploadManager alloc]init];
        NSData *imageData = UIImageJPEGRepresentation(self.postImage, 1.0f);
        [upLoadManager putData:imageData key:[data objectForKey:@"imageName"] token:[data objectForKey:@"uploadToken"] complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
            
            NSLog(@"%@",info);
            if (info.error)
            {
                [SVProgressHUD showErrorWithStatus:@"上传图片失败"];
            }
            else
            {
                //用户端提示
                
                [[AFHTTPAPIClient sharedInstance]PostPhotoInfomationWithUserId:userId photo:(NSString *)[data objectForKey:@"imageName"] thought:@"this is my first photo!" whenComplete:^(NSDictionary *returnData) {
                    if (returnData)
                    {
                        [SVProgressHUD showSuccessWithStatus:@"上传图片成功"];
                    }
                    else
                    {
                        [SVProgressHUD showErrorWithStatus:@"上传图片失败"];
                    }
                    
                    NSLog(@"%lu",(unsigned long)[self.navigationController.viewControllers count]);
                    
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"finishPostImage" object:nil];
                    
                    //通知服务器并补充信息
                    //....

                }];
                
            }
            
            
        } option:nil];
    }];
   
}


#pragma mark -------------dataformat

- (NSString *)getDateTimeString
{
    NSDateFormatter *formatter;
    NSString        *dateString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss"];
    
    dateString = [formatter stringFromDate:[NSDate date]];
    
    return dateString;
}


- (NSString *)randomStringWithLength:(int)len
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int)[letters length])]];
    }
    
    return randomString;
}
/*
#pragma mark ===============alert delegate====================
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{

    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishPostImage" object:nil];
    [self.navigationController popViewControllerAnimated:YES];

    
}*/

#pragma mark ==============tableview delegate===================

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.addressDataSource.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addressInfoCell" forIndexPath:indexPath];
    cell.textLabel.text = [self.addressDataSource objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.whatsGoingOnItem.adddresMark = [self.addressDataSource objectAtIndex:indexPath.row];
    self.whatsGoingOnItem.imageDescription = @"";
    self.addressInfoLabel.text = [NSString stringWithFormat:@"you chooese : %@",self.whatsGoingOnItem.adddresMark];
    
    
}

#pragma mark ================textview delegate====================
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![self.postImageDescription isExclusiveTouch])
    {
        self.whatsGoingOnItem.imageDescription = self.postImageDescription.text;
        [self.postImageDescription resignFirstResponder];
    }
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

@end
