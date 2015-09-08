//
//  SubjectViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/8/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "SubjectViewController.h"
#import "SubjectItemWithPostTableViewCell.h"
#import "SubjectItemWithoutPostTableViewCell.h"
#import "subjectItemHeader.h"
#import "SubjectItemFooter.h"
#import "HomeTableViewController.h"
#import "QDYHTTPClient.h"
#import "SVProgressHUD.h"
#import "macro.h"
@interface SubjectViewController()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) UILabel *tableHeaderLabel;
@property (nonatomic, strong) UIView *tableFooterView;
@property (nonatomic, strong) UILabel *tableFooterLabel;

@property (nonatomic, strong) subjectItemHeader *prototypeHeader;
@property (nonatomic, strong) SubjectItemFooter *prototypeFooter;
@property (nonatomic, strong) SubjectItemWithoutPostTableViewCell *prototypeCellWithoutPost;
@property (nonatomic, strong) SubjectItemWithPostTableViewCell *prototypeCellWithPost;


@end

@implementation SubjectViewController

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        //[self initSubjectTableView];
        [self setTitle:@"专题"];
    }
    return self;
}

-(SubjectItemWithoutPostTableViewCell *)prototypeCellWithoutPost
{
    if (!_prototypeCellWithoutPost)
    {
        _prototypeCellWithoutPost = [self.tableView dequeueReusableCellWithIdentifier:@"itemWithoutPost"];
    }
    return _prototypeCellWithoutPost;
}
-(SubjectItemWithPostTableViewCell *)prototypeCellWithPost
{
    if (!_prototypeCellWithPost)
    {
        _prototypeCellWithPost = [self.tableView dequeueReusableCellWithIdentifier:@"itemWithPost"];
    }
    return _prototypeCellWithPost;
}
-(SubjectItemFooter *)prototypeFooter
{
    if (!_prototypeFooter)
    {
        _prototypeFooter = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"footer"];
    }
    return _prototypeFooter;
}
-(subjectItemHeader *)prototypeHeader
{
    if (!_prototypeHeader)
    {
        _prototypeHeader = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    }
    return _prototypeHeader;
}

-(void)initSubjectTableView
{
    self.tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    [self.tableView setBackgroundColor:[UIColor colorWithWhite:240 alpha:1.0f]];
    [self.tableView registerNib:[UINib nibWithNibName:@"SubjectItemWithPostTableViewCell" bundle:nil] forCellReuseIdentifier:@"itemWithPost"];
    [self.tableView registerNib:[UINib nibWithNibName:@"SubjectItemWithoutPostTableViewCell" bundle:nil] forCellReuseIdentifier:@"itemWithoutPost"];
    
    [self.tableView registerClass:[subjectItemHeader class] forHeaderFooterViewReuseIdentifier:@"header"];
    [self.tableView registerClass:[SubjectItemFooter class] forHeaderFooterViewReuseIdentifier:@"footer"];

    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    [self.view addSubview:self.tableView];
    
}

-(void)viewDidLoad
{
    self.automaticallyAdjustsScrollViewInsets = YES;
    [self initSubjectTableView];
    [self getLatestData];
}

#pragma mark - table view delegate and datasource
-(float)caculateHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SubjectPost *post = self.subject.subjectpostList[indexPath.row];
    if (post.postId >0)
    {
        
        [self.prototypeCellWithPost configureWithContent:post];
        [self.prototypeCellWithPost layoutSubviews];
        return 4 + self.prototypeCellWithPost.title.frame.size.height + self.prototypeCellWithPost.postUserAvatar.frame.size.height + 8 + WZ_APP_SIZE.width + 4 + self.prototypeCellWithPost.photoDescription.frame.size.height;
    }
    else
    {
        [self.prototypeCellWithoutPost configureWithContent:post];
        [self.prototypeCellWithoutPost layoutSubviews];
        return 4 + self.prototypeCellWithoutPost.title.frame.size.height + WZ_APP_SIZE.width + 4 + self.prototypeCellWithoutPost.photoDescription.frame.size.height;
    }
    return 100;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    [self.prototypeHeader configureHeaderWithSubject:self.subject];
    [self.prototypeHeader layoutSubviews];
    float height = self.prototypeHeader.title.frame.size.height + self.prototypeHeader.subtitle.frame.size.height + self.prototypeHeader.subjectDescription.frame.size.height + 16;
    return height;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    [self.prototypeFooter configureFooterWithSubject:self.subject];
    [self.prototypeFooter layoutSubviews];
    float height = self.prototypeFooter.summaryLabel.frame.size.height + 16;
    return height;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.subject.subjectpostList.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    subjectItemHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    [header configureHeaderWithSubject:self.subject];
    return header;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    SubjectItemFooter *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"footer"];
    [footer configureFooterWithSubject:self.subject];
    return footer;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self caculateHeightForRowAtIndexPath:indexPath];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self caculateHeightForRowAtIndexPath:indexPath];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SubjectPost *post = self.subject.subjectpostList[indexPath.row];
    if (post.postId >0)
    {
        SubjectItemWithPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemWithPost" forIndexPath:indexPath];
        [cell configureWithContent:post];
        //configure the gesture
        UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarTapped:)];
        [cell.postUserAvatar addGestureRecognizer:avatarTap];
        [cell.postUserAvatar setUserInteractionEnabled:YES];
        UITapGestureRecognizer *photoTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(photoTapped:)];
        [cell.photo addGestureRecognizer:photoTap];
        [cell.photo setUserInteractionEnabled:YES];
        [cell.followButton addTarget:self action:@selector(followButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        SubjectItemWithoutPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemWithoutPost" forIndexPath:indexPath];
        [cell configureWithContent:post];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    
}
#pragma mark - control the model
-(void)getLatestData
{
    [[QDYHTTPClient sharedInstance]getSubjectDetailWithSubjectId:self.subject.subjectId whenComplete:^(NSDictionary *returnData) {
        if ([returnData objectForKey:@"data"])
        {
            self.subject = [returnData objectForKey:@"data"];
            [self.tableView reloadData];
            //[self.tableView setContentOffset:CGPointMake(0, 0)];
        }
        else if ([returnData objectForKey:@"error"])
        {
            [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"获取数据失败"];
        }
    }];
}

#pragma mark - gesture and action
-(void)avatarTapped:(UIGestureRecognizer *)gesture
{
    SubjectItemWithPostTableViewCell *cell = (SubjectItemWithPostTableViewCell*) gesture.view.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    SubjectPost *post = self.subject.subjectpostList[indexPath.row];
    [self goToPersonalPageWithUserInfo:post.userInfo];
}

-(void)photoTapped:(UIGestureRecognizer *)gesture
{
    SubjectItemWithPostTableViewCell *cell = (SubjectItemWithPostTableViewCell*) gesture.view.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    SubjectPost *post = self.subject.subjectpostList[indexPath.row];
    
    WhatsGoingOn *item = [[WhatsGoingOn alloc]init];
    item.postId = post.postId;
    [self gotoPostDetailPageWithPost:item];
}

- (void)followButtonPressed:(UIButton *)sender
{
    [sender setHidden:YES];
    SubjectItemWithPostTableViewCell *cell = (SubjectItemWithPostTableViewCell*) sender.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    SubjectPost *post = self.subject.subjectpostList[indexPath.row];
    NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[QDYHTTPClient sharedInstance]followUser:post.userInfo.UserID withUserId:myUserId whenComplete:^(NSDictionary *result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([result objectForKey:@"data"])
                {
                    [sender setHidden:YES];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateUserInfo" object:nil];
                    
                }
                else if ([result objectForKey:@"error"])
                {
                    [sender setHidden:NO];
                    [SVProgressHUD showErrorWithStatus:[result objectForKey:@"error"]];
                }
            });
            
        }];
    });
}

#pragma mark - transition
@end
