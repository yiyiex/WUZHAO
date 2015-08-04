//
//  WhatsGoingOn.m
//  testLogin
//
//  Created by yiyi on 14-11-29.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "WhatsGoingOn.h"


@implementation WhatsGoingOn


-(User *)photoUser
{
    if (!_photoUser)
    {
        _photoUser = [[User alloc]init];
    }
    return _photoUser;
}
-(NSMutableArray *)likeUserList
{
    if (!_likeUserList)
    {
        _likeUserList = [[NSMutableArray alloc]init];
    }
    return _likeUserList;
}
-(NSMutableArray *)imageUrlList
{
    if (!_imageUrlList)
    {
        _imageUrlList = [[NSMutableArray alloc]init];
    }
    return _imageUrlList;
}
-(NSMutableArray *)commentList
{
    if (!_commentList)
    {
        _commentList = [[NSMutableArray alloc]init];
    }
    return _commentList;
}
-(instancetype)initWithAttributes:(NSDictionary *)data
{
    self = [super init];
    if (!self)
    {
        return  nil;
    }
    self.postId =[(NSNumber *)[data objectForKey:@"post_id"] integerValue];
    self.photoUser.UserID = [(NSNumber *)[data objectForKey:@"user_id"]integerValue];
    self.photoUser.UserName = [data objectForKey:@"nick"];
    if ([data objectForKey:@"avatar"])
    {
        self.photoUser.avatarImageURLString = [data objectForKey:@"avatar"];
    }
    if ([data objectForKey:@"description"])
    {
        self.photoUser.selfDescriptions = [data objectForKey:@"description"];
    }
    if ([data objectForKey:@"followType"])
    {
        self.photoUser.followType = [(NSNumber *)[data objectForKey:@"followType"]integerValue];
    }
    
    self.postTime = [data objectForKey:@"create_time"];
    self.imageUrlString = [data objectForKey:@"photo"];
    if ([data objectForKey:@"photoList"])
    {
        [[data objectForKey:@"photoList"]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self.imageUrlList addObject:obj];
        }];
    }
    if ([data objectForKey:@"thought"])
    {
        self.imageDescription = [data objectForKey:@"thought"];
    }
    self.isLike = [(NSNumber *)[data objectForKey:@"isliked"] integerValue] == 1?true:false;
    if ([data objectForKey:@"isRecommend"] )
    {
        self.isRecommend = [(NSNumber *)[data objectForKey:@"isRecommend"] integerValue] == 1?true:false;
    }
    self.likeCount = [(NSNumber *)[data objectForKey:@"like_num"] integerValue];
    
    self.commentNum = [(NSNumber *)[data objectForKey:@"comment_num"]integerValue];
    
    if ([data objectForKey:@"poi_id"])
    {
        self.poiId = [(NSNumber *)[data objectForKey:@"poi_id"] integerValue];
    }
    if ([data objectForKey:@"poi_name"])
    {
        self.poiName = [data objectForKey:@"poi_name"];
    }
    
    
    if ([[data objectForKey:@"more_comments"] isEqualToString:@"false"])
    {
        self.hasMoreComments =  NO;
    }
    else
    {
        self.hasMoreComments = YES;
    }
    if ([data objectForKey:@"comment_list"])
    {
        NSArray *commentListInData = [data objectForKey:@"comment_list"];
        NSInteger commentNum = [(NSNumber *)[data objectForKey:@"comment_num"]integerValue];
        [self configureWithCommentList:commentListInData commentNum:commentNum];
        
    }
    
    if ([data objectForKey:@"likeUserList"])
    {
        NSArray *likeList = [data objectForKey:@"likeUserList"];
        [self configureIWithLikeList:likeList];
    }
    
    return self;
}

-(void)configureWithCommentList:(NSArray *)commentListInData commentNum:(NSInteger)num
{
    for (NSDictionary *comment in commentListInData)
    {
        Comment *commentItem = [[Comment alloc]initWithDictionary:comment];
        [self.commentList addObject:commentItem];
    }
}

-(void)configureIWithLikeList:(NSArray *)likeList
{
    
    if ([likeList count]>0)
    {
        for (NSDictionary *likeUserData in likeList)
        {
            User *likeUser = [[User alloc]initWithAttributes:likeUserData];
            [self.likeUserList addObject:likeUser];
        }
        
    }
}
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
   /* NSDictionary *nameStyle = @{@"userName":[WPAttributedStyleAction styledActionWithAction:^{
                                    [[[UIAlertView alloc] initWithTitle:@"提示" message:@"点击了" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil] show];
                                }],
                                @"address":[WPAttributedStyleAction styledActionWithAction:^{
                                    [[[UIAlertView alloc] initWithTitle:@"提示" message:@"点击了" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil] show];
                                }],
                                @"link": [UIColor greenColor]};*/
    
    
    WhatsGoingOn *item = [[WhatsGoingOn alloc] init];
    item.postId = 1;

    item.imageDescription = @"一人食";
    item.imageUrlString = [imageUrlStrings objectAtIndex:0];
    item.likeCount = 111;
    item.postTime = @"1天";
    item.comment = @"<userName>@小球！@#￥%……&*（）</userName> 我了就散了放假进口料件来烦死了快解放手机放大了！（*&&*@#……*@！（*sasfsdfasf”\n<seeMore>点击查看更多</seeMore>\n<userName>@一一</userName>水电费受身蹲伏撒方式地方舒服舒服十大发生的发撒发射点法撒旦范德萨发撒旦法水电费水电费水电费水电费阿斯蒂芬阿斯蒂芬撒地方撒地方圣达菲阿斯蒂芬啊是 2\b\n<userName>@test</userName>沙发啊分撒旦撒旦发撒旦法阿斯蒂芬撒旦防撒旦法是的发撒旦法撒旦防撒旦法撒旦发射点发的说法但是电风扇多少分水电费萨法撒旦发射点发撒旦发射点发舒服的 撒地方圣达菲 舒服阿斯蒂芬啊舒服舒服撒地方分手的萨芬撒旦发 舒服撒阿双方萨芬撒风多少分阿斯蒂芬 的撒分手发撒旦法适当第三附属发撒、\nsd d fsasfsad fsadf asdf sadf a 3\n\n<userName>user4</userName>testcommnet 4<address>www.douqiu.com</address>";
    item.commentList = @[@{@"avatorUrl":@"http://pic1.zhimg.com/9e2cf566532ec4cd24ce0f18b5282c79_l.jpg",@"username":@"xiaoqiu",@"content":@"lalalalallalal",@"time":@"12:22"},
        @{@"avatorUrl":@"http://pic4.zhimg.com/88db1114b_l.jpg",@"username":@"xiaoqiu2",@"content":@"lalalalallalal骚随机发送是foisjfosjoi 水电费sdfaoij 是的哦风景史丹佛水电费哦就是的哦飞机哦节 是的哦减肥哦就撒地方哦\n sdof josdojfoidsj ",@"time":@"12:22"},
        @{@"avatorUrl":@"http://pic4.zhimg.com/88db1114b_l.jpg",@"username":@"xiaoqiu3",@"content":@"lalalalallalal",@"time":@"12:22"},
        @{@"avatorUrl":@"http://pic1.zhimg.com/9e2cf566532ec4cd24ce0f18b5282c79_l.jpg",@"username":@"xiaoqiu4",@"content":@"lalalalallalal",@"time":@"12:22"},];
    
   // item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”<address>www.douqiu.com</address>" attributedStringWithStyleBook:nameStyle];
    
    [dataSource addObject:item];
    
    item = [[WhatsGoingOn alloc] init];
    item.postId = 2;
    item.imageUrlString = [imageUrlStrings objectAtIndex:1];
    item.likeCount = 1000;
    item.comment = @"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！\n”<address>www.douqiu.com</address>";
   // item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind <more>查看全部评论</more>" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    
    item = [[WhatsGoingOn alloc] init];
    item.imageUrlString = [imageUrlStrings objectAtIndex:2];
    item.likeCount = 1000;
    item.comment = @"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”<address>www.douqiu.com</address>";
   // item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    
    item = [[WhatsGoingOn alloc] init];
    item.postId = 14;
    item.imageUrlString = [imageUrlStrings objectAtIndex:3];
    item.likeCount = 1000;
    item.comment = @"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”<address>www.douqiu.com</address>";
    //item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    
    item = [[WhatsGoingOn alloc] init];
    item.postId = 3;
    item.imageUrlString = [imageUrlStrings objectAtIndex:4];
    item.likeCount = 1000;
    item.comment = @"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”<address>www.douqiu.com</address>";
   // item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    
    item = [[WhatsGoingOn alloc] init];
    item.postId = 4;
    item.imageUrlString = [imageUrlStrings objectAtIndex:0];
    item.likeCount = 1000;
    item.comment = @"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”<address>www.douqiu.com</address>";
   // item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    
    item = [[WhatsGoingOn alloc] init];
    item.postId = 5;
    item.imageUrlString = [imageUrlStrings objectAtIndex:1];
    item.likeCount = 1000;
    item.comment = @"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”<address>www.douqiu.com</address>";
    //item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    
    item = [[WhatsGoingOn alloc] init];
    item.postId = 6;
    item.imageUrlString = [imageUrlStrings objectAtIndex:2];
    item.likeCount = 1000;
    item.comment = @"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”<address>www.douqiu.com</address>";
    //item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    
    item = [[WhatsGoingOn alloc] init];
    item.postId = 7;
    item.imageUrlString = [imageUrlStrings objectAtIndex:3];
    item.likeCount = 1000;
    item.comment = @"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”<address>www.douqiu.com</address>";
    //item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    
    item = [[WhatsGoingOn alloc] init];
    item.postId = 8;
    item.imageUrlString = [imageUrlStrings objectAtIndex:4];
    item.likeCount = 100;
    item.comment = @"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”<address>www.douqiu.com</address>";
    //item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    item = [[WhatsGoingOn alloc] init];
    item.postId = 9;
    item.imageUrlString = [imageUrlStrings objectAtIndex:0];
    item.likeCount = 100;
    item.comment = @"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”<address>www.douqiu.com</address>";
    //item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    
    item = [[WhatsGoingOn alloc] init];
    item.postId = 10;
    item.imageUrlString = [imageUrlStrings objectAtIndex:1];
    item.likeCount = 100;
    item.comment = @"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”<address>www.douqiu.com</address>";
    //item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    
    item = [[WhatsGoingOn alloc] init];
    item.postId = 11;
    item.imageUrlString = [imageUrlStrings objectAtIndex:2];
    item.likeCount = 100;
    item.comment = @"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”<address>www.douqiu.com</address>";
    //item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    
    item = [[WhatsGoingOn alloc] init];
    item.postId = 12;
    item.imageUrlString = [imageUrlStrings objectAtIndex:3];
    item.likeCount = 100;
    item.comment = @"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”<address>www.douqiu.com</address>";
    //item.attributedComment = [@"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”\n\nThis is a game, please don't mind" attributedStringWithStyleBook:nameStyle];
    [dataSource addObject:item];
    
    item = [[WhatsGoingOn alloc] init];
    item.postId = 13;
    item.imageUrlString = [imageUrlStrings objectAtIndex:4];
    item.likeCount = 100;
    item.comment = @"<userName>@Arkadiusz Holko</userName>  ne generation plants the trees in whose shade another generation rests.One sows and another reaps。！”<address>www.douqiu.com</address>";
    //item.attributedComment = [@"<userName>@Jack</userName> 上课时，老师问小明怎么不玩手机啊，小明说：因为快递还没到，老师问“什么快递啊”？   这时教室门响了一个巨型充电宝+灯光+高音效音响+无线WIFI放到了小明面前，音乐灯光顿时响起，全班集体皮鞋高跟鞋换上嗨起，老师被无视的说怎么不叫上我\n\n<userName>@曾宪华</userName> 室友经常抱怨，20好几的人了还没有女朋友，连女孩手也没牵过，哪怕多做点春梦也行啊！于是我默默地出去买了一包春药和一瓶安眠药各拿一颗放入开水中溶了给他喝。大家说我这样做得对吗？" attributedStringWithStyleBook:nameStyle];
    
    [dataSource addObject:item];
    
    
    
    
    
    
    
    return  dataSource;
    
}
@end
