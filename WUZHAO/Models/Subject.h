//
//  Subject.h
//  WUZHAO
//
//  Created by yiyi on 15/8/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
@interface SubjectPost:NSObject
@property (nonatomic) NSInteger subjectId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subjectPhotoDescription;
@property (nonatomic, strong) NSString *photoUrlString;
@property (nonatomic, strong) User *userInfo;
@property (nonatomic) NSInteger subjectPostId;
@property (nonatomic) NSInteger postId;
@property (nonatomic, strong) NSString *createTime;
-(instancetype)initWithDictionary:(NSDictionary *)dic;

@end

@interface Subject : NSObject
@property (nonatomic) NSInteger subjectId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subTitle;
@property (nonatomic, strong) NSString *subjectDescription;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *backgroundImageUrlString;
@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, strong) NSMutableArray *subjectpostList;
-(instancetype)initWithDictionary:(NSDictionary *)dic;
@end
