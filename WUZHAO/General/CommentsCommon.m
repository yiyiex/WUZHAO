//
//  CommentsCommon.m
//  WUZHAO
//
//  Created by yiyi on 15-1-15.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "CommentsCommon.h"

#import "WPAttributedStyleAction.h"


@implementation CommentsCommon

-(NSDictionary *)createCommentStyleWithAttributeDic:(NSDictionary *)dic
{
    NSMutableDictionary * styleDic = [[NSMutableDictionary alloc]init];
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [styleDic setValuesForKeysWithDictionary:[self createCommentStyleForAttribute:key withAction:obj]];
    }];
    return styleDic;
}

-(NSDictionary *)createCommentStyleForAttribute:(NSString *)attribute withAction:(void(^)(void))action
{
    NSDictionary *nameStyle = [[NSDictionary alloc]init];
    [nameStyle setValue:[WPAttributedStyleAction styledActionWithAction:action]
                 forKey:attribute];
    return  nameStyle;
}
@end


