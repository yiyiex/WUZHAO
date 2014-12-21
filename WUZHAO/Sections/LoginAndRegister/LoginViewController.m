//
//  ViewController.m
//  testLogin
//
//  Created by yiyi on 14-11-24.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "LoginViewController.h"
#import "AFHTTPAPIClient.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    if ( [[AFHTTPAPIClient sharedInstance] IsAuthenticated])
    {
        [self performSegueWithIdentifier:@"HasLogin" sender:self];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)LoginButtonPressed:(id)sender
{
    
   /* NSURLSessionDataTask *task = [[AFHTTPAPIClient sharedInstance]LoginWithUserName:self.UserNameField.text password:self.PasswordField.text complete:^
                                  {
                                      if ( [[AFHTTPAPIClient sharedInstance] IsAuthenticated])
                                      {
                                          [self performSegueWithIdentifier:@"HasLogin" sender:self];
                                      }
                                      else
                                      {
                                          
                                      }
                                  }];

   */
    NSLog(@"get login button pressed");
    [self performSegueWithIdentifier:@"HasLogin" sender:self];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    
}



@end
