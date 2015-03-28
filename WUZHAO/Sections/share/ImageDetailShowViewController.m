//
//  ImageDetailShowViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/3/28.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "ImageDetailShowViewController.h"
#import "macro.h"

@interface ImageDetailShowViewController ()

@end

@implementation ImageDetailShowViewController
@synthesize imageToShow;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView
{
    [self.view setBackgroundColor:rgba_WZ(23,24,26,0.9)];
    [self addViewGestureRecognizer];
    self.detailImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, (WZ_APP_SIZE.height -WZ_APP_SIZE.width)/2, WZ_APP_SIZE.width, WZ_APP_SIZE.width)];
    [self.view addSubview:self.detailImageView];
    [self.detailImageView setImage:self.imageToShow];
}
-(void)addViewGestureRecognizer
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeTheView:)];
    [self.view addGestureRecognizer:tapGesture];
    [self.view setUserInteractionEnabled:YES];
}
-(void)closeTheView:(UITapGestureRecognizer *)gesture
{
    [self dismissViewControllerAnimated:YES completion:nil];
    //self dismissViewControllerAnimated:<#(BOOL)#> completion:<#^(void)completion#>
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
