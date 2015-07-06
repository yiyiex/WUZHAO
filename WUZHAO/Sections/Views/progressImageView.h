//
//  progressImageView.h
//  WUZHAO
//
//  Created by yiyi on 15/7/2.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface progressImageView : UIImageView

@property (nonatomic, strong) UIActivityIndicatorView *aiv;
@property (nonatomic, strong) UIView *maskView;

-(void)setProgress:(float)progress;

-(void)setfinishState;

-(void)setErrorState;
@end
