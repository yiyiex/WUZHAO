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

#import "MineViewController.h"

#import "PlaceholderTextView.h"

#import "QDYHTTPClient.h"

#import "DAKeyboardControl.h"
#import "SVProgressHUD.h"
#define SEGUEFIRST @"showCommentList"
@interface CommentListViewController ()<UITableViewDataSource,UITableViewDelegate,CommentTextViewDelegate,UITextViewDelegate>

@property (nonatomic,strong) UITableView *commentListTableView; //展示评论列表
@property (nonatomic,strong) UIToolbar *toolbar;  //发表评论工具栏
@property (nonatomic,strong) PlaceholderTextView *commentTextField;  //评论输入框
@property (nonatomic,strong) UIButton *sendButton;  //发表按钮
@property (nonatomic,strong) CommentTableViewCell *prototypeCell;

@property (nonatomic,strong) User *replyUser;


@end

@implementation CommentListViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarItem;
    self.navigationItem.title = @"评论列表";
   // self.automaticallyAdjustsScrollViewInsets = NO;
    //[self.commentListTableView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    
    [self initCommentListTableView];
    [self addToolBar];
    [self setKeyboard];
    //[self setKeyboard];
    [self getLatestCommentList];
    
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.isKeyboardShowWhenLoadView)
    {
        [self.commentTextField becomeFirstResponder];
    }
   

}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //[self.view removeKeyboardControl];
    
}
-(void)dealloc
{
    [self.view removeKeyboardControl];
    [self.commentListTableView setEditing:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(User *)replyUser
{
    if (!_replyUser)
    {
        _replyUser = [[User alloc]init];
    }
    return  _replyUser;
}
-(void)setPoiItem:(WhatsGoingOn *)poiItem
{
    _poiItem = poiItem;
    _commentList = [poiItem.commentList mutableCopy];
}
-(NSMutableArray *)commentList
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
        _prototypeCell = [self.commentListTableView dequeueReusableCellWithIdentifier:@"commentTableCell"];
    }
    return _prototypeCell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    
}
#pragma mark - draw the compoment
//绘制评论列表 commentListTableView
-(void)initCommentListTableView
{
    if (!_commentListTableView)
    {
        _commentListTableView = [[UITableView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height-40)];
       // _commentListTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_commentListTableView setEstimatedRowHeight:40.0f];
        _commentListTableView.rowHeight = UITableViewAutomaticDimension;
        [_commentListTableView registerNib:[UINib nibWithNibName:@"CommentListTableViewCell" bundle:nil] forCellReuseIdentifier:@"commentTableCell"];
      //  [_commentListTableView registerClass:[CommentTableViewCell class] forCellReuseIdentifier:@"commentTableCell"];
        [_commentListTableView setDelegate:self];
        [_commentListTableView setDataSource:self];
        [_commentListTableView setDirectionalLockEnabled:YES];
        [_commentListTableView setSectionIndexBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:_commentListTableView];
        
        UISwipeGestureRecognizer *swipeUpGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
        [swipeUpGesture setDirection:UISwipeGestureRecognizerDirectionUp];
        [_commentListTableView addGestureRecognizer:swipeUpGesture];
        UISwipeGestureRecognizer *swipeDownGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
        [swipeDownGesture setDirection:UISwipeGestureRecognizerDirectionDown];
        [_commentListTableView addGestureRecognizer:swipeDownGesture];
       

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
    
        _commentTextField = [[PlaceholderTextView alloc]initWithFrame:CGRectMake(10.0f, 6.0f, _toolbar.bounds.size.width -20.0f -68.0f, 30.0f)];
        _commentTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _commentTextField.placeholder = @"输入评论内容...";
        _commentTextField.placeholderFont = WZ_FONT_COMMON_SIZE;
        [_commentTextField setFont:WZ_FONT_COMMON_SIZE];
        [_commentTextField setScrollEnabled:YES];
         _commentTextField.delegate = self;
        
        [_commentTextField setReturnKeyType:UIReturnKeyDone];
        
        
        
        
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
        
        
        __strong typeof (weakSelf_WZ)strongSelf = weakSelf_WZ;
        CGRect toolBarFrame = strongSelf.toolbar.frame;
        CGRect tableViewFrame = strongSelf.commentListTableView.frame;
        strongSelf.commentListTableView.contentInset = UIEdgeInsetsMake(64, 0,keyboardFrameInView.size.height+ toolBarFrame.size.height, 0);
       // tableViewFrame.size.height = keyboardFrameInView.origin.y - toolBarFrame.size.height;
        //strongSelf.commentListTableView.frame = tableViewFrame;
        
        toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
        strongSelf.toolbar.frame = toolBarFrame;
        
        
       
        
                
    }];
}
#pragma mark - gesture
-(void)avatarClick:(UITapGestureRecognizer *)gesture
{
    CommentTableViewCell *cell = (CommentTableViewCell *)[[gesture.view superview]superview];
    NSIndexPath *indexpath = [self.commentListTableView indexPathForCell:cell];
    User *user = [[User alloc]init];
    Comment *commentItem = self.commentList[indexpath.row];
    user.UserID = commentItem.commentUser.UserID;
    user.UserName = commentItem.commentUser.UserName;
    [self goToPersonalPageWithUserInfo:user];
    
    
}

-(void)infoImageClick:(UIGestureRecognizer *)gesture
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alertController addAction:cancelAction];
    
    CommentTableViewCell *cell = (CommentTableViewCell *)[[gesture.view superview]superview];
    NSIndexPath *indexpath = [self.commentListTableView indexPathForCell:cell];

    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {

        [self.commentList removeObjectAtIndex:indexpath.row];
        [self loadData];
        
    }];
    [alertController addAction:deleteAction];
    
    UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"重新发送" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self resendCommentAtIndexPath:indexpath];
    }];
    [alertController addAction:retryAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}
#pragma mark -  action
-(void)resendCommentAtIndexPath:(NSIndexPath *)indexPath
{
    Comment *comment = [self.commentList objectAtIndex:indexPath.row];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[QDYHTTPClient sharedInstance]CommentPhotoWithUserId:comment.commentUser.UserID postId:comment.postId comment:comment.content replyUserId:comment.replyUser.UserID whenComplete:^(NSDictionary *returnData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([returnData objectForKey:@"data"])
                {
                    // [SVProgressHUD showInfoWithStatus:@"评论成功"];
                    NSLog(@"评论成功");
                    comment.isFailed = NO;
                    [self loadData];
                    //更新主页显示内容
                    [self updateHomePageCommentContentAfterCommentSuccess:comment];
                }
                else if ([returnData objectForKey:@"error"])
                {
                    [SVProgressHUD showErrorWithStatus:@"评论失败，请检查网络设置"];
                    comment.isFailed = YES;
                    [self loadData];
                }
            });
            
        }];
        
    });

}
-(void)sendComment:(id)sender
{
    NSString *commentContent = self.commentTextField.text;
    if ([commentContent isEqualToString:@""])
    {
        return;
    }
    self.commentTextField.text = @"";
    [self updateCommentViewFrame];
    [self setCommentTextFieldPlaceHolder];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    Comment *comment = [[Comment alloc]init];
    comment.commentUser.UserID = [userDefault integerForKey:@"userId"];
    comment.commentUser.UserName = [userDefault objectForKey:@"userName"];
    comment.commentUser.avatarImageURLString = [userDefault objectForKey:@"avatarUrl"];
    comment.postId = self.poiItem.postId;
    comment.content = commentContent;
    if ( self.replyUser.UserName && self.replyUser.UserID != comment.commentUser.UserID)
    {
        comment.replyUser = self.replyUser;
        comment.commentString = [NSString stringWithFormat:@"%@ 回复 %@: %@",comment.commentUser.UserName,comment.replyUser.UserName,comment.content];
    }
    else
    {
        comment.commentString = [NSString stringWithFormat:@"%@: %@",comment.commentUser.UserName,comment.content];
    }
    comment.createTime = @"刚刚";
    
    //恢复replyuser
    self.replyUser = nil;
    [self.commentList addObject:comment];
    [self loadData];
   
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[QDYHTTPClient sharedInstance]CommentPhotoWithUserId:comment.commentUser.UserID postId:comment.postId comment:comment.content replyUserId:comment.replyUser.UserID whenComplete:^(NSDictionary *returnData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([returnData objectForKey:@"data"])
                {
                   // [SVProgressHUD showInfoWithStatus:@"评论成功"];
                    NSLog(@"评论成功");
                    //更新主页显示内容
                    [self updateHomePageCommentContentAfterCommentSuccess:comment];
 
                    //[self getLatestCommentList];
                }
                else if ([returnData objectForKey:@"error"])
                {
                    //[SVProgressHUD showErrorWithStatus:@"评论失败，请检查网络设置"];
                    comment.isFailed = YES;
                    [self loadData];
                }
            });
            
        }];

    });
    
}

-(void)updateHomePageCommentContentAfterCommentSuccess:(Comment *)comment
{
    //更新主页显示内容
    NSMutableArray *newpoiCommentList = [NSMutableArray arrayWithArray:self.poiItem.commentList];
    if (newpoiCommentList.count ==5)
    {
        [newpoiCommentList removeObjectAtIndex:0];
    }
    [newpoiCommentList addObject:comment];
    self.poiItem.commentList = newpoiCommentList;
    self.poiItem.commentNum ++;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - tableview delegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Comment *cellData = [self.commentList objectAtIndex:indexPath.row];
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentTableCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (!cell)
    {
        cell = [[CommentTableViewCell alloc]init];
    }
    [cell configureDataWith:cellData parentController:self];

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
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.prototypeCell configureDataWith:self.commentList[indexPath.row] parentController:nil];
    float height = 28+ self.prototypeCell.commentContent.frame.size.height +2 ;
    
    return (isnan(height)?UITableViewAutomaticDimension:height);
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.prototypeCell configureDataWith:self.commentList[indexPath.row] parentController:nil];
    float height = 28+ self.prototypeCell.commentContent.frame.size.height +2;
    return (isnan(height)?UITableViewAutomaticDimension:height);
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
        Comment *commentItem = self.commentList[indexPath.row];
        self.replyUser.UserID =  commentItem.commentUser.UserID;
        self.replyUser.UserName = commentItem.commentUser.UserName;
        [self setCommentTextFieldPlaceHolder];
        if (self.replyUser.UserID != [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"])
        {
            if (![self.commentTextField isFirstResponder])
            {
                [self.commentTextField becomeFirstResponder];
            }
        }
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView setEditing:YES animated:YES];
    NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    Comment *comment = [self.commentList objectAtIndex:indexPath.row];
    if (comment.commentUser.UserID == myUserId)
    {
        return UITableViewCellEditingStyleDelete;
    }

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
    
    Comment *commentToDelete = [self.commentList objectAtIndex:indexPath.row];
    [self.commentListTableView beginUpdates];
    [self.commentList removeObjectAtIndex:indexPath.row];
    [self.commentListTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.commentListTableView endUpdates];
    self.poiItem.commentNum --;
    for (NSInteger i = 0;i <self.poiItem.commentList.count;i++)
    {
        Comment *oldComment = self.poiItem.commentList[i];
        if (oldComment.commentId == commentToDelete.commentId)
        {
            NSMutableArray *newpoiCommentList = [NSMutableArray arrayWithArray:self.poiItem.commentList];
            [newpoiCommentList removeObjectAtIndex:i];
            self.poiItem.commentList = newpoiCommentList;
            break;
        }
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[QDYHTTPClient sharedInstance]DeleteCommentPhotoWithCommentId:commentToDelete.commentId  whenComplete:^(NSDictionary *returnData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([returnData objectForKey:@"data"])
                {
                    NSLog(@"删除评论成功");
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
                        [self loadData];
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

-(void)loadData
{
    [self.commentListTableView reloadData];
    float tableViewVisibleHeight = self.view.keyboardFrameInView.origin.y- self.toolbar.frame.size.height;
    if (self.commentListTableView.contentSize.height >tableViewVisibleHeight)
    {
        [self.commentListTableView setContentOffset:CGPointMake(0,self.commentListTableView.contentSize.height - tableViewVisibleHeight) animated:YES];
    }
}



#pragma mark - textView delegate

-(void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"return key click");
}

-(void)textViewDidChange:(UITextView *)textView
{
    if ([textView isEqual:self.commentTextField])
    {
        [self updateCommentViewFrame];
    }
}


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [self sendComment:self.sendButton];
        return NO;
    }
    return YES;
    
}

#pragma mark - commentTextView Delegate

-(void)commentTextView:(CommentTextView *)commentTextView didClickLinkUser:(User *)user
{
    [self goToPersonalPageWithUserInfo:user];
}

-(void)didClickUnlinedTextOncommentTextView:(CommentTextView *)commentTextView
{
    CommentTableViewCell *cell = (CommentTableViewCell *)[[commentTextView superview]superview];
    NSIndexPath *indexpath = [self.commentListTableView indexPathForCell:cell];
    Comment *commentItem = self.commentList[indexpath.row];
    self.replyUser.UserID =  commentItem.commentUser.UserID;
    self.replyUser.UserName = commentItem.commentUser.UserName;
    [self setCommentTextFieldPlaceHolder];
    if (self.replyUser.UserID != [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"])
    {
        if (![self.commentTextField isFirstResponder])
        {
            [self.commentTextField becomeFirstResponder];
        }
    }
}



#pragma mark - method
-(void)hideKeyboard
{
    self.replyUser.UserID = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    self.replyUser.UserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    [self setCommentTextFieldPlaceHolder];
    //[[NSNotificationCenter defaultCenter]postNotificationName:UIKeyboardWillHideNotification object:nil];
                             
}
-(void)updateCommentViewFrame
{
    UITextView *textView = self.commentTextField;
    CGRect textViewFrame = textView.frame;
    // 计算 text view 的高度
    CGSize maxSize = CGSizeMake(textViewFrame.size.width, CGFLOAT_MAX);
    CGSize newSize = [textView sizeThatFits:maxSize];
    if (newSize.height <90 )
    {
        textViewFrame.size.height = newSize.height;
        // 让 table view 重新计算高度
        UIToolbar *toolbar = self.toolbar;
        CGRect toolBarFrame = toolbar.frame;
        
        toolBarFrame.origin.y = toolBarFrame.origin.y +toolBarFrame.size.height - textViewFrame.size.height -10;
        toolBarFrame.size.height = textViewFrame.size.height +10;
        toolbar.frame = toolBarFrame;
        textView.frame = textViewFrame;
    }
    
}

-(void)setCommentTextFieldPlaceHolder
{
    NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    if (!self.replyUser)
    {
        self.commentTextField.placeholder = @"输入评论内容...";
    }
    if (self.replyUser.UserID != myUserId && self.replyUser.UserName)
    {
        self.commentTextField.placeholder = [NSString stringWithFormat:@"回复%@：",self.replyUser.UserName];
    }
    else
    {
        self.commentTextField.placeholder = @"输入评论内容...";
    }
}

-(void)goToPersonalPageWithUserInfo:(User *)user
{
    UIStoryboard *personalStoryboard= [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
    MineViewController *personalViewCon = [personalStoryboard instantiateViewControllerWithIdentifier:@"personalPage"];
    [personalViewCon setUserInfo:user];
    [self.navigationController pushViewController:personalViewCon animated:YES];
}

@end
