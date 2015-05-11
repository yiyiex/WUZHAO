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
#pragma mark - Table view data source


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

@end
