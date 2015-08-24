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
@property (nonatomic, strong) IBOutlet PlaceholderTextView *feedbackContent;
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
    [self.view setBackgroundColor:[UIColor colorWithRed:238 green:238 blue:238 alpha:1.0]];
    float feedbackContentHeight = 80;
    
    //self.feedbackContent = [[PlaceholderTextView alloc]initWithFrame:CGRectMake(24,88, WZ_APP_SIZE.width-48,feedbackContentHeight)];
    //[self.feedbackContent setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    [self.feedbackContent.layer setBorderColor:[THEME_COLOR_DARK_BIT_PARENT CGColor]];
    [self.feedbackContent.layer setBorderWidth:0.8f];
    self.feedbackContent.placeholder = @" 请您填写您对Place的意见和建议";
    self.feedbackContent.placeholderFont = WZ_FONT_COMMON_SIZE;
    [self.feedbackContent setFont:WZ_FONT_COMMON_SIZE];

    [self.feedbackContent becomeFirstResponder];
    [self.feedbackContent setDelegate:self];
    //[self.view addSubview:self.feedbackContent];
    //[self.feedbackContent setContentSize:CGSizeMake(self.feedbackContent.frame.size.width, feedbackContentHeight)];
    
    float contactHeight = 40;
    self.contact = [[UITextField alloc]initWithFrame:CGRectMake(24,88 + feedbackContentHeight +22, WZ_APP_SIZE.width-48,contactHeight)];
    self.contact.placeholder = @" 手机/邮箱/QQ(选填)";
    [self.contact setFont:WZ_FONT_COMMON_SIZE];
    //[self.contact setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    [self.contact.layer setBorderColor:[THEME_COLOR_DARK_BIT_PARENT CGColor]];
    [self.contact.layer setBorderWidth:0.8f];
    [self.view addSubview:self.contact];
    
    self.sendButton = [[UIButton alloc]initWithFrame:CGRectMake(24, 88 + feedbackContentHeight + 22 + contactHeight +22, WZ_APP_SIZE.width-48, 42)];
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendButton setThemeFrameAppearence];
    [self.sendButton setBigButtonAppearance];
    [self.sendButton addTarget:self action:@selector(sendFeedBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sendButton];
    
    if (!self.navigationController)
    {
        UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 28, 64, 32)];
        //[cancelButton setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(canButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setTitleColor:THEME_COLOR_DARK forState:UIControlStateNormal];
        [cancelButton.titleLabel setFont:WZ_FONT_HIRAGINO_SIZE_16];
        [self.view addSubview:cancelButton];
    }
    
}
-(void)canButtonPressed
{
    if ([self.feedbackContent isFirstResponder])
    {
        [self.feedbackContent resignFirstResponder];
    }
    if ([self.contact isFirstResponder])
    {
        [self.contact resignFirstResponder];
    }
    if (self.navigationController)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
            [SVProgressHUD showSuccessWithStatus:@"反馈成功，我们会及时跟进的哦"];
            double delaysInSecond = 2;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)delaysInSecond * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^{
               [self canButtonPressed];
            }) ;
           
           // [self.navigationController popViewControllerAnimated:YES];
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

