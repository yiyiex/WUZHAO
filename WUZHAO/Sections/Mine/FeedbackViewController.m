//
//  FeedbackViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/4/15.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "FeedbackViewController.h"
#import "PlaceholderTextView.h"
#import "QDYHTTPClient.h"

#import "UIButton+ChangeAppearance.h"
#import "SVProgressHUD.h"
#import "macro.h"

@interface FeedbackViewController ()<UITextViewDelegate>
@property (nonatomic, strong) PlaceholderTextView *feedbackContent;
@property (nonatomic, strong) UITextField *contact;
@property (nonatomic, strong) UIButton *sendButton;
@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationItem];
    [self initView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setNavigationItem
{
    self.title = @"用户反馈";
    //左侧取消按钮
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(canButtonPressed)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    /*
    //右侧保存按钮
    UIButton *save = [[UIButton alloc]init];
    save.titleLabel.text =@"完成";
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
    self.navigationItem.rightBarButtonItem = saveButton;*/
}
-(void)initView
{
    float feedbackContentHeight = 80;
    self.feedbackContent = [[PlaceholderTextView alloc]initWithFrame:CGRectMake(10,80, WZ_APP_SIZE.width-20,feedbackContentHeight)];
    [self.feedbackContent setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    self.feedbackContent.placeholder = @"请您填写您对Place的意见和建议";
    self.feedbackContent.placeholderFont = WZ_FONT_COMMON_SIZE;
    [self.feedbackContent setFont:WZ_FONT_COMMON_SIZE];
    [self.feedbackContent becomeFirstResponder];
    [self.feedbackContent setDelegate:self];
    [self.view addSubview:self.feedbackContent];
    
    float contactHeight = 40;
    self.contact = [[UITextField alloc]initWithFrame:CGRectMake(10,80 + feedbackContentHeight +20, WZ_APP_SIZE.width-20,contactHeight)];
    self.contact.placeholder = @"手机/邮箱/QQ(选填)";
    [self.contact setFont:WZ_FONT_COMMON_SIZE];
    [self.contact setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    [self.view addSubview:self.contact];
    
    self.sendButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 80 + feedbackContentHeight + 20 + contactHeight +20, WZ_APP_SIZE.width-20, 42)];
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendButton setThemeBackGroundAppearance];
    [self.sendButton setBigButtonAppearance];
    [self.sendButton addTarget:self action:@selector(sendFeedBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sendButton];
    
}
-(void)canButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)sendFeedBack:(UIButton *)sender
{
    
    //TO DO
    //提交反馈
    if ([self.feedbackContent.text isEqualToString:@""])
    {
        [SVProgressHUD showInfoWithStatus:@"请输入反馈信息"];
        return;
    }
    NSString *feedBack = self.feedbackContent.text;
    NSString *contact = self.contact.text;
    NSInteger userId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    [[QDYHTTPClient sharedInstance]feedBackWithUserId:userId content:feedBack contact:contact whenComplete:^(NSDictionary *returnData) {
        if ([returnData objectForKey:@"data"])
        {
            [SVProgressHUD showInfoWithStatus:@"反馈成功"];
            sleep(1);
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
        }
    }];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![self.feedbackContent isExclusiveTouch])
    {
        [self.feedbackContent resignFirstResponder];
    }
    if (![self.contact isExclusiveTouch])
    {
        [self.contact resignFirstResponder];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

