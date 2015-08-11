//
//  Subject.m
//  WUZHAO
//
//  Created by yiyi on 15/8/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "Subject.h"
#import "NSDictionary+utility.h"
@implementation SubjectPost

-(instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if ([dic hasObject:@"description"])
    {
        self.subjectPhotoDescription = [dic objectForKey:@"description"];
    }
    if ([dic hasObject:@"photo"])
    {
        self.photoUrlString = [dic objectForKey:@"photo"];
    }
    if ([dic hasObject:@"subjectId"])
    {
        self.subjectId = [(NSNumber *)[dic objectForKey:@"photo"]integerValue];
    }
    if ([dic hasObject:@"userInfo"])
    {
        self.userInfo = [[User alloc]initWithAttributes:[dic objectForKey:@"userInfo"]];
    }
    if ([dic hasObject:@"subjectpostId"])
    {
        self.subjectPostId = [(NSNumber *)[dic objectForKey:@"subjectpostId"]integerValue];
    }
    if ([dic hasObject:@"postId"])
    {
        self.postId = [(NSNumber *)[dic objectForKey:@"postId"]integerValue];
    }
    if ([dic hasObject:@"createTime"])
    {
        self.createTime = [dic objectForKey:@"createTime"];
    }
    if ([dic hasObject:@"title"])
    {
        self.title  = [dic objectForKey:@"title"];
    }
    return self;
    
}

@end
@implementation Subject
-(instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if ([dic hasObject:@"subTitle"])
    {
        self.subTitle = [dic objectForKey:@"subTitle"];
    }
    if ([dic hasObject:@"description"])
    {
        self.subjectDescription = [dic objectForKey:@"description"];
    }
    if ([dic hasObject:@"title"])
    {
        self.title = [dic objectForKey:@"title"];
    }
    if ([dic hasObject:@"createTime"])
    {
        self.createTime = [dic objectForKey:@"createTime"];
    }
    if ([dic hasObject:@"subjectId"])
    {
        self.subjectId = [(NSNumber *)[dic objectForKey:@"subjectId"]integerValue];
    }
    if ([dic hasObject:@"summary"])
    {
        self.summary = [dic objectForKey:@"summary"];
    }
    if ([dic hasObject:@"background"])
    {
        self.backgroundImageUrlString = [dic objectForKey:@"background"];
    }
    if ([dic hasObject:@"createTime"])
    {
        self.createTime = [dic objectForKey:@"createTime"];
    }
    if ([dic hasObject:@"subjectpostList"])
    {
        NSArray *subjectPostList = [dic objectForKey:@"subjectpostList"];
        if (subjectPostList.count >0)
        {
            self.subjectpostList = [[NSMutableArray alloc]init];
        }
        [subjectPostList enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            SubjectPost *post = [[SubjectPost alloc]initWithDictionary:obj];
            [self.subjectpostList addObject:post];
        }];
        
    }
    return self;
    
}

@end
