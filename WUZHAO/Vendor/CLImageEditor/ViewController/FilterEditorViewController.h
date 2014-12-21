//
//  FilterEditorViewController.h
//  testLogin
//
//  Created by yiyi on 14-11-29.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLImageEditor.h"

@interface FilterEditorViewController : CLImageEditor
<UIScrollViewDelegate, UIBarPositioningDelegate>
{
    IBOutlet __weak UINavigationBar *_navigationBar;
    IBOutlet __weak UIScrollView *_scrollView;
}
@property (nonatomic, strong) UIImageView  *imageView;
@property (nonatomic, weak) IBOutlet UIScrollView *menuView;
@property (nonatomic, readonly) UIScrollView *scrollView;

- (IBAction)pushedCloseBtn:(id)sender;
- (IBAction)pushedFinishBtn:(id)sender;


- (id)initWithImage:(UIImage*)image;


@end
