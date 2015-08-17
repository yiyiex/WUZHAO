//
//  VoteAlertView.m
//  WUZHAO
//
//  Created by yiyi on 15/8/17.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//



#import "VoteAlertView.h"
#import "QDYHTTPClient.h"
#import "macro.h"
typedef NS_ENUM(NSUInteger, VOTETYPE)
{
    VOTETYPE_VOTE = 1,
    VOTETYPE_FEEDBACK = 2,
    VOTETYPE_CANCEL = 3
};

@interface VoteAlertView()
@property (nonatomic, strong) UIAlertAction *voteAction;
@property (nonatomic, strong) UIAlertAction *feedBackAction;
@property (nonatomic, strong) UIAlertAction *cancelAction;
@end
@implementation VoteAlertView
-(instancetype)init
{
    self = [super init];
    if (self)
    {
    
        self.title = @"觉得Place怎么样？";
        NSMutableAttributedString *attTitle = [[NSMutableAttributedString alloc] initWithString:@"觉得Place怎么样？"];
        [attTitle addAttribute:NSFontAttributeName
                      value:WZ_FONT_TITLE
                      range:NSMakeRange(0, attTitle.length)];
        [attTitle addAttribute:NSForegroundColorAttributeName value:THEME_COLOR_FONT_GREY range:NSMakeRange(0, attTitle.length)];
        [self setValue:attTitle forKey:@"attributedTitle"];

        [self addAction:self.voteAction];
        [self addAction:self.feedBackAction];
        [self addAction:self.cancelAction];
    }
    return self;
}

-(UIAlertAction *)voteAction
{
    if (!_voteAction) {
       _voteAction = [UIAlertAction actionWithTitle:@"还不错，给个评价" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
           //TO DO
           //1.go to vote page   2. not alert again
           NSInteger userId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
           [[QDYHTTPClient sharedInstance]setUserRateStatusWithUserId:userId voteStatus:VOTETYPE_VOTE whenComplete:^(NSDictionary *result) {
               NSLog(@"%@",result);
           }];
           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/place-biao-ji-dian-fen-xiang/id989677123?mt=8"]];
           
       }];
    }
    return _voteAction;
}
-(UIAlertAction *)feedBackAction
{
    if (!_feedBackAction)
    {
        _feedBackAction = [UIAlertAction actionWithTitle:@"我要吐槽" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //TO DO
           // 1.go to feedbackPage  2. not alert again
            NSInteger userId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
            [[QDYHTTPClient sharedInstance]setUserRateStatusWithUserId:userId voteStatus:VOTETYPE_FEEDBACK whenComplete:^(NSDictionary *result) {
                NSLog(@"%@",result);
            }];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"showFeedbackPage" object:nil];
        }];
    }
    return _feedBackAction;
}
-(UIAlertAction *)cancelAction
{
    if (!_cancelAction)
    {
        _cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSInteger userId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
            [[QDYHTTPClient sharedInstance]setUserRateStatusWithUserId:userId voteStatus:VOTETYPE_CANCEL whenComplete:^(NSDictionary *result) {
                NSLog(@"%@",result);
            }];
            [self removeFromParentViewController];
        }];
    }
    return _cancelAction;
}
@end
