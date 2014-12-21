//
//  AddImageInfoViewController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-21.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "AddImageInfoViewController.h"
#import "AddressInfoList.h"

@interface AddImageInfoViewController()
@property NSArray *addressDataSource;
@end

@implementation AddImageInfoViewController

- (void)viewDidLoad
{
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = NO;
    self.postImageView.image = self.postImage;
    [self.addressTableView reloadData];
}
#pragma mark =================datas===================
-(NSArray *)addressDataSource
{
    if (!_addressDataSource)
    {
        _addressDataSource = [[AddressInfoList newDataSource] mutableCopy];
    }
    return _addressDataSource;
}

-(UIImageView *)postImageView
{
    if (_postImage)
    {
        _postImageView.image = _postImage;
    }
    return _postImageView;
}

-(WhatsGoingOn *)whatsGoingOnItem
{
    if (!_whatsGoingOnItem)
    {
        _whatsGoingOnItem = [[WhatsGoingOn alloc]init];
    }
    return _whatsGoingOnItem;
}

#pragma mark ==============buttons

-(void)PostButtonPressed:(UIBarButtonItem *)sender
{
    if(self.postImageDescription.text)
    {
        self.whatsGoingOnItem.imageDescription = self.postImageDescription.text;
    }
    self.whatsGoingOnItem.imageUrlString = @"";
    self.whatsGoingOnItem.likeCount = 0;
    self.whatsGoingOnItem.comment = @"";
    //self.whatsGoingOnItem.photoUser =
    [self.postImageDescription resignFirstResponder];
    
    //发布照片信息
    //........

    //转回到主页，显示最新发布的信息
    if ([self.addImageInfoDelegate respondsToSelector:@selector(endPostImageInfo:)])
    {
        [self.addImageInfoDelegate endPostImageInfo];
    }
    
    
}

#pragma mark ==============tableview delegate===================

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.addressDataSource.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addressInfoCell" forIndexPath:indexPath];
    cell.textLabel.text = [self.addressDataSource objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.whatsGoingOnItem.adddresMark = [self.addressDataSource objectAtIndex:indexPath.row];
    self.whatsGoingOnItem.imageDescription = @"";
    NSLog(@"test whatsgoingon");
    self.addressInfoLabel.text = [NSString stringWithFormat:@"you chooese : %@",self.whatsGoingOnItem.adddresMark];
    
    
}

#pragma mark ================textview delegate====================
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![self.postImageDescription isExclusiveTouch])
    {
        self.whatsGoingOnItem.imageDescription = self.postImageDescription.text;
        [self.postImageDescription resignFirstResponder];
    }
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

@end
