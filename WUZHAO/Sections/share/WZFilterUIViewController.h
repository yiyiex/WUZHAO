//  滤镜界面
//  WZFilterUIViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/1/28.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WZFilterUIViewControllerDelegate;

@interface WZFilterUIViewController : UIViewController

@property (nonatomic,strong) UIImage *originalImage;

@property (nonatomic,strong) id <WZFilterUIViewControllerDelegate> delegate;



-(instancetype) initWithImage:(UIImage *)image delegate:(id<WZFilterUIViewControllerDelegate>)delegate;

@end

@protocol WZFilterUIViewControllerDelegate <NSObject>

-(void)FilterController:(WZFilterUIViewController*)controller didEndFilterThePhoto:(UIImage *)newPhoto;

@end
