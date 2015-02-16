//
//  WhatsGoingOn.h
//  testLogin
//
//  Created by yiyi on 14-11-29.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "User.h"
@interface WhatsGoingOn : NSObject

@property (nonatomic,copy) User *photoUser;
@property (nonatomic ,readwrite) NSInteger postId;
@property (nonatomic,readwrite) NSInteger commentNum;
@property (nonatomic,copy) NSString *imageUrlString;
@property (nonatomic,copy) NSString *postTime;
@property (nonatomic,copy) NSString *imageDescription;
//@property (nonatomic,copy) NSString *adddresMark;
@property (nonatomic) NSInteger likeCount;
@property (nonatomic,copy) NSString *comment;
@property (nonatomic,copy) NSArray  *commentList;
@property (nonatomic,copy) NSAttributedString *attributedComment;
@property (nonatomic) BOOL hasMoreComments;
@property (nonatomic) NSInteger poiId;
@property (nonatomic,strong) NSString *poiName;
+ (NSArray *) newDataSource;

@end
