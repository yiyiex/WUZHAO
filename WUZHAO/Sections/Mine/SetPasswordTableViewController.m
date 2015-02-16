//
//  SetPasswordTableViewController.m
//  WUZHAO
//
//  Created by yiyi on 15-1-21.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "SetPasswordTableViewController.h"
#import "AFHTTPAPIClient.h"
#import  "SVProgressHUD.h"

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
    self.myOldPwdCell.imageView.image = [UIImage imageNamed:@"defaultAvator"];
    self.myOldPwdTextField =  [[UITextField alloc]initWithFrame:CGRectMake(100, 10, 250, 30)];

    self.myOldPwdTextField.placeholder = @"当前密码";
    [self.myOldPwdCell addSubview:self.myOldPwdTextField];
    
    self.myNewPwdCell.imageView.image = [UIImage imageNamed:@"defaultAvator"];
    self.myNewPwdTextField =  [[UITextField alloc]initWithFrame:CGRectMake(100, 10, 250, 30)];

    self.myNewPwdTextField.placeholder = @"新密码";
    [self.myNewPwdCell addSubview:self.myNewPwdTextField];
    
    self.comfirmPwdCell.imageView.image = [UIImage imageNamed:@"defaultAvator"];
    self.comfirmPwdTextField =  [[UITextField alloc]initWithFrame:CGRectMake(100, 10, 250, 30)];

    self.comfirmPwdTextField.placeholder = @"再次输入新密码";
    [self.comfirmPwdCell addSubview:self.comfirmPwdTextField];
    
}
-(void)canButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)saveButtonPressed
{
    NSInteger userId = [[NSUserDefaults standardUserDefaults] integerForKey:@"userId"];
   // NSDictionary *result = [[AFHTTPAPIClient sharedInstance ]UpdatePwdWithUserId:(NSInteger)userId password:self.myOldPwdTextField.text newpassword:self.myNewPwdTextField.text];
    //if ([result objectForKey:@"data"])
   // {

   // }
 
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
