//
//  CommonContainerViewController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-15.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "CommonContainerViewController.h"

@interface CommonContainerViewController ()
@property (nonatomic,strong) NSString * currentSegueIdentifier;
@property (nonatomic) BOOL transitionInProgress;
@end

@implementation CommonContainerViewController
#define initSegue @"SegueFirst"
- (instancetype)initWithChildren:(NSArray *)childrenName
{
    self = [super init];
    if (self)
    {
       [self setChildrenName:childrenName];
    }
    self.CurrentSegueIdentifier = [self.ChildrenName firstObject];
    return  self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self performSegueWithIdentifier:self.currentSegueIdentifier sender:self];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setChildrenName:(NSArray *)ChildrenName
{
    if (!_ChildrenName)
    {
        _ChildrenName = ChildrenName;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:initSegue])
    {
        if (self.childViewControllers.count > 0)
        {
            [self swapFromViewController:[self.childViewControllers firstObject] toViewController:segue.destinationViewController];
        }
        else
        {
            [self addChildViewController:segue.destinationViewController];
            UIView *destView = ((UIViewController *)segue.destinationViewController).view;
            destView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            [self.view addSubview:destView];
            [segue.destinationViewController didMoveToParentViewController:self];
            
        }
    }
    else{
        [self swapFromViewController:[self.childViewControllers firstObject] toViewController:segue.destinationViewController];
    }
}
-(void)swapFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
{
    toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    
    [self transitionFromViewController:fromViewController toViewController:toViewController duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished){
        if (finished)
        {
            [fromViewController removeFromParentViewController];
            [toViewController didMoveToParentViewController:self];
            self.transitionInProgress = NO;
        }
    }];
}
-(void)swapViewControllersWithIdentifier:(NSString *)identifier
{
    if (self.transitionInProgress)
    {
        return;
    }
    self.transitionInProgress = YES;
    self.currentSegueIdentifier =identifier;
    NSLog(@"swap with identifier %@",identifier);
    
    [self performSegueWithIdentifier:self.currentSegueIdentifier sender:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
