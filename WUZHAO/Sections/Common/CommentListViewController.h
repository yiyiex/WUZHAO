//  评论详情列表；展示所有评论，并发表评论
//  CommentListViewController.h
//  WUZHAO
//
//  Created by yiyi on 15-1-9.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "WhatsGoingOn.h"
@interface CommentListViewController : UIViewController
@property (nonatomic,strong) WhatsGoingOn *poiItem;

@property (nonatomic, strong) NSMutableArray *commentList; //存储评论列表
@property (nonatomic) BOOL isKeyboardShowWhenLoadView;

-(void)avatarClick:(UITapGestureRecognizer *)gesture;
@end
