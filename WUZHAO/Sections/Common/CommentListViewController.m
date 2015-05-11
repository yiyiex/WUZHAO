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

#import "QDYHTTPClient.h"

#import "DAKeyboardControl.h"
#import "SVProgressHUD.h"
#define SEGUEFIRST @"showCommentList"
@interface CommentListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *commentListTableView; //展示评论列表
@property (nonatomic,strong) UIToolbar *toolbar;  //发表评论工具栏
@property (nonatomic,strong) UITextField *commentTextField;  //评论输入框
@property (nonatomic,strong) UIButton *sendButton;  //发表按钮
@property (nonatomic,strong) CommentTableViewCell *prototypeCell;
@end

@implementation CommentListViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarItem;
    
    self.navigationItem.title = @"评论列表";
    [self addCommentListTableView];
    [self addToolBar];
    //[self setKeyboard];
    [self getLatestCommentList];
    
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setKeyboard];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.view removeKeyboardControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray *)commentList
{
    if (!_commentList)
    {
        _commentList = [[NSMutableArray alloc]init];
    }
    return _commentList;
}
- (CommentTableViewCell *)prototypeCell
{
    if (!_prototypeCell) {
        _prototypeCell = [self.commentListTableView dequeueReusableCellWithIdentifier:NSStringFromClass([CommentTableViewCell class])];
    }
    return _prototypeCell;
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
       // _commentListTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_commentListTableView setEstimatedRowHeight:40.0f];
        _commentListTableView.rowHeight = UITableViewAutomaticDimension;
        [_commentListTableView registerNib:[UINib nibWithNibName:@"CommentListTableViewCell" bundle:nil] forCellReuseIdentifier:@"commentTableCell"];
      //  [_commentListTableView registerClass:[CommentTableViewCell class] forCellReuseIdentifier:@"commentTableCell"];
        [_commentListTableView setDelegate:self];
        [_commentListTableView setDataSource:self];
        [_commentListTableView setSectionIndexBackgroundColor:[UIColor clearColor]];
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
        _commentTextField.placeholder = @"输入评论内容...";
        [_commentTextField setFont:WZ_FONT_COMMON_SIZE];
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
        __strong typeof (weakSelf_WZ)strongSelf = weakSelf_WZ;
        CGRect toolBarFrame = strongSelf.toolbar.frame;
        toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
        strongSelf.toolbar.frame = toolBarFrame;
        
        
        CGRect tableViewFrame = strongSelf.commentListTableView.frame;
        tableViewFrame.size.height = toolBarFrame.origin.y ;
        strongSelf.commentListTableView.frame = tableViewFrame;
        
                
    }];
}

#pragma mark -  action
-(void)sendComment:(id)sender
{
    NSString *commentContent = self.commentTextField.text;
    if ([commentContent isEqualToString:@""])
    {
        return;
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSInteger userId = [userDefault integerForKey:@"userId"];
    NSString *userName = [userDefault objectForKey:@"userName"];
    NSString *avatarUrl = [userDefault objectForKey:@"avatarUrl"];
    NSInteger postId = self.poiItem.postId;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[QDYHTTPClient sharedInstance]CommentPhotoWithUserId:userId postId:postId comment:commentContent whenComplete:^(NSDictionary *returnData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([returnData objectForKey:@"data"])
                {
                    [SVProgressHUD showInfoWithStatus:@"评论成功"];
                    self.commentTextField.text = @"";
                    //更新主页显示内容
                    NSString *commentString;
                    NSMutableDictionary *myCommentItem = [[NSMutableDictionary alloc]init];
                    [myCommentItem setObject:commentContent forKey:@"content"];
                    [myCommentItem setObject:[returnData objectForKey:@"data"]  forKey:@"commentId"];
                    [myCommentItem setObject:@"刚刚" forKey:@"time"];
                    [myCommentItem setObject:[NSNumber numberWithInteger:postId] forKey:@"postId"];
                    [myCommentItem setObject:userName forKey:@"userName"];
                    [myCommentItem setObject:[NSNumber numberWithInteger:userId] forKey:@"userId"];
                    [myCommentItem setObject:avatarUrl forKey:@"avatarUrl"];
                    commentString =[NSString stringWithFormat:@"%@: %@",[myCommentItem objectForKey:@"userName"],[myCommentItem objectForKey:@"content"]];
                    NSMutableArray *newpoiCommentList = [NSMutableArray arrayWithArray:self.poiItem.commentList];
                    NSMutableArray *newCommentStringList = [NSMutableArray arrayWithArray:self.poiItem.commentStringList];
                    if (newpoiCommentList.count>=5)
                    {
                        [newpoiCommentList removeObjectAtIndex:0];
                        [newCommentStringList removeObjectAtIndex:0];
                    }
                    [newpoiCommentList addObject:myCommentItem];
                    self.poiItem.commentList = newpoiCommentList;
                    [newCommentStringList addObject:commentString];
                    self.poiItem.commentStringList = newCommentStringList;
                    self.poiItem.commentNum ++;
                    
                    // [self.commentList addObject:@{}];
                    [self getLatestCommentList];
                    NSLog(@"comment list tableview contentsize height:%f",self.commentListTableView.contentSize.height);
                    NSLog(@"app height:%f",WZ_APP_SIZE.height);
                    NSLog(@"comment list tableview origian height :%f",self.commentListTableView.bounds.origin.y);
                }
                else if ([returnData objectForKey:@"error"])
                {
                    [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
                }
            });
            
        }];

    });
    
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
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        return UITableViewAutomaticDimension;
    }
    self.prototypeCell.bounds = CGRectMake(0, 0, CGRectGetWidth(self.commentListTableView.bounds), CGRectGetHeight(self.prototypeCell.bounds));
    [self.prototypeCell updateConstraintsIfNeeded];
    [self.prototypeCell layoutIfNeeded];
    //return 800;
    return [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellData = [self.commentList objectAtIndex:indexPath.row];
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentTableCell" forIndexPath:indexPath];
    if (!cell)
    {
        cell = [[CommentTableViewCell alloc]init];
    }
    
    [cell.userAvatorView sd_setImageWithURL:[NSURL URLWithString:[cellData objectForKey:@"avatarUrl"]]];
    cell.userName.text = [NSString stringWithFormat:@"%@",[cellData objectForKey:@"userName"]];
    cell.commentContent.text = [cellData objectForKey:@"content"];
    cell.commentTime.text =  [cellData objectForKey:@"time"];
    [cell setAppearance];
    return cell;
    /*
    if (self.commentList.count <=4)
    {
        NSDictionary *cellData = [self.commentList objectAtIndex:indexPath.row];
        CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentTableCell" forIndexPath:indexPath];
        if (!cell)
        {
            cell = [[CommentTableViewCell alloc]init];
        }
        
        [cell.userAvatorView sd_setImageWithURL:[NSURL URLWithString:[cellData objectForKey:@"avatorUrl"]]];
        cell.userName.text = [NSString stringWithFormat:@"%@",[cellData objectForKey:@"userName"]];
        cell.commentContent.text = [cellData objectForKey:@"content"];
        cell.commentTime.text =  [cellData objectForKey:@"time"];
        [cell setAppearance];
        return cell;
    }
    else
    {
        
        if (indexPath.row == 1)
        {
            UITableViewCell *cell = [[UITableViewCell alloc]init];
            cell.textLabel.text = @"加载更多评论";
            [cell.textLabel setFont:WZ_FONT_SMALL_READONLY_BOLD];
            return cell;
        }
        else
        {
            NSDictionary *cellData;
            if (indexPath.row == 0)
            {
                 cellData = [self.commentList objectAtIndex:indexPath.row];
            }
            else
            {
                cellData = [self.commentList objectAtIndex:indexPath.row-1];
            }
          
            cellData = [self.commentList objectAtIndex:indexPath.row];
            CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentTableCell" forIndexPath:indexPath];
            [cell.userAvatorView sd_setImageWithURL:[NSURL URLWithString:[cellData objectForKey:@"avatorUrl"]]];
           cell.userName.text = [NSString stringWithFormat:@"%@",[cellData objectForKey:@"userName"]];
            cell.commentContent.text = [cellData objectForKey:@"content"];
            cell.commentTime.text =  [cellData objectForKey:@"time"];
            [cell setAppearance];
            return cell;
        
        }
    }*/
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*if (self.commentList.count <=4)
    {
        return  self.poiItem.commentList.count;
    }
    return self.commentList.count +1;
     */
    return self.commentList.count ;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentTableViewCell *cell = (CommentTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ( indexPath.row == 1 && [cell.textLabel.text isEqualToString:@"加载更多评论"])
    {
        //TO DO
        //加载更多评论
    }
    else
    {
        return;
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView setEditing:YES animated:YES];
    NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    NSDictionary *comment = [self.commentList objectAtIndex:indexPath.row];
    if ([(NSNumber *)[comment objectForKey:@"userId"] integerValue] == myUserId)
    {
        return UITableViewCellEditingStyleDelete;
    }
    /*
    else
    {
        return UITableViewCellEditingStyleNone;
    }*/
    return UITableViewCellEditingStyleNone;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self deleteCommentAtIndex:indexPath];
    }
}

-(void)deleteCommentAtIndex:(NSIndexPath *)indexPath
{

    NSInteger commentIdToDelete = [(NSNumber *)[[self.commentList objectAtIndex:indexPath.row] objectForKey:@"commentId"] integerValue];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[QDYHTTPClient sharedInstance]DeleteCommentPhotoWithCommentId:commentIdToDelete  whenComplete:^(NSDictionary *returnData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([returnData objectForKey:@"data"])
                {
                    [self.commentListTableView beginUpdates];
                    [self.commentList removeObjectAtIndex:indexPath.row];
                    [self.commentListTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.commentListTableView endUpdates];
                    self.poiItem.commentNum --;
                    for (NSInteger i = 0;i <self.poiItem.commentList.count;i++)
                    {
                        NSInteger oldCommentId = [(NSNumber *)[self.poiItem.commentList[i] objectForKey:@"commentId"] integerValue];
                        if (oldCommentId == commentIdToDelete)
                        {
                            NSMutableArray *newpoiCommentList = [NSMutableArray arrayWithArray:self.poiItem.commentList];
                            NSMutableArray *newCommentStringList = [NSMutableArray arrayWithArray:self.poiItem.commentStringList];
                            [newpoiCommentList removeObjectAtIndex:i];
                            self.poiItem.commentList = newpoiCommentList;
                            [newCommentStringList removeObjectAtIndex:i];
                            self.poiItem.commentStringList = newCommentStringList;
                            break;
                        }
                        
                        
                    }
                }
                else
                {
                    [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
                }
            });
        }];
    });
 
}
-(void)getLatestCommentList
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[QDYHTTPClient sharedInstance]GetCommentListWithPostId:self.poiItem.postId whenComplete:^(NSDictionary *returnData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([returnData objectForKey:@"data"])
                {
                    WhatsGoingOn *returnItem = [returnData objectForKey:@"data"];
                    if (returnItem)
                    {
                        self.commentList = [returnItem.commentList mutableCopy];
                        [self.commentListTableView reloadData];
                        if (self.view.keyboardFrameInView.size.height >0)
                        {
                            //键盘展开时，滚动到底部
                            if (self.commentListTableView.contentSize.height > WZ_APP_SIZE.height- self.view.keyboardFrameInView.size.height)
                            {
                                [self.commentListTableView setContentOffset:CGPointMake(0, self.commentListTableView.contentSize.height -self.commentListTableView.bounds.size.height -64 ) animated:YES];
                            }
                        }
                        else
                        {
                            NSLog(@"content size height%f",self.commentListTableView.contentSize.height);
                            NSLog(@"bounds size height%f",self.commentListTableView.bounds.size.height);
                            
                            if (self.commentListTableView.contentSize.height > self.commentListTableView.bounds.size.height)
                            {
                                [self.commentListTableView setContentOffset:CGPointMake(0, self.commentListTableView.contentSize.height -self.commentListTableView.bounds.size.height +44) animated:NO];
                            }
                        }
                    }
                    else
                    {
                        [SVProgressHUD showErrorWithStatus:@"获取评论列表失败"];
                    }
                    
                }
                else if ([returnData objectForKey:@"error"])
                {
                    [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
                }
            });

        }];

    });
 }

@end
