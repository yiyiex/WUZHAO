//
//  AppDelegate.m
//  WUZHAO
//
//  Created by yiyi on 14-12-11.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "AppDelegate.h"
#import "GlobalAppearance.h"

#import "MainTabBarViewController.h"
#import "LaunchViewController.h"

#import "QDYHTTPClient.h"
#import "POISearchAPI.h"

#import "ApplicationUtility.h"

#import "macro.h"
#import "BPush.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "UMSocialSinaHandler.h"
#import "UMSocialQQHandler.h"

#import <Bugly/CrashReporter.h>

@interface AppDelegate ()<BPushDelegate>
{
    NSString *myDeviceToken;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [GlobalAppearance setGlobalAppearance];
    [[CrashReporter sharedInstance]installWithAppId:@"900006753"];
    [[CrashReporter sharedInstance]enableLog:YES];
    
    if (launchOptions)
    {
        NSDictionary * userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if(userInfo)
        {
            NSInteger  noticeType  = [[userInfo valueForKey:@"noticeType"]integerValue];
            if (noticeType == 1 || noticeType == 2 ||noticeType == 3 || noticeType ==4)
            {
                //3-notice tab
                [[NSUserDefaults standardUserDefaults]setObject:@3 forKey:@"launchIndex"];
                //0 -- system notice tab  1-- private letter tab
                [[NSUserDefaults standardUserDefaults]setObject:@0 forKey:@"noticeIndex"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
            }
            else if (noticeType == 5)
            {
                //3-notice tab
                [[NSUserDefaults standardUserDefaults]setObject:@3 forKey:@"launchIndex"];
                //0 -- system notice tab  1-- private letter tab
                [[NSUserDefaults standardUserDefaults]setObject:@1 forKey:@"noticeIndex"];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }
            if (noticeType == 6)
            {
                //3-notice tab
                [[NSUserDefaults standardUserDefaults]setObject:@3 forKey:@"launchIndex"];
                //0 -- system notice tab  1-- private letter tab
                [[NSUserDefaults standardUserDefaults]setObject:@0 forKey:@"noticeIndex"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
            }
            [[QDYHTTPClient sharedInstance] getLatestNoticeNumber];
        }
        
    }
    else
        
    {
        [[QDYHTTPClient sharedInstance] getLatestNoticeNumber];
    }
    //初始化百度推送
    NSString *pushKey= @"MXD0PZ8Qt9LD9ia3PWf41PSL";
   // [BPush registerChannel:launchOptions apiKey:pushKey pushMode:BPushModeDevelopment isDebug:YES];
    [BPush registerChannel:launchOptions apiKey:pushKey pushMode:BPushModeProduction isDebug:NO];
    [BPush setDelegate:self]; // 必须。参数对象必须实现onMethod: response:方法，本示例中为self
    
    // [BPush setAccessToken:@"3.ad0c16fa2c6aa378f450f54adb08039.2592000.1367133742.282335-602025"];  // 可选。api key绑定时不需要，也可在其它时机调用
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)])
    {
        UIUserNotificationSettings
        *settings = [UIUserNotificationSettings settingsForTypes: (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound) categories:nil];
        [application registerForRemoteNotifications];
        [application registerUserNotificationSettings:settings];
        
        
     
    }
    
    //设置友盟sdk key
    [UMSocialData setAppKey:@"55a5c86567e58ecd13000507"];
    [UMSocialWechatHandler setWXAppId:@"wx439fd7dddb2fccd0" appSecret:@"745a38ee5cbad3948d7b353e24f1e637" url:nil];
   //  [UMSocialSinaSSOHandler openNewSinaSSOWithRedirectURL:nil];
   // [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    [UMSocialQQHandler setQQWithAppId:@"1104705877" appKey:@"xaYJeCHCVxI3yVT1" url:@"http://placeapp.cn"];
    [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ,UMShareToQzone,UMShareToWechatSession,UMShareToWechatTimeline]];
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}
-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [UMSocialSnsService handleOpenURL:url];
}
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [UMSocialSnsService handleOpenURL:url];
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[QDYHTTPClient sharedInstance] getLatestNoticeNumber];
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[QDYHTTPClient sharedInstance] getLatestNoticeNumber];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [BPush registerDeviceToken:deviceToken]; // 必须
    
    myDeviceToken  = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:myDeviceToken forKey:@"deviceToken"];
    [userDefaults synchronize];
    [BPush bindChannel]; // 必须。可以在其它时机调用，只有在该方法返回（通过onMethod:response:回调）绑定成功时，app才能接收到Push消息。一个app绑定成功至少一次即可（如果access token变更请重新绑定）。
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{

}

-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
    
}

-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    
}


// 必须，如果正确调用了setDelegate，在bindChannel之后，结果在这个回调中返回。
// 若绑定失败，请进行重新绑定，确保至少绑定成功一次
- (void) onMethod:(NSString*)method response:(NSDictionary*)data
{
    if ([BPushRequestMethodBind isEqualToString:method])
    {
        NSDictionary* res = [[NSDictionary alloc] initWithDictionary:data];
        
        //NSString *appid = [res valueForKey:BPushRequestAppIdKey];
        NSString *userid = [res valueForKey:BPushRequestUserIdKey];
        NSString *channelid = [res valueForKey:BPushRequestChannelIdKey];
        //int returnCode = [[res valueForKey:BPushRequestErrorCodeKey] intValue];
        //NSString *requestid = [res valueForKey:BPushRequestRequestIdKey];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:userid forKey:@"bpUserId"];
        [userDefaults setObject:channelid forKey:@"bpChannelId"];
        [userDefaults setObject:myDeviceToken forKey:@"deviceToken"];
        [userDefaults synchronize];
        [[QDYHTTPClient sharedInstance]registerBPushWithBpUserId:userid bpChannelId:channelid deviceToken:myDeviceToken whenComplete:^(NSDictionary *returnData) {
            if ([returnData objectForKey:@"data"])
            {
                NSLog(@"register to baidu push success");
            }
            else if ([returnData objectForKey:@"error"])
            {
                NSLog(@"register to baidu push error");
            }
        }];

    }
}
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //处理接受的消息
    [BPush handleNotification:userInfo];
    UILocalNotification *localNotification = [[UILocalNotification alloc]init];
    localNotification.userInfo = userInfo;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.alertBody = [[userInfo objectForKey:@"aps"]objectForKey:@"alert"];
    localNotification.fireDate = [NSDate date];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    [[QDYHTTPClient sharedInstance] getLatestNoticeNumber];
    if(userInfo)
    {
        //通知notice页面更新
        NSInteger  noticeType  = [[userInfo valueForKey:@"noticeType"]integerValue];
        if (noticeType == 1 || noticeType == 2 ||noticeType == 3 || noticeType ==4)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"updateNoticePage" object:nil userInfo:@{@"type":@"notice"}];
            
        }
        else if (noticeType == 5)
        {
           [[NSNotificationCenter defaultCenter]postNotificationName:@"updateNoticePage" object:nil userInfo:@{@"type":@"message"}];
        }
    }
}




@end
