//
//  FilteredImageView.m
//  WUZHAO
//
//  Created by yiyi on 15/5/30.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "FilteredImageView.h"


@implementation FilteredImageView


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    EAGLContext *context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self.context = context;
    self.clipsToBounds = YES;
    self.cicontext = [CIContext contextWithEAGLContext:self.context];
    return self;
    
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    self.clipsToBounds = YES;
    self.context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self.cicontext = [CIContext contextWithEAGLContext:self.context];
    return self;
}

-(void)setFilter:(CIFilter *)filter
{
    _filter = filter;
    [self setNeedsDisplay];
}
-(void)setInputImage:(UIImage *)inputImage
{
    _inputImage = inputImage;
    [self setNeedsDisplay];
}

-(NSMutableArray *)preEffectFilters
{
    if (!_preEffectFilters)
    {
        _preEffectFilters = [[NSMutableArray alloc]init];
    }
    return _preEffectFilters;
}

-(CIImage *)getOutPutCIImage
{
    CIImage *outputCIImage;
    if (self.cicontext != nil && self.inputImage != nil && self.filter != nil)
    {
        CIImage *inputCIImage = [CIImage imageWithCGImage:[self.inputImage CGImage]];
        if (self.preEffectFilters.count == 0)
        {
            [self.filter setValue:inputCIImage forKey:kCIInputImageKey];
        }
        else
        {
            CIImage *preCIImage = inputCIImage;
            for (FilterParameters *preEffect in self.preEffectFilters)
            {
                CIFilter *filter = [CIFilter filterWithName:preEffect.filterName];
                [preEffect.otherInputs enumerateObjectsUsingBlock:^(NSDictionary *input, NSUInteger idx, BOOL *stop) {
                    [filter setValue:input[@"value"] forKey:input[@"key"]];
                }];
                [filter setValue:preCIImage forKey:kCIInputImageKey];
                [filter setValue:[NSNumber numberWithFloat:preEffect.currentValue] forKey:preEffect.key];
                preCIImage = filter.outputImage;
            }
            [self.filter setValue:preCIImage forKey:kCIInputImageKey];
        }
        outputCIImage = self.filter.outputImage;
    }
    return outputCIImage;
}

-(void)deletePreEffectFilter:(FilterParameters *)parameters
{
    for (FilterParameters *preEffectParameter in self.preEffectFilters)
    {
        if (preEffectParameter.filterName == parameters.filterName && preEffectParameter.key == parameters.key)
        {
            [self.preEffectFilters removeObject:preEffectParameter];
        }
        break;
    }
    [self setNeedsDisplay];
}

-(UIImage *)outputImage
{
    
    if (self.filter && self.inputImage)
    {
        CIImage *inputCIImage = [CIImage imageWithCGImage:[self.inputImage CGImage]];
        CIImage *outputCIImage = [self getOutPutCIImage];
        CGImageRef imageRef = [self.cicontext createCGImage:outputCIImage fromRect:[inputCIImage extent]];
        UIImage *outputImgae = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        return outputImgae;
    }
    return nil;
}

-(void)drawRect:(CGRect)rect
{
    CIImage *inputCIImage = [CIImage imageWithCGImage:[self.inputImage CGImage]];
    CIImage *outputCIImage = [self getOutPutCIImage];
    if (outputCIImage)
    {
        [self clearBackground];
        CGRect inputBounds = [inputCIImage extent];
        CGRect drawableBounds = CGRectMake(0, 0, self.drawableWidth, self.drawableHeight);
        CGRect targetBounds = [self imageBoundsForContentModeFromRect:inputBounds toRect:drawableBounds];
        [self.cicontext drawImage:outputCIImage inRect:targetBounds fromRect:inputBounds];
        
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsDisplay];
}

-(void)clearBackground
{
    CGFloat r = 0;
    CGFloat g = 0;
    CGFloat b = 0;
    CGFloat a = 0;
    if ( self.backgroundColor )
    {
        [self.backgroundColor getRed:&r green:&g blue:&b alpha:&a];
    }
    glClearColor(r, g, b, a);
    glClear( GL_COLOR_BUFFER_BIT);
    
}

-(CGRect)aspectFillFromRect:(CGRect)fromRect toRect:(CGRect)toRect
{
    float fromAspectRatio = fromRect.size.width /fromRect.size.height;
    float toAspectRatio = toRect.size.width / toRect.size.height;
    CGRect fitRect = toRect;
    if (fromAspectRatio > toAspectRatio)
    {
        fitRect.size.width = toRect.size.height *fromAspectRatio;
        fitRect.origin.x += (toRect.size.width - fitRect.size.width) *0.5;
    }
    else
    {
        fitRect.size.height = toRect.size.width /fromAspectRatio;
        fitRect.origin.y += (toRect.size.height -fitRect.size.height) *0.5;
    }
    return CGRectIntegral(fitRect);
}
-(CGRect)aspectFitFromRect:(CGRect)fromRect toRect:(CGRect)toRect
{
    float fromAspectRatio = fromRect.size.width /fromRect.size.height;
    float toAspectRatio = toRect.size.width / toRect.size.height;
    CGRect fitRect = toRect;
    if (fromAspectRatio > toAspectRatio)
    {
        fitRect.size.height = toRect.size.width *fromAspectRatio;
        fitRect.origin.y += (toRect.size.height - fitRect.size.height) *0.5;
    }
    else
    {
        fitRect.size.width = toRect.size.height /fromAspectRatio;
        fitRect.origin.x += (toRect.size.width -fitRect.size.width) *0.5;
    }
    return CGRectIntegral(fitRect);
}

-(CGRect)imageBoundsForContentModeFromRect:(CGRect)fromRect toRect:(CGRect)toRect
{
    switch (self.contentMode) {
        case UIViewContentModeScaleAspectFill:
            return [self aspectFillFromRect:fromRect toRect:toRect];
        case UIViewContentModeScaleAspectFit:
            return [self aspectFitFromRect:fromRect toRect:toRect];
        default:
            return fromRect;
    }
}

#pragma mark - filterSliderView Delegate

-(void)filterSliderValueDidChange:(FilterParameters *)parameters
{
    for (FilterParameters *preEffectParameter in self.preEffectFilters)
    {
        if (preEffectParameter.filterName == parameters.filterName && preEffectParameter.key == parameters.key)
        {
            preEffectParameter.currentValue = parameters.currentValue;
        }
        break;
    }
    [self setNeedsDisplay];
}


@end
