//
//  MainTabBarController.m
//  testLogin
//
//  Created by yiyi on 14-11-25.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "MainTabBarController.h"
#import "AFHTTPAPIClient.h"
@implementation MainTabBarController

-(void)viewDidLoad
{
    if (![[AFHTTPAPIClient sharedInstance]IsAuthenticated])
    {
        NSLog(@"*****not Login****");
        self.navigationItem.hidesBackButton = YES;
       // [self performSegueWithIdentifier:@"ToLogin" sender:self];

    }
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ToLogin"])
    {
        
    }
    else if ([[segue identifier] isEqualToString:@"LoginSuccess"])
    {
        
    }
}

@end
