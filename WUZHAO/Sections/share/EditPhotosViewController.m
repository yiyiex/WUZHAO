//
//  EditPhotosViewController.m
//  WUZHAO
//
//  Created by yiyi on 14-12-19.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "EditPhotosViewController.h"
#import "CLImageEditor.h"

@implementation EditPhotosViewController

-(void)viewDidLoad
{
    if (self.editImage)
    {
        self.editImageView.image = self.editImage;
    }
    if (self.editImageView.image)
    {
        NSLog(@"begin edit");
        CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:self.editImageView.image delegate:self];
        [self presentViewController:editor animated:YES completion:nil];
    }
}
@end
