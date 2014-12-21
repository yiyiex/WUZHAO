//
//  SearchViewController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-15.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "SearchViewController.h"
#import "CommonContainerViewController.h"

#define SEGUEFIRST @"segueFirst"
#define SEGUESECOND @"segueSecond"

@interface SearchViewController ()
@property (nonatomic, strong) CommonContainerViewController *containerViewController;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedContainer"])
    {
        self.containerViewController = segue.destinationViewController;
    }
}

-(CommonContainerViewController *)containerViewController
{
    if (!_containerViewController)
    {
        _containerViewController = [[CommonContainerViewController alloc]initWithChildren:@[SEGUEFIRST,SEGUESECOND]];
        
    }
    return _containerViewController;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)segmentIndexChanged:(id)sender {
    NSString *swapIdentifier ;
    switch (self.segmentControl.selectedSegmentIndex) {
        case 0:
            swapIdentifier = SEGUEFIRST;
            break;
        case 1:
            swapIdentifier = SEGUESECOND;
            break;
        default:
            swapIdentifier = SEGUEFIRST;
            break;
    }
    [self.containerViewController swapViewControllersWithIdentifier:swapIdentifier];
}
@end
