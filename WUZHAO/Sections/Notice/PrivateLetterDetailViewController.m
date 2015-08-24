//
//  PrivateLetterDetailViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/7/25.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "PrivateLetterDetailViewController.h"
#import "MyMessageTableViewCell.h"
#import "OtherMessageTableViewCell.h"
#import "DAKeyboardControl.h"
#import "LetterDetailTimeHeaderView.h"
#import "PlaceholderTextView.h"
#import "UIButton+ChangeAppearance.h"
#import "macro.h"
#import "SVProgressHUD.h"
#import "MineViewController.h"
#import "UIViewController+Basic.h"

#import "UIImageView+WebCache.h"

#import "QDYHTTPClient.h"

@interface PrivateLetterDetailViewController ()<UITextViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) IBOutlet UITableView *conversationTableView;
@property (nonatomic, strong) IBOutlet UIToolbar *messageInputToolBar;
@property (nonatomic, strong) PlaceholderTextView *inputTextView;
@property (nonatomic, strong) UIButton *sendButton;

@property (nonatomic, strong) MyMessageTableViewCell *myMessagePrototypeCell;
@property (nonatomic, strong) OtherMessageTableViewCell *otherMessagePrototypeCell;





@end

@implementation PrivateLetterDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shouldRefreshData = YES;
    
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarItem;
    self.navigationItem.title = self.conversation.other.UserName;
    
    [self initConversationTableView];
    [self addToolBar];
    [self setKeyboard];
    [self getLatestConversation];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self loadDataWithAnimate:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [self.view removeKeyboardControl];
}

-(MyMessageTableViewCell *)myMessagePrototypeCell
{
    if (!_myMessagePrototypeCell) {
        _myMessagePrototypeCell = [self.conversationTableView dequeueReusableCellWithIdentifier:@"myMessage"];
    }
    return _myMessagePrototypeCell;
}

-(OtherMessageTableViewCell *)otherMessagePrototypeCell
{
    if (!_otherMessagePrototypeCell) {
        _otherMessagePrototypeCell = [self.conversationTableView dequeueReusableCellWithIdentifier:@"otherMessage"];
    }
    return _otherMessagePrototypeCell;
}

//绘制评论列表 commentListTableView
-(void)initConversationTableView
{
    _conversationTableView = [[UITableView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height-40) style:UITableViewStyleGrouped];
    [self.view addSubview:_conversationTableView];
    _conversationTableView.delegate = self;
    _conversationTableView.dataSource = self;
    [_conversationTableView setDirectionalLockEnabled:YES];
    [_conversationTableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    [_conversationTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_conversationTableView registerNib:[UINib nibWithNibName:@"MyMessageCell" bundle:nil] forCellReuseIdentifier:@"myMessage"];
    [_conversationTableView registerNib:[UINib nibWithNibName:@"OtherMessageCell" bundle:nil] forCellReuseIdentifier:@"otherMessage"];
    
    [_conversationTableView registerClass:[LetterDetailTimeHeaderView class] forHeaderFooterViewReuseIdentifier:@"sectionHeader"];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refreshByPullingTable:) forControlEvents:UIControlEventValueChanged];
    [self.conversationTableView addSubview:self.refreshControl];
    [self.refreshControl setHidden:YES];
}

//绘制评论发表工具栏
-(void)addToolBar
{
    _messageInputToolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0.0f,WZ_APP_SIZE.height-20.0f , WZ_APP_SIZE.width,40.f )];
    [self.view addSubview:_messageInputToolBar];
    _inputTextView = [[PlaceholderTextView alloc]initWithFrame:CGRectMake(10.0f, 6.0f, _messageInputToolBar.frame.size.width -20.0f -68.0f, 30.0f)];
    _inputTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _inputTextView.placeholder = @"输入内容";
    _inputTextView.placeholderFont = WZ_FONT_COMMON_SIZE;
    [_inputTextView setFont:WZ_FONT_COMMON_SIZE];
    [_inputTextView setScrollEnabled:YES];
    _inputTextView.delegate = self;
    
    [_inputTextView setReturnKeyType:UIReturnKeyDefault];
    
    [_messageInputToolBar addSubview:_inputTextView];
    
    
    _sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [_sendButton setNormalButtonAppearance];
    _sendButton.frame = CGRectMake(_messageInputToolBar.bounds.size.width - 68.0f,
                                   6.0f,
                                   58.0f,
                                   29.0f);
    [_messageInputToolBar addSubview:_sendButton];
    [_sendButton setThemeBackGroundAppearance];
    [_sendButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setSendButton:_sendButton];
    
}

//安装可隐藏和显示的键盘
-(void)setKeyboard
{
    self.view.keyboardTriggerOffset = self.messageInputToolBar.frame.size.height;
    
    WEAKSELF_WZ
    [self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
        __strong typeof (weakSelf_WZ)strongSelf = weakSelf_WZ;
        CGRect toolBarFrame = strongSelf.messageInputToolBar.frame;
        CGRect tableViewFrame = strongSelf.conversationTableView.frame;
        tableViewFrame.size.height = keyboardFrameInView.origin.y - toolBarFrame.size.height;
        strongSelf.conversationTableView.frame = tableViewFrame;
        toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
        strongSelf.messageInputToolBar.frame = toolBarFrame;
        [strongSelf loadDataWithAnimate:YES];
    }];
}

#pragma mark - textView delegate

-(void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"return key click");
}
-(void)textViewDidChange:(UITextView *)textView
{
    if ([textView isEqual:self.inputTextView])
    {
        [self updateInputViewFrame];
    }
}
-(void)updateInputViewFrame
{
    UITextView *textView = self.inputTextView;
    CGRect textViewFrame = textView.frame;
    // 计算 text view 的高度
    CGSize maxSize = CGSizeMake(textViewFrame.size.width, CGFLOAT_MAX);
    CGSize newSize = [textView sizeThatFits:maxSize];
    if (newSize.height <90 )
    {
        textViewFrame.size.height = newSize.height;
        // 让 table view 重新计算高度
        UIToolbar *toolbar = self.messageInputToolBar;
        CGRect toolBarFrame = toolbar.frame;
        
        toolBarFrame.origin.y = toolBarFrame.origin.y +toolBarFrame.size.height - textViewFrame.size.height -10;
        toolBarFrame.size.height = textViewFrame.size.height +10;
        toolbar.frame = toolBarFrame;
        textView.frame = textViewFrame;
    }
    
}

#pragma mark - tableview delegate

-(float)caculateHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *sectionList = self.conversation.messageList[indexPath.section];
    Message *message = sectionList[indexPath.row];
    float height = 80;
    float avatarHeight = 48;
    float spacing = 8;
    if (message.fromId == self.conversation.me.UserID)
    {
        MyMessageTableViewCell *cell = self.myMessagePrototypeCell;
        [cell configureCellWithMessage:message];
        height = MAX(avatarHeight +spacing*2, spacing*4+ cell.messageView.frame.size.height);
    }
    else
    {
        OtherMessageTableViewCell *cell = self.otherMessagePrototypeCell;
        [cell configureCellWithMessage:message];
        height = MAX(avatarHeight +spacing*2, spacing*4+ cell.messageView.frame.size.height);
    }
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *sectionList = self.conversation.messageList[section];
    return sectionList.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.conversation.messageList.count;
}
/*
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSMutableArray *sectionList = self.conversation.messageList[section];
    Message *sectionFirstMessage = [sectionList firstObject];
    return sectionFirstMessage.createTime;
}*/
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self caculateHeightForRowAtIndexPath:indexPath];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self caculateHeightForRowAtIndexPath:indexPath];
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSMutableArray *sectionList = self.conversation.messageList[section];
    Message *sectionFirstMessage = [sectionList firstObject];
    LetterDetailTimeHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"sectionHeader"];
    [headerView setTime:sectionFirstMessage.createTime];
    return headerView;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *sectionList = self.conversation.messageList[indexPath.section];
    Message *message = sectionList[indexPath.row];
    if (message.fromId == self.conversation.me.UserID)
    {
        MyMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myMessage" forIndexPath:indexPath];
        if (!cell)
        {
            cell = [[MyMessageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myMessage"];
        }
        [cell configureCellWithMessage:message];
        [cell.avatarView sd_setImageWithURL:[NSURL URLWithString:self.conversation.me.avatarImageURLString]];
        UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarTapped:)];
        [cell.avatarView addGestureRecognizer:avatarTap];
        [cell.avatarView setUserInteractionEnabled:YES];
        
        //failedinfo gesture
        if (message.isFailed)
        {
            [cell.failedInfoIcon setUserInteractionEnabled:YES];
            UITapGestureRecognizer *failedInfoTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(failedIconTap:)];
            [cell.failedInfoIcon addGestureRecognizer:failedInfoTap];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    else if (message.fromId == self.conversation.other.UserID)
    {
        OtherMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"otherMessage" forIndexPath:indexPath];
        if (!cell)
        {
            cell = [[OtherMessageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"otherMessage"];
        }
        [cell configureCellWithMessage:message];
        [cell.avatarView sd_setImageWithURL:[NSURL URLWithString:self.conversation.other.avatarImageURLString]];
        UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarTapped:)];
        [cell.avatarView addGestureRecognizer:avatarTap];
        [cell.avatarView setUserInteractionEnabled:YES];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
    
}

#pragma mark - action and gesture
-(void)refreshByPullingTable:(id)sender
{
    if (self.shouldRefreshData)
    {
        [self getLatestConversation];
    }
    else
    {
        if ([self.refreshControl isRefreshing])
        {
            [self.refreshControl endRefreshing];
        }
    }
}
-(void)sendMessage:(id)sender
{
    if ([self.inputTextView.text isEqualToString:@""])
    {
        return;
    }

    Message *newMessage = [[Message alloc]init];
    newMessage.fromId = self.conversation.me.UserID;
    newMessage.toId = self.conversation.other.UserID;
    newMessage.content = self.inputTextView.text;
    newMessage.createTime = @"刚刚";
    [self.conversation appendMessage:newMessage];
    [self.inputTextView setPlaceholder:@"请输入内容"];
    self.inputTextView.text = @"";
    [self updateInputViewFrame];
    [self loadDataWithAnimate:YES];
    [[QDYHTTPClient sharedInstance]sendMessageWithMyUserId:newMessage.fromId toUserId:newMessage.toId content:newMessage.content whenComplete:^(NSDictionary *returnData) {
        if ([returnData objectForKey:@"data"])
        {
            //success
        }
        else
        {
            //failed
            newMessage.isFailed = YES;
            [self loadDataWithAnimate:YES];
        }
    }];
}
-(void)failedIconTap:(UIGestureRecognizer *)gesture
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alertController addAction:cancelAction];
    
    MyMessageTableViewCell *cell = (MyMessageTableViewCell *)[[gesture.view superview]superview];
    NSIndexPath *indexpath = [self.conversationTableView indexPathForCell:cell];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self.conversationTableView beginUpdates];
        NSMutableArray *section = self.conversation.messageList[indexpath.section];
        [section removeObjectAtIndex:indexpath.row];
        if (section.count >0)
        {
            [self.conversationTableView deleteRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationFade];
            
        }
        else
        {
            [self.conversation.messageList removeObject:section];
            [self.conversationTableView deleteSections:[NSIndexSet indexSetWithIndex:indexpath.section] withRowAnimation:UITableViewRowAnimationFade];
        }

        [self.conversationTableView endUpdates];
       // [self.commentList removeObjectAtIndex:indexpath.row];
       // [self loadData];
        
    }];
    [alertController addAction:deleteAction];
    
    UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"重新发送" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self resendCommentAtIndexPath:indexpath];
    }];
    [alertController addAction:retryAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)avatarTapped:(UIGestureRecognizer *)gesture
{
    UIImageView *avatar = (UIImageView *)gesture.view;
    UITableViewCell *cell = (UITableViewCell *)avatar.superview.superview;
    NSIndexPath *indexPath = [self.conversationTableView indexPathForCell:cell];
    NSMutableArray *sectionList = self.conversation.messageList[indexPath.section];
    Message *message = sectionList[indexPath.row];
    User *user = [[User alloc]init];
    user.UserID = message.fromId;
    [self goToPersonalPageWithUserInfo:user];
}

#pragma mark - control the model
-(void)resendCommentAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *section = self.conversation.messageList[indexPath.section];
    Message *message = section[indexPath.row];
    [[QDYHTTPClient sharedInstance]sendMessageWithMyUserId:message.fromId toUserId:message.toId content:message.content whenComplete:^(NSDictionary *returnData) {
        if ([returnData objectForKey:@"data"])
        {
            //success
            message.isFailed = NO;
            [self.conversationTableView reloadData];
            //[self loadDataWithAnimate:NO];
            
        }
        else
        {
            //failed
            message.isFailed = YES;
            [SVProgressHUD showErrorWithStatus:@"重新发送失败"];
            //[self loadDataWithAnimate:YES];
        }
    }];

    
}
-(void)getLatestConversation
{
    if (!self.shouldRefreshData)
    {
        self.shouldRefreshData = NO;
    }
    [[QDYHTTPClient sharedInstance]getConversationWithUserId:self.conversation.me.UserID otherUserId:self.conversation.other.UserID whenComplete:^(NSDictionary *returnData) {
        self.shouldRefreshData = YES;
        if ([self.refreshControl isRefreshing])
        {
            [self.refreshControl endRefreshing];
        }
        if ([returnData objectForKey:@"data"])
        {
            [[QDYHTTPClient sharedInstance]getLatestNoticeNumber];
            Conversation *c = [returnData objectForKey:@"data"];
            if (c.me.UserID>0 && c.other.UserID >0)
            {
                
                self.conversation.me = c.me;
                self.conversation.other = c.other;
                self.conversation.messageList = c.messageList;
                self.conversation.latestMsg = c.latestMsg;
                self.conversation.newMessageCount = c.newMessageCount;
            }
            else
            {
                NSLog(@"暂时无信息");
            }
        
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
        }
        [self loadDataWithAnimate:NO];
    }];
}

-(void)loadDataWithAnimate:(BOOL)animate
{
    if (!self.shouldRefreshData)
    {
        return;
    }
    self.shouldRefreshData = NO;
    [self.conversationTableView reloadData];
    float tableViewVisibleHeight = self.view.keyboardFrameInView.origin.y- self.messageInputToolBar.frame.size.height;
    //float contentsize = self.conversationTableView.contentSize.height;
    if (self.conversationTableView.contentSize.height >tableViewVisibleHeight)
    {
        [self.conversationTableView setContentOffset:CGPointMake(0,self.conversationTableView.contentSize.height - tableViewVisibleHeight) animated:animate];
    }
    if ([self.refreshControl isRefreshing])
    {
        [self.refreshControl endRefreshing];
    }
    self.shouldRefreshData = YES;
}

-(void)goToPersonalPageWithUserInfo:(User *)user
{
    UIStoryboard *personalStoryboard= [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
    MineViewController *personalViewCon = [personalStoryboard instantiateViewControllerWithIdentifier:@"personalPage"];
    [personalViewCon setUserInfo:user];
    [self pushToViewController:personalViewCon animated:YES hideBottomBar:YES];
}

@end
