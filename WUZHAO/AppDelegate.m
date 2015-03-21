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

#import "PIOSearchAPI.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    // Override point for customization after application launch.
    [GlobalAppearance setGlobalAppearance];
    NSUserDefaults *userDefaul = [NSUserDefaults standardUserDefaults];
    NSLog(@"userdefault id%@",[userDefaul objectForKey:@"userId"]);
    NSLog(@"userdefault token%@",[userDefaul objectForKey:@"token"]);
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuid = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
    NSLog(@"uuid : %@",uuid);
    
    /*
    NSString *path = NSHomeDirectory();
    NSLog(@"NSHomeDirectory : %@",path);
    NSString *userName = NSUserName();
    NSLog(@"NSUserName : %@",userName);
    NSLog(@"root path for userName :%@",NSHomeDirectoryForUser(userName));

    ///*
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault objectForKey:@"userId"] &&[userDefault objectForKey:@"token"])
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MainTabBarViewController *mainTabBarController = [storyboard instantiateViewControllerWithIdentifier:@"mainTabBarViewController"];
        
    }*/
   // [[PIOSearchAPI sharedInstance]SearchAroundPIOWithLongitude:20.5 Latitude:140.5 whenComplete:^(NSDictionary *result) {
    //    NSLog(@"%@",result);
   // }];
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
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
