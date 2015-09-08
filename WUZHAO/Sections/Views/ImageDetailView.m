//
//  ImageDetailView.m
//  WUZHAO
//
//  Created by yiyi on 15/8/19.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "ImageDetailView.h"
#import "macro.h"
#import "UIImageView+WebCache.h"
#import "PhotoCommon.h"
#define spacing 20.0f
@interface ImageDetailView()<UIScrollViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *zoomScrollViews;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIControl *overlayView;
@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) NSArray *imagesInfo;
@property (nonatomic, strong) UIView *infoPanel;
@property (nonatomic, strong) NSArray *infoPanelLabels;
@property (nonatomic, strong) UIImageView *infoIcon;
@end

@implementation ImageDetailView

-(instancetype)initWithImages:(NSArray *)images currentImageIndex:(NSInteger)index
{
    self = [super initWithFrame:CGRectMake(0, 0, WZ_DEVICE_SIZE.width, WZ_DEVICE_SIZE.height)];
    self.userInteractionEnabled = YES;
    [self.scrollView setContentSize:CGSizeMake(images.count*(WZ_DEVICE_SIZE.width+spacing), WZ_DEVICE_SIZE.height)];
    [self.scrollView setContentOffset:CGPointMake(index*(WZ_DEVICE_SIZE.width+spacing), 0)];
    [self addSubview:self.scrollView];
    
    [self.pageControl setNumberOfPages:images.count];
    [self.pageControl setCurrentPage:index];
    
    [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {
        CGRect zoomViewFrame = CGRectMake(idx*(WZ_DEVICE_SIZE.width + spacing), (WZ_DEVICE_SIZE.height-WZ_DEVICE_SIZE.width)/2, WZ_DEVICE_SIZE.width, WZ_DEVICE_SIZE.width);
        // CGRect zoomViewFrame = CGRectMake(idx*(WZ_DEVICE_SIZE.width + spacing), 0, WZ_DEVICE_SIZE.width, WZ_DEVICE_SIZE.height);
        
        
        UIScrollView *zoomView = [[UIScrollView alloc]initWithFrame:zoomViewFrame];
        zoomView.layer.masksToBounds = NO;
        [zoomView setMaximumZoomScale:3.0f];
        [zoomView setMinimumZoomScale:1.0f];
        zoomView.showsHorizontalScrollIndicator = NO;
        zoomView.showsVerticalScrollIndicator = NO;
        zoomView.contentSize = CGSizeMake(WZ_DEVICE_SIZE.width, WZ_DEVICE_SIZE.width);
        zoomView.tag = 200;
        zoomView.delegate = self;
        [self.scrollView addSubview:zoomView];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, zoomViewFrame.size.width, zoomViewFrame.size.height)];
        [imageView setImage:image];
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *imageClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        [imageView addGestureRecognizer:imageClick];
        imageView.tag = 100+idx;
        [self.imageViews addObject:imageView];
        
        
        [zoomView addSubview:imageView];
        [self.zoomScrollViews addObject:zoomView];

    }];
    return self;
    
}

-(instancetype)initWithImageUrls:(NSArray *)imageUrls currentImageIndex:(NSInteger)index
{
    self = [self initWithImageUrls:imageUrls currentImageIndex:index placeHolderImages:nil];
    return self;
}
-(instancetype)initWithImageUrls:(NSArray *)imageUrls currentImageIndex:(NSInteger)index placeHolderImages:(NSArray *)placeHolderImages
{
    self = [super initWithFrame:CGRectMake(0, 0, WZ_DEVICE_SIZE.width, WZ_DEVICE_SIZE.height)];
    self.userInteractionEnabled = YES;
    [self.scrollView setContentSize:CGSizeMake(imageUrls.count*(WZ_DEVICE_SIZE.width+spacing), WZ_DEVICE_SIZE.height)];
    [self.scrollView setContentOffset:CGPointMake(index*(WZ_DEVICE_SIZE.width+spacing), 0)];
    [self addSubview:self.scrollView];
    
    [self.pageControl setNumberOfPages:imageUrls.count];
    [self.pageControl setCurrentPage:index];
    
    //set images info with image urls
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self setImagesInfoWithUrls:imageUrls];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateInfoIconState];
        }) ;
    });
    
    [imageUrls enumerateObjectsUsingBlock:^(NSString *imageUrl, NSUInteger idx, BOOL *stop) {
        
        CGRect zoomViewFrame = CGRectMake(idx*(WZ_DEVICE_SIZE.width + spacing), (WZ_DEVICE_SIZE.height-WZ_DEVICE_SIZE.width)/2, WZ_DEVICE_SIZE.width, WZ_DEVICE_SIZE.width);
       // CGRect zoomViewFrame = CGRectMake(idx*(WZ_DEVICE_SIZE.width + spacing), 0, WZ_DEVICE_SIZE.width, WZ_DEVICE_SIZE.height);
        
        
        UIScrollView *zoomView = [[UIScrollView alloc]initWithFrame:zoomViewFrame];
        zoomView.layer.masksToBounds = NO;
        [zoomView setMaximumZoomScale:3.0f];
        [zoomView setMinimumZoomScale:1.0f];
        zoomView.showsHorizontalScrollIndicator = NO;
        zoomView.showsVerticalScrollIndicator = NO;
        zoomView.contentSize = CGSizeMake(WZ_DEVICE_SIZE.width, WZ_DEVICE_SIZE.width);
        zoomView.tag = 200;
        zoomView.delegate = self;
        [self.scrollView addSubview:zoomView];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, zoomViewFrame.size.width, zoomViewFrame.size.height)];
        //[imageView setContentMode:UIViewContentModeScaleAspectFit];
        UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [imageView addSubview:aiv];
        [imageView bringSubviewToFront:aiv];
        [aiv setCenter:CGPointMake(WZ_DEVICE_SIZE.width/2, WZ_DEVICE_SIZE.width/2)];
        [aiv startAnimating];
        if (placeHolderImages && placeHolderImages.count >idx )
        {
            if ([placeHolderImages objectAtIndex:idx] && ![[placeHolderImages objectAtIndex:idx] isEqual:[NSNull null]])
            {
                [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:placeHolderImages[idx] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [aiv stopAnimating];
                    [aiv removeFromSuperview];
                }];
            }
            else
            {
                [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [aiv stopAnimating];
                    [aiv removeFromSuperview];
                }];
            }
        }
        else
        {
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [aiv stopAnimating];
                [aiv removeFromSuperview];
            }];
        }
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *imageClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        [imageView addGestureRecognizer:imageClick];
        imageView.tag = 100+idx;
        [self.imageViews addObject:imageView];

        
        [zoomView addSubview:imageView];
        [self.zoomScrollViews addObject:zoomView];
        
    }];
    return self;
}
-(NSMutableArray *)imageViews
{
    if (!_imageViews) {
        _imageViews = [[NSMutableArray alloc]init];
    }
    return _imageViews;
}

-(UIControl *)overlayView
{
    if (!_overlayView)
    {
        _overlayView = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, WZ_DEVICE_SIZE.width, WZ_DEVICE_SIZE.height)];
        _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _overlayView.backgroundColor = [UIColor clearColor];
        

    }
    return _overlayView;
}

-(UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,0, WZ_DEVICE_SIZE.width+spacing, WZ_DEVICE_SIZE.height)];
        _scrollView.tag = 300;
        _scrollView.delegate = self;
        [_scrollView setPagingEnabled:YES];
        [_scrollView setBackgroundColor:[UIColor blackColor]];
        UITapGestureRecognizer *greyMaskClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss:)];
        [_scrollView addGestureRecognizer:greyMaskClick];
        
    }
    return _scrollView;
}

-(UIPageControl *)pageControl
{
    if (!_pageControl)
    {
        _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, WZ_DEVICE_SIZE.height - 80, WZ_DEVICE_SIZE.width, 20)];
        [self addSubview:_pageControl];
        [_pageControl setHidden:YES];
    }
    return _pageControl;
}
-(NSMutableArray *)zoomScrollViews
{
    if (!_zoomScrollViews)
    {
        _zoomScrollViews = [[NSMutableArray alloc]init];
    }
    return _zoomScrollViews;
}

-(UIView *)infoPanel
{
    if (!_infoPanel)
    {
        _infoPanel = [[UIView alloc]initWithFrame:CGRectMake(0, WZ_DEVICE_SIZE.height - 200, WZ_DEVICE_SIZE.width, 200)];
        [_infoPanel.layer setBackgroundColor:[[UIColor blackColor]CGColor]];
        [_infoPanel.layer setOpacity:0.6f];
        [_infoPanel setUserInteractionEnabled:NO];
        NSMutableArray *infoLabelsArray = [[NSMutableArray alloc]init];
        float labelSpacing = 8.0;
        float labelHeight = 16;
        NSArray *title = @[@"品牌",@"型号",@"焦距",@"光圈",@"快门速度",@"ISO",@"曝光补偿",@"镜头"];
        for (int i = 0 ;i<8 ;i++)
        {
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, labelSpacing +(labelSpacing+labelHeight)*i, 60, labelHeight)];
            [titleLabel setTextColor:THEME_COLOR_FONT_GREY];
            [titleLabel setFont:WZ_FONT_SMALL_SIZE];
            [titleLabel setText:title[i]];
            [titleLabel setTextAlignment:NSTextAlignmentRight];
            
            UILabel *infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(32+60, labelSpacing +(labelSpacing+labelHeight)*i, WZ_DEVICE_SIZE.width - 92, labelHeight)];
            [infoLabel setTextColor:THEME_COLOR_WHITE];
            [infoLabel setFont:WZ_FONT_SMALL_SIZE];
            [infoLabel setText:@""];
            [infoLabel setTextAlignment:NSTextAlignmentLeft];
            [infoLabelsArray addObject:infoLabel];
            
            [_infoPanel addSubview:titleLabel];
            [_infoPanel addSubview:infoLabel];
        }
        self.infoIcon = [[UIImageView alloc]initWithFrame:CGRectMake(2, WZ_DEVICE_SIZE.height - 38, 36, 36)];
        [self.infoIcon setImage:[UIImage imageNamed:@"photo_info"]];
        [self.infoIcon setUserInteractionEnabled:YES];
        UITapGestureRecognizer *infoIconTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(infoIconClick)];
        [self.infoIcon addGestureRecognizer:infoIconTap];
        [self addSubview:_infoIcon];
        [self addSubview:_infoPanel];
        _infoPanelLabels = [[NSArray alloc]initWithArray:infoLabelsArray];
        
    }
    return _infoPanel;
}

-(void)setImagesInfo:(NSArray *)info
{
    _imagesInfo = [[NSMutableArray alloc]initWithArray:info];
}

-(void)setImagesInfoWithUrls:(NSArray *)urlStringList
{
    NSMutableArray *INFOS = [[NSMutableArray alloc]init];
   [urlStringList enumerateObjectsUsingBlock:^(NSString *imageUrl, NSUInteger idx, BOOL *stop) {
       NSDictionary *info = [PhotoCommon getImageInfoFromUrl:[NSURL URLWithString:imageUrl]];
       if (info)
       {
           [INFOS addObject:info];
       }
       else
       {
           [INFOS addObject:[NSNull null]];
       }
   }];
    self.imagesInfo = INFOS;
}

-(void)show
{
    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    if (!self.overlayView.superview)
    {
        NSEnumerator *frontToBackWindows = [[UIApplication sharedApplication].windows reverseObjectEnumerator];
        for (UIWindow *window in frontToBackWindows)
        {
            BOOL windowOnMainScreen = window.screen == [UIScreen mainScreen];
            BOOL windowIsVisiable = !window.hidden && window.alpha >0;
            BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
            if (windowOnMainScreen && windowIsVisiable && windowLevelNormal)
            {
                [window addSubview:self.overlayView];
                break;
            }
        }
    }
    else
    {
        [self.overlayView.superview bringSubviewToFront:self.overlayView];
    }
    if (!self.superview)
    {
        [self.overlayView addSubview:self];
    }
    [self.infoPanel setHidden:YES];
    [self updateInfoIconState];
    
    [self.scrollView setAlpha:0.0f];
    
    
    /*
    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView *imageView, NSUInteger idx, BOOL *stop) {
        [self.scrollView addSubview:imageView];
    }];*/
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.scrollView setAlpha:1.0f];
    } completion:^(BOOL finished) {
  
        if (self.pageControl.numberOfPages>1)
        {
            [self.pageControl setHidden:NO];
            double delayInseconds = 3;
            dispatch_time_t popTime =  dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInseconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.3 animations:^{
                    self.pageControl.alpha = 0.0f;
                    
                } completion:^(BOOL finished) {
                    [self.pageControl setHidden:YES];
                    [self.pageControl setAlpha:1.0f];
                }];
            });
        }
    }];
}

-(void)dismiss:(UIGestureRecognizer *)gesture
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.overlayView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [_scrollView removeFromSuperview];
        _scrollView = nil;
        [_pageControl removeFromSuperview];
        _pageControl = nil;
        _imageViews = nil;
        [_overlayView removeFromSuperview];
        _overlayView = nil;
        
        [[UIApplication sharedApplication]setStatusBarHidden:NO];
        
    }];
}
-(void)updateInfoIconState
{
    NSInteger currentIndex = self.scrollView.contentOffset.x/WZ_DEVICE_SIZE.width;
    NSDictionary *currentInfoDic = self.imagesInfo[currentIndex];
    if (currentInfoDic && ![currentInfoDic isEqual:[NSNull null]])
    {
        NSArray *info = [self transImageInfo:currentInfoDic];
        if (info)
        {
            [self.infoIcon setHidden:NO];
            if (![self.infoPanel isHidden])
            {
                [self updateInfoPanel];
            }
       
        }
        else
        {
            [self.infoIcon setHidden:YES];
            if (![self.infoPanel isHidden])
            {
                [self.infoPanel setHidden:YES];
            }
        }
    }
    else
    {
        [self.infoIcon setHidden:YES];
        if (![self.infoPanel isHidden])
        {
            [self.infoPanel setHidden:YES];
        }
    }
}

-(void)updateInfoPanel
{
    NSInteger currentIndex = self.scrollView.contentOffset.x/WZ_DEVICE_SIZE.width;
    NSDictionary *currentInfoDic = self.imagesInfo[currentIndex];
    if (currentInfoDic && ![currentInfoDic isEqual:[NSNull null]])
    {
        NSArray *info = [self transImageInfo:currentInfoDic];
        if (info)
        {
            [self.infoPanelLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
                [label setText:info[idx]];
            }];
            [self.infoPanel setNeedsDisplay];
        }
        else
        {
            [self.infoPanelLabels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
                [label setText:@""];
            }];
        }
    }
}
-(void)showInfoPanel
{
    [self updateInfoPanel];
    [self.infoPanel setFrame:CGRectMake(0, WZ_DEVICE_SIZE.height, WZ_DEVICE_SIZE.width, 200)];
    [self.infoPanel setHidden:NO];
    [UIView animateWithDuration:0.3 animations:^{
        [self.infoPanel setFrame:CGRectMake(0, WZ_DEVICE_SIZE.height - 200, WZ_DEVICE_SIZE.width, 200)];
    } completion:^(BOOL finished) {
        [self bringSubviewToFront:self.infoIcon];
    }];
}

-(void)hideInfoPanel
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.infoPanel setFrame:CGRectMake(0, WZ_DEVICE_SIZE.height, WZ_DEVICE_SIZE.width, 200)];
    } completion:^(BOOL finished) {
        [self.infoPanel setHidden:YES];
    }];
    
}

-(void)infoIconClick
{
    if ([self.infoPanel isHidden])
    {
        [self showInfoPanel];
    }
    else
    {
        [self hideInfoPanel];
    }
}
#pragma mark - utility

-(NSArray *)transImageInfo:(NSDictionary *)originInfo
{
    NSMutableArray *transInfo = [[NSMutableArray alloc]init];
    NSDictionary *TIFF = [originInfo objectForKey:@"{TIFF}"];
    NSDictionary *exif = [originInfo objectForKey:@"{Exif}"];
    for(int i = 0;i <8;i++)
    {
        switch (i) {
            case 0:
                if ([TIFF objectForKey:@"Make"])
                {
                    [transInfo addObject:[NSString stringWithFormat:@"%@",[TIFF valueForKey:@"Make"]]];
                }
                else
                {
                    [transInfo addObject:@""];
                }
                break;
            case 1:
                if ([TIFF objectForKey:@"Model"])
                {
                    [transInfo addObject:[NSString stringWithFormat:@"%@",[TIFF valueForKey:@"Model"]]];
                }
                else
                {
                    [transInfo addObject:@""];
                }
                break;
            case 2:
                if ([exif objectForKey:@"FocalLength"])
                {
                    [transInfo addObject:[NSString stringWithFormat:@"%@mm",[exif objectForKey:@"FocalLength"]]];
                }
                else
                {
                    [transInfo addObject:@""];
                }
                break;
            case 3:
                if ( [exif objectForKey:@"FNumber"])
                {
                    [transInfo addObject:[NSString stringWithFormat:@"f/%@", [exif objectForKey:@"FNumber"]]];
                }
                else
                {
                     [transInfo addObject:@""];
                }
                break;
            case 4:
                if ([exif objectForKey:@"ExposureTime"])
                {
                    NSNumber *time = (NSNumber *)[exif valueForKey:@"ExposureTime"];
                    if (time.doubleValue <0.01)
                    {
                        [transInfo addObject:[NSString stringWithFormat:@"%ld/1000s",(long)(NSInteger)(time.doubleValue*1000)]];
                    }
                    else
                    {
                        [transInfo addObject:[NSString stringWithFormat:@"%ld/100s",(long)(NSInteger)(time.doubleValue*100)]];
                    }
                }
                else
                {
                    [transInfo addObject:@""];
                }
                break;
            case 5:
                if ([exif objectForKey:@"ISOSpeedRatings"])
                {
                    NSArray *isoSpeedRatings = (NSArray *)[exif valueForKey:@"ISOSpeedRatings"];
                    [transInfo addObject:[NSString stringWithFormat:@"%@",isoSpeedRatings[0]]];
                }
                else
                {
                     [transInfo addObject:@""];
                }
                break;
            case 6:
                if ([exif objectForKey:@"ExposureBiasValue"])
                {
                    [transInfo addObject:[NSString stringWithFormat:@"%@",[exif objectForKey:@"ExposureBiasValue"]]];
                }
                else
                {
                     [transInfo addObject:@""];
                }
                break;
            case 7:
                if ([exif objectForKey:@"LensModel"])
                {
                    [transInfo addObject:[NSString stringWithFormat:@"%@",[exif objectForKey:@"LensModel"]]];
                }
                else
                {
                     [transInfo addObject:@""];
                }
                break;
        }
    }
    __block NSArray *info;
    [transInfo enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        if (![obj isEqualToString:@""])
        {
            info = [NSArray arrayWithArray:transInfo];
            *stop = YES;
        }
    }];
    return info;
}


#pragma mark - scrollview delegate
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
    if (scrollView.tag == 200)
    {
        NSLog(@"contentoffset %f,%f",scrollView.contentOffset.x,scrollView.contentOffset.y);
        NSLog(@"contentsize %f ,%f",scrollView.contentSize.width,scrollView.contentSize.height);
        if (targetContentOffset->x>8 && targetContentOffset->x < scrollView.contentSize.width- scrollView.frame.size.width-8)
        {
            NSLog(@"set scroll view enable no");
            self.scrollView.scrollEnabled = NO;
        }
        else
        {
            NSLog(@"setscrollview enable yes");
            self.scrollView.scrollEnabled = YES;
        }
    }
    if (scrollView.tag == 300 && scrollView.scrollEnabled)
    {
        
        //[self.scrollView setFrame:CGRectMake(0, 0, WZ_DEVICE_SIZE.width, WZ_DEVICE_SIZE.height)];
        [self.scrollView setContentSize:CGSizeMake((WZ_DEVICE_SIZE.width+spacing)*self.zoomScrollViews.count, WZ_DEVICE_SIZE.height)];
        [self.zoomScrollViews enumerateObjectsUsingBlock:^(UIScrollView *zoomView, NSUInteger idx, BOOL *stop) {
            [zoomView setZoomScale:1.0f animated:YES];
            zoomView.frame = CGRectMake(idx*(WZ_DEVICE_SIZE.width+spacing), (WZ_DEVICE_SIZE.height-WZ_DEVICE_SIZE.width)/2, WZ_DEVICE_SIZE.width, WZ_DEVICE_SIZE.width);
            zoomView.contentSize=CGSizeMake(WZ_DEVICE_SIZE.width, WZ_DEVICE_SIZE.width);
        }];
        
        
    }
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag == 300 )
    {
        NSInteger currentIndex = self.scrollView.contentOffset.x/WZ_DEVICE_SIZE.width;
        
        [self.pageControl setCurrentPage:currentIndex];
        if (self.pageControl.numberOfPages >1)
        {
            [self.pageControl setHidden:NO];
            double delayInseconds = 3;
            dispatch_time_t popTime =  dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInseconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^{
                if (self.scrollView.decelerating || self.scrollView.tracking ||self.scrollView.dragging)
                    return ;
                [UIView animateWithDuration:0.3 animations:^{
                    self.pageControl.alpha = 0.0f;
                } completion:^(BOOL finished) {
                    [self.pageControl setHidden:YES];
                    [self.pageControl setAlpha:1.0f];
                }];
            });
        }
        [self updateInfoIconState];
        
    }
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (scrollView.tag == 200)
    {
        __block UIImageView *imageView;
        [scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[UIImageView class]])
            {
                imageView = (UIImageView*)obj;
            }
        }];
        return imageView;
    }
    return nil;
}

-(void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    [self.scrollView setScrollEnabled:NO];
    UIImageView *imageView = (UIImageView *)view;
    scrollView.contentSize=imageView.image.size;
    [self.scrollView bringSubviewToFront:scrollView];
   // imageView.frame=CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height);
}
-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if(scrollView.zoomScale <=1) scrollView.zoomScale = 1.0f;
    CGFloat xcenter = scrollView.frame.size.width/2 , ycenter = scrollView.frame.size.height/2;
    
    xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : xcenter;
    
    ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : ycenter;
    
    NSInteger currentIndex = self.scrollView.contentOffset.x/WZ_DEVICE_SIZE.width;
    UIImageView *imageView = (UIImageView *)[self viewWithTag:(100+currentIndex)];
    [imageView setCenter:CGPointMake(xcenter, ycenter)];
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self.scrollView setScrollEnabled:YES];
    
}



@end
