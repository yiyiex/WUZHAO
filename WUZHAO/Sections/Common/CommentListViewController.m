//
//  CommentListViewController.m
//  WUZHAO
//
//  Created by yiyi on 15-1-9.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//
#import "macro.h"

#import "CommentListViewController.h"
#import "CommentTableViewCell.h"
#import "CommonContainerViewController.h"
#import "UIImageView+WebCache.h"
#import "UIButton+ChangeAppearance.h"

#import "DAKeyboardControl.h"
#define SEGUEFIRST @"showCommentList"
@interface CommentListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *commentListTableView; //展示评论列表
@property (nonatomic,strong) UIToolbar *toolbar;  //发表评论工具栏
@property (nonatomic,strong) UITextField *commentTextField;  //评论输入框
@property (nonatomic,strong) UIButton *sendButton;  //发表按钮
@end

@implementation CommentListViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"评论列表";
    
    [self addCommentListTableView];
    [self addToolBar];
    [self setKeyboard];
    
    [self.commentListTableView setEstimatedRowHeight:80];
    
    self.commentListTableView.rowHeight = UITableViewAutomaticDimension;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray *)commentList
{
    if (!_commentList)
    {
        _commentList = [[NSArray alloc]init];
    }
    return _commentList;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    
}
#pragma mark - draw the compoment
//绘制评论列表 commentListTableView
-(void)addCommentListTableView
{
    if (!_commentListTableView)
    {
        _commentListTableView = [[UITableView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height-40)];
        _commentListTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_commentListTableView setEstimatedRowHeight:60.0f];
        _commentListTableView.rowHeight = UITableViewAutomaticDimension;
        [_commentListTableView registerClass:[CommentTableViewCell class] forCellReuseIdentifier:@"commentTableCell"];
        [_commentListTableView setDelegate:self];
        [_commentListTableView setDataSource:self];
        [self.view addSubview:_commentListTableView];
    }
}

//绘制评论发表工具栏
-(void)addToolBar
{
    if (!_toolbar)
    {
    
        _toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0.0f,WZ_DEVICE_BOUNDS.size.height-40.0f , WZ_DEVICE_BOUNDS.size.width,40.f )];
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleWidth;
    
        [self.view addSubview:_toolbar];
        [self setToolbar:_toolbar];
    
        _commentTextField = [[UITextField alloc]initWithFrame:CGRectMake(10.0f, 6.0f, _toolbar.bounds.size.width-20.0f-68.0f, 30.0f)];
        _commentTextField.borderStyle = UITextBorderStyleRoundedRect;
        _commentTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_toolbar addSubview:_commentTextField];
        [self setCommentTextField:_commentTextField];
        
        _sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton setNormalButtonAppearance];
        _sendButton.frame = CGRectMake(_toolbar.bounds.size.width - 68.0f,
                                  6.0f,
                                  58.0f,
                                  29.0f);
        [_toolbar addSubview:_sendButton];
        [_sendButton setThemeBackGroundAppearance];
        [_sendButton addTarget:self action:@selector(sendComment:) forControlEvents:UIControlEventTouchUpInside];
        
        [self setSendButton:_sendButton];
    }
    
}

//安装可隐藏和显示的键盘
-(void)setKeyboard
{
    self.view.keyboardTriggerOffset = self.toolbar.bounds.size.height;
    
    WEAKSELF_WZ
    [self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
        /*
         Try not to call "self" inside this block (retain cycle).
         But if you do, make sure to remove DAKeyboardControl
         when you are done with the view controller by calling:
         [self.view removeKeyboardControl];
         */
        
        CGRect toolBarFrame = weakSelf_WZ.toolbar.frame;
        toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
        weakSelf_WZ.toolbar.frame = toolBarFrame;
        
        
        CGRect tableViewFrame = weakSelf_WZ.commentListTableView.frame;
        tableViewFrame.size.height = toolBarFrame.origin.y ;
        weakSelf_WZ.commentListTableView.frame = tableViewFrame;
        
                
    }];
}

#pragma mark -  action
-(void)sendComment:(id)sender
{
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark -------UITableView delegate--------
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellData = [self.commentList objectAtIndex:indexPath.row];
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentTableCell" forIndexPath:indexPath];
    if (!cell)
    {
        cell = [[CommentTableViewCell alloc]init];
    }

    [cell.userAvatorView sd_setImageWithURL:[NSURL URLWithString:[cellData objectForKey:@"avatorUrl"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cell.userName.text = [cellData objectForKey:@"username"];
    cell.commentContent.text = [cellData objectForKey:@"content"];
    cell.commentTime.text =  [cellData objectForKey:@"time"];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%@",self.commentList);
    NSLog(@"%@",self.commentListTableView);
    return self.commentList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

@end
