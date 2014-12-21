//
//  WhatsGoingOn.m
//  testLogin
//
//  Created by yiyi on 14-11-29.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "WhatsGoingOn.h"
#import "WPAttributedStyleAction.h"
#import "NSString+WPAttributedMarkup.h"

@implementation WhatsGoingOn



+ (NSArray *) newDataSource
{
    NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    NSArray *imageUrlStrings= [NSArray arrayWithObjects:
                @"http://img3.douban.com/view/photo/photo/public/p2206858462.jpg",
                @"http://img3.douban.com/view/photo/photo/public/p2206860902.jpg",
                @"http://img3.douban.com/view/photo/photo/public/p2206861122.jpg",
                @"http://img3.douban.com/view/photo/photo/public/p2206861334.jpg",
                @"http://img5.douban.com/view/photo/photo/public/p2206861688.jpg",nil];

    //评论user的展示和交互
    //评论内容自定义展现、交互、LINK内容
    NSDictionary *nameStyle = @{@"body":[UIFont fontWithName:@"HelveticaNeue" size:16],
                                @"userName":[WPAttributedStyleAction styledActionWithAction:^{
                                    [[[UIAlertView alloc] initWithTitle:@"提示" message:@"点击了" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil] show];
                                }],
                                @"link": [UIColor blueColor]};
    
    WhatsGoingOn *item = [[WhatsGoingOn alloc] init];
    item.imageUrlString = [imageUrlStrings objectAtIndex:0];
    item.likeCount = @"525";
    item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    
    [dataSource addObject:item];
    
    item = [[WhatsGoingOn alloc] init];
    item.imageUrlString = [imageUrlStrings objectAtIndex:1];
    item.likeCount = @"1000";
    item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    
    item = [[WhatsGoingOn alloc] init];
    item.imageUrlString = [imageUrlStrings objectAtIndex:2];
    item.likeCount = @"1000";
    item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    
    item = [[WhatsGoingOn alloc] init];
    item.imageUrlString = [imageUrlStrings objectAtIndex:3];
    item.likeCount = @"1000";
    item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    
    item = [[WhatsGoingOn alloc] init];
    item.imageUrlString = [imageUrlStrings objectAtIndex:4];
    item.likeCount = @"1000";
    item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    
    item = [[WhatsGoingOn alloc] init];
    item.imageUrlString = [imageUrlStrings objectAtIndex:0];
    item.likeCount = @"1000";
    item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    
    item = [[WhatsGoingOn alloc] init];
    item.imageUrlString = [imageUrlStrings objectAtIndex:1];
    item.likeCount = @"1000";
    item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    
    item = [[WhatsGoingOn alloc] init];
    item.imageUrlString = [imageUrlStrings objectAtIndex:2];
    item.likeCount = @"1000";
    item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    
    item = [[WhatsGoingOn alloc] init];
    item.imageUrlString = [imageUrlStrings objectAtIndex:3];
    item.likeCount = @"1000";
    item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    
    item = [[WhatsGoingOn alloc] init];
    item.imageUrlString = [imageUrlStrings objectAtIndex:4];
    item.likeCount = @"1000";
    item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    item = [[WhatsGoingOn alloc] init];
    item.imageUrlString = [imageUrlStrings objectAtIndex:0];
    item.likeCount = @"1000";
    item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    item = [[WhatsGoingOn alloc] init];
    item.imageUrlString = [imageUrlStrings objectAtIndex:1];
    item.likeCount = @"1000";
    item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    
    item = [[WhatsGoingOn alloc] init];
    item.imageUrlString = [imageUrlStrings objectAtIndex:2];
    item.likeCount = @"1000";
    item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    
    item = [[WhatsGoingOn alloc] init];
    item.imageUrlString = [imageUrlStrings objectAtIndex:3];
    item.likeCount = @"1000";
    item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    
    item = [[WhatsGoingOn alloc] init];
    item.imageUrlString = [imageUrlStrings objectAtIndex:4];
    item.likeCount = @"1000";
    item.attributedComment = [@"<userName>@Jack</userName> 上课时，老师问小明怎么不玩手机啊，小明说：因为快递还没到，老师问“什么快递啊”？   这时教室门响了一个巨型充电宝+灯光+高音效音响+无线WIFI放到了小明面前，音乐灯光顿时响起，全班集体皮鞋高跟鞋换上嗨起，老师被无视的说怎么不叫上我\n\n<userName>@曾宪华</userName> 室友经常抱怨，20好几的人了还没有女朋友，连女孩手也没牵过，哪怕多做点春梦也行啊！于是我默默地出去买了一包春药和一瓶安眠药各拿一颗放入开水中溶了给他喝。大家说我这样做得对吗？" attributedStringWithStyleBook:nameStyle];
    
    [dataSource addObject:item];
    
    
    
    
    
    
    
    return  dataSource;
    
}
@end
