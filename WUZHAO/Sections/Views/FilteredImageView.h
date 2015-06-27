//
//  FilteredImageView.h
//  WUZHAO
//
//  Created by yiyi on 15/5/30.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <CoreImage/CoreImage.h>
#import <Foundation/Foundation.h>
#import "FilterSliderView.h"

@interface FilteredImageView : GLKView <FilterSliderDelegate>
@property (nonatomic, strong) CIContext *cicontext;
@property (nonatomic, strong) CIFilter *filter;
@property (nonatomic, strong) UIImage *inputImage;
@property (nonatomic, strong) UIImage *outputImage;

@property (nonatomic, strong) NSMutableArray *preEffectFilters;

-(void)deletePreEffectFilter:(FilterParameters *)parameters;
@end
