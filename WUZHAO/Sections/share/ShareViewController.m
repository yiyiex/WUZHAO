//
//  MineViewController.m
//  Dtest3
//
//  Created by yiyi on 14-10-29.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "ShareViewController.h"
#import "CLImageEditor.h"

@interface ShareViewController ()<CLImageEditorDelegate, CLImageEditorTransitionDelegate ,CLImageEditorThemeDelegate>

@end

@implementation ShareViewController
@synthesize editImageView;
@synthesize editScrollView;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  /*  if (editImageView.image)
    {
        CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:editImageView.image delegate:self];
        [self presentViewController:editor animated:YES completion:nil];
        
    }
    else
    {
        
    }*/
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
