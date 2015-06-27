//
//  SetPasswordTableViewController.m
//  WUZHAO
//
//  Created by yiyi on 15-1-21.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "SetPasswordTableViewController.h"
#import "QDYHTTPClient.h"
#import "SVProgressHUD.h"
#import "NSString+SHA1WithSalt.h"
#import "NSString+Verify.h"
#import "macro.h"

@interface SetPasswordTableViewController ()

@end

@implementation SetPasswordTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationItem];
    [self setTablePerform];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setNavigationItem
{
    self.title = @"设置密码";
    //左侧取消按钮
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(canButtonPressed)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    //右侧保存按钮
    UIButton *save = [[UIButton alloc]init];
    save.titleLabel.text =@"完成";
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
    self.navigationItem.rightBarButtonItem = saveButton;
}
-(void)setTablePerform
{
    self.myOldPwdTextField =  [[UITextField alloc]initWithFrame:CGRectMake(60, 10, WZ_APP_SIZE.width-68, 30)];
    [self.myOldPwdTextField setSecureTextEntry:YES];
    self.myOldPwdTextField.placeholder = @"当前密码";
    [self.myOldPwdTextField setFont:WZ_FONT_COMMON_SIZE];
    [self.myOldPwdCell addSubview:self.myOldPwdTextField];
    
    self.myNewPwdTextField =  [[UITextField alloc]initWithFrame:CGRectMake(60, 10, WZ_APP_SIZE.width-68, 30)];
    [self.myNewPwdTextField setSecureTextEntry:YES];
    self.myNewPwdTextField.placeholder = @"新密码";
    [self.myNewPwdTextField setFont:WZ_FONT_COMMON_SIZE];
    [self.myNewPwdCell addSubview:self.myNewPwdTextField];
    
    self.comfirmPwdTextField =  [[UITextField alloc]initWithFrame:CGRectMake(60, 10, WZ_APP_SIZE.width-68, 30)];
    [self.comfirmPwdTextField setSecureTextEntry:YES];
    self.comfirmPwdTextField.placeholder = @"再次输入新密码";
    [self.comfirmPwdTextField setFont:WZ_FONT_COMMON_SIZE];
    [self.comfirmPwdCell addSubview:self.comfirmPwdTextField];
    
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
-(void)canButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)saveButtonPressed
{

    if ([self.myOldPwdTextField.text isEqualToString:@""])
    {
        [SVProgressHUD showErrorWithStatus:@"请输入旧密码"];
        return;
    }
    if ([self.myNewPwdTextField.text isEqualToString:@""])
    {
        [SVProgressHUD showErrorWithStatus:@"请输入新密码"];
        return;
    }
    if ([self.comfirmPwdTextField.text isEqualToString:@""])
    {
        [SVProgressHUD showErrorWithStatus:@"请输入确认密码"];
        return;
    }
    if (![self.myNewPwdTextField.text isEqualToString:self.comfirmPwdTextField.text])
    {
        [SVProgressHUD showErrorWithStatus:@"两次输入的新密码不匹配"];
        return;
    }
    NSInteger userId = [[NSUserDefaults standardUserDefaults] integerForKey:@"userId"];
    NSString *oldPwd = self.myOldPwdTextField.text;
    NSString *newPwd = self.myNewPwdTextField.text;
    if (! [newPwd isValidPassword])
    {
        [SVProgressHUD showInfoWithStatus:@"新密码位数至少为6位"];
        return;
    }
    NSString *oldSPwd = [oldPwd SHA1];
    NSString *newSPwd = [newPwd SHA1];
    [[QDYHTTPClient sharedInstance]UpdatePwdWithUserId:userId password:oldSPwd newpassword:newSPwd whenComplete:^(NSDictionary *returnData) {
        if ([returnData objectForKey:@"data"])
        {
            [SVProgressHUD showSuccessWithStatus:@"更新密码成功"];
            sleep(1);
            [self.navigationController popViewControllerAnimated:YES];
            //[[NSNotificationCenter defaultCenter]postNotificationName:@"setPassword" object:nil];
        }
        else if ([returnData objectForKey:@"error"])
        {
            [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
        }
    }];

 
}
#pragma mark -touch 
-(void)resignFirstResponderOfView:(UIView *)view
{
    if ( [self.myOldPwdTextField isFirstResponder])
    {
        [self.myOldPwdTextField resignFirstResponder];
    }
    if ( [self.myNewPwdTextField isFirstResponder])
    {
        [self.myNewPwdTextField resignFirstResponder];
    }
    if ( [self.comfirmPwdTextField isFirstResponder])
    {
        [self.comfirmPwdTextField resignFirstResponder];
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
