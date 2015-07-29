//
//  PrivateLetterDetailViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/7/25.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrivateLetter.h"

@interface PrivateLetterDetailViewController : UIViewController

@property (nonatomic, strong) Conversation *conversation;
@property (nonatomic) BOOL shouldRefreshData;

-(void)getLatestConversation;

@end
