//
//  ApplicationUtility.m
//  WUZHAO
//
//  Created by yiyi on 15/5/14.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "ApplicationUtility.h"
#import "macro.h"

@implementation ApplicationUtility

+(void)setApplicationIconBadgeWithNum:(NSInteger)number
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8"))
    {
        UIUserNotificationType myType = UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
        UIUserNotificationSettings *mySetting = [UIUserNotificationSettings settingsForTypes:myType categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySetting];
    }else{
        UIRemoteNotificationType myType = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myType];
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:number];
}
@end
