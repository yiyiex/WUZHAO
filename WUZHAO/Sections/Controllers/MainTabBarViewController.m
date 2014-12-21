//
//  MainTabBarViewController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-19.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "HomeTableViewController.h"
@implementation MainTabBarViewController 


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@""])
    {
        
    }
}




#pragma mark =========controllers delegate============
-(void)endPostImageInfo
{
    NSLog(@"finish post ,go back to the home table view");
    [self setSelectedViewController:[self.tabBarController.viewControllers objectAtIndex:0]];
}

@end
