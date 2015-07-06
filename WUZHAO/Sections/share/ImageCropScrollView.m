//
//  ImageCropScrollView.m
//  WUZHAO
//
//  Created by yiyi on 15/7/1.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//
#import "ImageCropScrollView.h"
#import "PhotoCommon.h"
#import "UIImage+Resize.h"
#define rad(angle) ((angle) / 180.0 * M_PI)

@interface ImageCropScrollView ()<UIScrollViewDelegate>
{
    CGSize _imageSize;
}
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation ImageCropScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.alwaysBounceHorizontal = YES;
        self.alwaysBounceVertical = YES;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
    }
    return self;
}



- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    self.imageView.frame = frameToCenter;
}

/**
 *  cropping image not just snapshot , inpired by https://github.com/gekitz/GKImagePicker
 *
 *  @return image cropped
 */
- (UIImage *)capture
{
    /*
    CGRect visibleRect = [self _calcVisibleRectForCropArea];//caculate visible rect for crop
    CGAffineTransform rectTransform = [self _orientationTransformedRectOfImage:self.imageView.image];//if need rotate caculate
    visibleRect = CGRectApplyAffineTransform(visibleRect, rectTransform);
    
    CGImageRef ref = CGImageCreateWithImageInRect([self.imageView.image CGImage], visibleRect);//crop
    UIImage* cropped = [[UIImage alloc] initWithCGImage:ref scale:self.imageView.image.scale orientation:self.imageView.image.imageOrientation] ;
    CGImageRelease(ref);
    return cropped;
     */
    CGRect visibleRect = [self _calcVisibleRectForCropArea];//caculate visible rect for crop
    CGAffineTransform rectTransform = [self _orientationTransformedRectOfImage:self.unfilteredImage];//if need rotate caculate
    visibleRect = CGRectApplyAffineTransform(visibleRect, rectTransform);
    
    CGImageRef ref = CGImageCreateWithImageInRect([self.unfilteredImage CGImage], visibleRect);//crop
    UIImage* cropped = [[UIImage alloc] initWithCGImage:ref scale:self.imageView.image.scale orientation:self.unfilteredImage.imageOrientation] ;
    CGImageRelease(ref);
    return cropped;
}



static CGRect TWScaleRect(CGRect rect, CGFloat scale)
{
    return CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
}


-(CGRect)_calcVisibleRectForCropArea{
    
    CGFloat sizeScale = self.imageView.image.size.width / self.imageView.frame.size.width;
    sizeScale *= self.zoomScale;
    CGRect visibleRect = [self convertRect:self.bounds toView:self.imageView];
    return visibleRect = TWScaleRect(visibleRect, sizeScale);
}

- (CGAffineTransform)_orientationTransformedRectOfImage:(UIImage *)img
{
    CGAffineTransform rectTransform;
    switch (img.imageOrientation)
    {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -img.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -img.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -img.size.width, -img.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    
    return CGAffineTransformScale(rectTransform, img.scale, img.scale);
}


- (void)displayImage:(UIImage *)image
{
    // clear the previous image
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    
    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;
    
    // make a new UIImageView for the new image
    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.imageView.clipsToBounds = NO;
    [self addSubview:self.imageView];
    
    CGRect frame = self.imageView.frame;
    if (image.size.height > image.size.width) {
        frame.size.width = self.bounds.size.width;
        frame.size.height = (self.bounds.size.width / image.size.width) * image.size.height;
    } else {
        frame.size.height = self.bounds.size.height;
        frame.size.width = (self.bounds.size.height / image.size.height) * image.size.width;
    }
    self.imageView.frame = frame;
    [self configureForImageSize:self.imageView.bounds.size];
}


- (void)configureForImageSize:(CGSize)imageSize
{
    _imageSize = imageSize;
    self.contentSize = imageSize;
    
    //to center
    if (imageSize.width > imageSize.height) {
        self.contentOffset = CGPointMake((imageSize.width - self.frame.size.width)/2, 0);
    } else if (imageSize.width < imageSize.height) {
        self.contentOffset = CGPointMake(0, (imageSize.height - self.frame.size.height)/2);
    }
    
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    self.minimumZoomScale = 1.0;
    self.maximumZoomScale = 2.0;
}
- (void)setBlockZoomScalesForCurrentBounds
{
    self.minimumZoomScale = 1.0;
    self.maximumZoomScale = 1.0;
}

#pragma mark - locate image
-(void)setImageViewInCenter
{
    CGRect frame = self.imageView.frame;
    CGSize imageSize = frame.size;
    //to center
    if (imageSize.width > imageSize.height) {
        self.contentOffset = CGPointMake((imageSize.width - self.frame.size.width)/2, 0);
    } else if (imageSize.width < imageSize.height) {
        self.contentOffset = CGPointMake(0, (imageSize.height - self.frame.size.height)/2);
    }
    else
    {
        self.contentOffset = CGPointMake(0, 0);
    }
    
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;
}
-(void)adaptImageView
{
    CGRect frame = self.imageView.frame;
    CGSize imageSize = frame.size;
    if (imageSize.width > imageSize.height)
    {
        [self addWhiteSideToImageHeight];
    }
    else if (imageSize.width < imageSize.height)
    {
        [self addWhiteSideToImageWidth];
    }
    else if (imageSize.width == imageSize.height)
    {
        self.contentOffset = CGPointMake(0, 0);
        [self setMaxMinZoomScalesForCurrentBounds];
        self.zoomScale = self.minimumZoomScale;

    }
}

-(void)addWhiteSideToImageHeight
{
    CGSize oldImageSize = self.imageView.image.size;
    CGSize newImageSize = CGSizeMake(oldImageSize.width, oldImageSize.width);
    UIGraphicsBeginImageContext(newImageSize);
    
    float sideHight = (oldImageSize.width - oldImageSize.height)/2;
    [self.unfilteredImage drawInRect:CGRectMake(0, sideHight, oldImageSize.width, oldImageSize.height)];
    UIImage *whiteImage = [PhotoCommon createImageWithColor:[UIColor whiteColor] size:CGSizeMake(newImageSize.width, sideHight)];
    [whiteImage drawInRect:CGRectMake(0, 0, newImageSize.width, sideHight)];
    [whiteImage drawInRect:CGRectMake(0, newImageSize.height - sideHight, newImageSize.width, sideHight)];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    self.unfilteredImage = resultingImage;
    UIGraphicsEndImageContext();
}
-(void)addWhiteSideToImageWidth
{
    CGSize oldImageSize = self.imageView.image.size;
    CGSize newImageSize = CGSizeMake(oldImageSize.height, oldImageSize.height);
    UIGraphicsBeginImageContext(newImageSize);
    
    float sideWidth= (oldImageSize.height - oldImageSize.width)/2;
    [self.unfilteredImage drawInRect:CGRectMake(sideWidth, 0, oldImageSize.width, oldImageSize.height)];
    UIImage *whiteImage = [PhotoCommon createImageWithColor:[UIColor whiteColor] size:CGSizeMake(newImageSize.height, sideWidth)];
    [whiteImage drawInRect:CGRectMake(0, 0,sideWidth, newImageSize.height)];
    [whiteImage drawInRect:CGRectMake(newImageSize.width - sideWidth, 0 , sideWidth,newImageSize.height)];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    self.unfilteredImage = resultingImage;
    UIGraphicsEndImageContext();
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end

