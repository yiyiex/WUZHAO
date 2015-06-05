//
//  ViewContainerScrollViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/5/19.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "ViewContainerScrollViewController.h"

@interface ViewContainerScrollViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *contentViews;
@property (nonatomic) NSInteger activeIndex;



@end

@implementation ViewContainerScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)initControl
{
    self.contentViews = [[NSMutableArray alloc]init];
    for (int i = 0;i <3 ;i++)
    {
        [self.contentViews addObject:[NSNull null]];
    }
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame) * 3, FLT_MAX);
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.delegate = self;
    [self.view addSubview: self.scrollView];
    
    
}

-(void)reloadView
{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (int i = 0; i < 3; i ++)
    {

    }

    

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
