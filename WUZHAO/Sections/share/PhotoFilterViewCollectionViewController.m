//
//  PhotoFilterViewCollectionViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/5/30.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "PhotoFilterViewCollectionViewController.h"
#import "PhotoFilterCollectionViewCell.h"
#import "PhotoEffectCollectionViewCell.h"
#import "FilterSliderView.h"
#import "FilterSelectImageView.h"
#import "ImageCropScrollView.h"

#import "PhotoCommon.h"
#import "captureMacro.h"
#import "macro.h"
#import "UIButton+ChangeAppearance.h"
#import "UIImage+Color.h"
#import "UIImage+Resize.h"

#import "AddImageInfoViewController.h"

#define SELECT_INDICATOR_OFFSET 0
typedef NS_ENUM(NSInteger, EDIT_TYPE)
{
    EDIT_TYPE_FILTER = 1,
    EDIT_TYPE_EFFECT = 2,
    EDIT_TYPE_CROP = 3
};

@interface PhotoFilterViewCollectionViewController ()
{
    float preEffectValue;
    
    float collectionOriginY;
    float collectionHeight;
    float collectionViewOffset;
    float collectionViewHeight;
    float collectionCellWidth;
    
    float bottombarHeight;
}


@property (nonatomic, strong) UICollectionView *photoFilterCollectionView;
@property (nonatomic, strong) UICollectionView *photoEffectCollectionView;

@property (nonatomic, strong) NSMutableArray *filters;
@property (nonatomic, strong) NSMutableDictionary *filterDescriptions;
@property (nonatomic, strong) NSMutableArray *effectDescriptions;

@property (nonatomic, weak) IBOutlet UIView *topBarView;
@property (nonatomic, strong) UIScrollView *imageSelectScrollView;
@property (nonatomic, strong) NSMutableArray *imageSelectIcon;
@property (nonatomic, strong) FilterSelectImageView *selectedImageView;
@property (nonatomic, strong) UILabel *topBarTitleLabel;

@property (nonatomic, strong) UIView *effectTopBarView;
@property (nonatomic, strong) UILabel *effectTopBarTitleLabel;

@property (nonatomic, strong)  UIView *bottomBarView;
@property (nonatomic, strong) UIButton *filterButton;
@property (nonatomic, strong) UIButton *effectButton;
@property (nonatomic, strong) UIButton *cropButton;

@property (nonatomic, strong) UIView *sliderEditView;
@property (nonatomic, strong) UIButton *sliderEditOk;
@property (nonatomic, strong) UIButton *sliderEditCancel;
@property (nonatomic, strong) FilterSliderView *effectFilterSliderView;


@property (nonatomic, strong) UIView *cropButtonView;
@property (nonatomic, strong) UIButton *centerPhotoButton;
@property (nonatomic, strong) UIButton *adaptiveButton;
@property (nonatomic, strong) UIButton *cropOK;
@property (nonatomic, strong) UIButton *cropCancel;
@property (nonatomic, strong) ImageCropScrollView *cropScrollView;

@property (nonatomic, strong) UIView *selectIndicatorView;

@property (nonatomic, strong) UIView *selectImageIndicatorView;

@property (nonatomic) EDIT_TYPE editType;

@end

@implementation PhotoFilterViewCollectionViewController

static NSString * const reuseIdentifier1 = @"PhotoFilterCollectionViewCell";
static NSString * const reuseIdentifier2 = @"PhotoEffectCollectionViewCell";

-(NSMutableArray *)filters
{
    if (!_filters)
    {
        _filters = [[NSMutableArray alloc]init];
        [_filters addObject:[CIFilter filterWithName:@"CIColorControls"]];
        [_filters addObject:[CIFilter filterWithName:@"CIPhotoEffectMono"]];
        [_filters addObject:[CIFilter filterWithName:@"CIPhotoEffectFade"]];
        [_filters addObject:[CIFilter filterWithName:@"CIPhotoEffectChrome"]];
        [_filters addObject:[CIFilter filterWithName:@"CIPhotoEffectTonal"]];
        [_filters addObject:[CIFilter filterWithName:@"CIPhotoEffectProcess"]];
        [_filters addObject:[CIFilter filterWithName:@"CIPhotoEffectTransfer"]];
        [_filters addObject:[CIFilter filterWithName:@"CIPhotoEffectInstant"]];
        [_filters addObject:[CIFilter filterWithName:@"CIPhotoEffectNoir"]];
    }
    return _filters;
}

-(NSMutableDictionary *)filterDescriptions
{
    if (!_filterDescriptions)
    {
        _filterDescriptions = [[NSMutableDictionary alloc]init];
         [_filterDescriptions setValue:@"原图" forKey:@"Normal"];
         [_filterDescriptions setValue:@"单色" forKey:@"Mono"];
         [_filterDescriptions setValue:@"色调" forKey:@"Tonal"];
         [_filterDescriptions setValue:@"黑白" forKey:@"Noir"];
         [_filterDescriptions setValue:@"褪色" forKey:@"Fade"];
         [_filterDescriptions setValue:@"铬黄" forKey:@"Chrome"];
         [_filterDescriptions setValue:@"冲印" forKey:@"Process"];
         [_filterDescriptions setValue:@"岁月" forKey:@"Transfer"];
         [_filterDescriptions setValue:@"怀旧" forKey:@"Instant"];
    }
    return _filterDescriptions;
}
-(NSMutableArray *)effectDescriptions
{
    if (!_effectDescriptions)
    {
        _effectDescriptions = [[NSMutableArray alloc]init];
        FilterParameters *parameters;
        
        parameters = [[FilterParameters alloc]init];
        parameters.filterName = @"CIExposureAdjust";
        parameters.name = @"曝光";
        parameters.key = kCIInputEVKey;
        parameters.maxmumValue = 3;
        parameters.minmumValue = -2;
        parameters.currentValue = parameters.defaultValue = 0;
        [_effectDescriptions addObject:parameters];
        
        parameters = [[FilterParameters alloc]init];
        parameters.filterName = @"CIColorControls";
        parameters.name = @"对比度";
        parameters.key = kCIInputContrastKey;
        parameters.maxmumValue = 1.1;
        parameters.minmumValue = 0.9;
        parameters.currentValue = parameters.defaultValue = 1;
       [_effectDescriptions addObject:parameters];
        
        parameters = [[FilterParameters alloc]init];
        parameters.filterName = @"CIStraightenFilter";
        parameters.name = @"角度校正";
        parameters.key = kCIInputAngleKey;
        parameters.maxmumValue = M_PI/12;
        parameters.minmumValue = -M_PI/12;
        parameters.currentValue = parameters.defaultValue = 0.00;
        [_effectDescriptions addObject:parameters];
        
        parameters = [[FilterParameters alloc]init];
        parameters.filterName = @"CISharpenLuminance";
        parameters.name = @"锐化";
        parameters.key = kCIInputSharpnessKey;
        parameters.maxmumValue = 2;
        parameters.minmumValue = 0;
        parameters.currentValue = parameters.defaultValue = 0;
        [_effectDescriptions addObject:parameters];
        
        parameters = [[FilterParameters alloc]init];
        parameters.filterName = @"CIColorControls";
        parameters.name = @"饱和度";
        parameters.key = kCIInputSaturationKey;
        parameters.maxmumValue = 2;
        parameters.minmumValue = 0;
        parameters.currentValue = parameters.defaultValue = 1;
       [_effectDescriptions addObject:parameters];
        

        parameters = [[FilterParameters alloc]init];
        parameters.filterName = @"CIVignetteEffect";
        parameters.name = @"晕影";
        parameters.key = kCIInputIntensityKey;
        parameters.maxmumValue = 1;
        parameters.minmumValue = 0;
        parameters.currentValue = parameters.defaultValue = 0;
        CIVector *center = [CIVector vectorWithX:320 Y:320];
        [parameters.otherInputs addObject:@{@"key":kCIInputCenterKey,@"value":center}];
        [parameters.otherInputs addObject:@{@"key":kCIInputRadiusKey,@"value":@300}];
        [_effectDescriptions addObject:parameters];
        
        parameters = [[FilterParameters alloc]init];
        parameters.filterName = @"CIHueAdjust";
        parameters.name = @"颜色";
        parameters.key = kCIInputAngleKey;
        parameters.maxmumValue = M_PI;
        parameters.minmumValue = -M_PI;
        parameters.currentValue = parameters.defaultValue = 0.00;
        [_effectDescriptions addObject:parameters];
        
        /*
        parameters = [[FilterParameters alloc]init];
        parameters.filterName = @"CIGammaAdjust";
        parameters.name = @"Gamma";
        parameters.key = @"inputPower";
        parameters.maxmumValue = 1;
        parameters.minmumValue = 0;
        parameters.currentValue = parameters.defaultValue = 0.5;
        [_effectDescriptions addObject:parameters];*/
        
        parameters = [[FilterParameters alloc]init];
        parameters.filterName = @"CIVibrance";
        parameters.name = @"肤色";
        parameters.key = @"inputAmount";
        parameters.maxmumValue = 1;
        parameters.minmumValue = -1;
        parameters.currentValue = parameters.defaultValue = 0;
        [_effectDescriptions addObject:parameters];

        parameters = [[FilterParameters alloc]init];
        parameters.filterName = @"CIColorControls";
        parameters.name = @"亮度";
        parameters.key = kCIInputBrightnessKey;
        parameters.maxmumValue = 0.1;
        parameters.minmumValue = -0.1;
        parameters.currentValue = parameters.defaultValue = 0;
        [_effectDescriptions addObject:parameters];
        
        parameters = [[FilterParameters alloc]init];
        parameters.filterName = @"CISepiaTone";
        parameters.name = @"褪色";
        parameters.key = kCIInputIntensityKey;
        parameters.maxmumValue = 0.5;
        parameters.minmumValue = 0;
        parameters.currentValue = parameters.defaultValue = 0;
        [_effectDescriptions addObject:parameters];

        parameters = [[FilterParameters alloc]init];
        parameters.filterName = @"CIGaussianBlur";
        parameters.name = @"高斯模糊";
        parameters.key = kCIInputRadiusKey;
        parameters.maxmumValue = 5;
        parameters.minmumValue = 0;
        parameters.currentValue = parameters.defaultValue = 0;
       // [parameters.otherInputs addObject:@{@"key":kCIInputIntensityKey,@"value":@1}];
        [_effectDescriptions addObject:parameters];
        
        parameters = [[FilterParameters alloc]init];
        parameters.filterName = @"CIGloom";
        parameters.name = @"柔和";
        parameters.key = kCIInputRadiusKey;
        parameters.maxmumValue = 10;
        parameters.minmumValue = 0;
        parameters.currentValue = parameters.defaultValue = 0;
        [parameters.otherInputs addObject:@{@"key":kCIInputIntensityKey,@"value":@1}];
        [_effectDescriptions addObject:parameters];
        
        parameters = [[FilterParameters alloc]init];
        parameters.filterName = @"CIHighlightShadowAdjust";
        parameters.name = @"高光";
        parameters.key = @"inputHighlightAmount";
        parameters.maxmumValue = 1;
        parameters.minmumValue = 0.3;
        parameters.currentValue = parameters.defaultValue = 0;
        [parameters.otherInputs addObject:@{@"key":kCIInputRadiusKey,@"value":@5}];
        [_effectDescriptions addObject:parameters];
        
        parameters = [[FilterParameters alloc]init];
        parameters.filterName = @"CIHighlightShadowAdjust";
        parameters.name = @"阴影";
        parameters.key = @"inputShadowAmount";
        parameters.maxmumValue = 1;
        parameters.minmumValue = -1;
        parameters.currentValue = parameters.defaultValue = 0;
        [parameters.otherInputs addObject:@{@"key":kCIInputRadiusKey,@"value":@5}];
        [_effectDescriptions addObject:parameters];
        
        
    }
    return _effectDescriptions;
}


-(UIView *)selectIndicatorView
{
    if (!_selectIndicatorView)
    {
        _selectIndicatorView = [[UIView alloc]initWithFrame:CGRectMake(0, collectionViewHeight-2  , collectionCellWidth, 2)];
        [_selectIndicatorView setBackgroundColor:THEME_COLOR_DARK];
        
    }
   
    return _selectIndicatorView;
}

-(NSMutableArray *)filteredImages
{
    if (!_filteredImages)
    {
        _filteredImages = [[NSMutableArray alloc]init];
        [self.imagesAndInfo enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIImage *image = [obj objectForKey:@"image"];
            if (image.size.width != image.size.height)
            {
                float width = MIN(image.size.width, image.size.height);
                CGRect cropRect = CGRectMake((image.size.width-width)/2, (image.size.height-width)/2,width,width);
                image = [image croppedImage:cropRect];
            }
            [_filteredImages addObject:image];
        }];
    }
    return _filteredImages;
}

-(NSMutableArray *)filteredImageViews
{
    if (!_filteredImageViews)
    {
        _filteredImageViews = [[NSMutableArray alloc]init];
        [self.filteredImages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            FilteredImageView *filterView = [[FilteredImageView alloc]initWithFrame:CGRectMake(0, self.topBarView.frame.size.height, WZ_APP_SIZE.width, WZ_APP_SIZE.width)];
            filterView.inputImage = (UIImage *)obj;
            filterView.contentMode = UIViewContentModeScaleAspectFill;
            filterView.filter = self.filters[0];
            [_filteredImageViews addObject:filterView];
            
        }];
    }
    return _filteredImageViews;
}


-(void)caculateCollectionRelationSize
{
    collectionOriginY = self.topBarView.frame.size.height + WZ_APP_SIZE.width ;
    collectionHeight = WZ_APP_SIZE.height - collectionOriginY - bottombarHeight;
    collectionCellWidth =  isIPHONE_4s?collectionHeight -20: 48;
    collectionViewHeight = isIPHONE_4s? 40 : 100;
    collectionViewOffset = (collectionHeight - collectionViewHeight)/2;
    

    
}
-(void )initPhotoFilterCollectionView
{
    if (!_photoFilterCollectionView)
    {
        UICollectionViewFlowLayout *collectionLayout = [[UICollectionViewFlowLayout alloc]init];
        collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        if (collectionCellWidth == 48)
        {
            collectionLayout.itemSize = CGSizeMake(collectionCellWidth, collectionCellWidth+20);
            [PhotoFilterCollectionViewCell setLabelheight:20];
            
        }
        else
        {
            collectionLayout.itemSize = CGSizeMake(collectionCellWidth, collectionCellWidth);
            [PhotoFilterCollectionViewCell setLabelheight:0];
        }
        collectionLayout.minimumInteritemSpacing = 10;
        collectionLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 0);
        _photoFilterCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, collectionOriginY + collectionViewOffset, WZ_APP_SIZE.width, collectionViewHeight) collectionViewLayout:collectionLayout];
        [_photoFilterCollectionView addSubview:self.selectIndicatorView];
        _photoFilterCollectionView.dataSource = self;
        _photoFilterCollectionView.delegate = self;
        [PhotoFilterCollectionViewCell setCellWidth:collectionCellWidth];
        [_photoFilterCollectionView registerClass:[PhotoFilterCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier1];
        
        [self.view addSubview:_photoFilterCollectionView];
        
    }
}
-(void )initPhotoEffectCollectionView
{
    if (!_photoEffectCollectionView)
    {
        UICollectionViewFlowLayout *collectionLayout = [[UICollectionViewFlowLayout alloc]init];
        collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        if (collectionCellWidth  == 48)
        {
            collectionLayout.itemSize = CGSizeMake(collectionCellWidth, collectionCellWidth+20);
            [PhotoEffectCollectionViewCell setLabelheight:20];
            
        }
        else
        {
            collectionLayout.itemSize = CGSizeMake(collectionCellWidth, collectionCellWidth);
            [PhotoEffectCollectionViewCell setLabelheight:0];
        }
        collectionLayout.minimumInteritemSpacing = 10;
        collectionLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 0);
        _photoEffectCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, collectionOriginY + collectionViewOffset, WZ_APP_SIZE.width, collectionViewHeight) collectionViewLayout:collectionLayout];
        _photoEffectCollectionView.dataSource = self;
        _photoEffectCollectionView.delegate = self;
        [PhotoEffectCollectionViewCell setCellWidth:collectionCellWidth];
        [_photoEffectCollectionView registerClass:[PhotoEffectCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier2];
        
        [self.view addSubview:_photoEffectCollectionView];

    }
}

-(FilterSliderView *)effectFilterSliderView
{
    if (!_effectFilterSliderView)
    {
        _effectFilterSliderView = [[FilterSliderView alloc]initWithFrame:CGRectMake(0, 0, WZ_APP_SIZE.width, WZ_APP_SIZE.height - collectionOriginY - 44)];
    }
    return _effectFilterSliderView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initTopContainerView];
    [self initBottomContainerView];
    [self caculateCollectionRelationSize];
    [self.view setNeedsUpdateConstraints];
    [self.view setNeedsLayout];
    
    [self filterButtonClick:self.filterButton];
    
}

-(void)initSliderEditView
{
    self.sliderEditView = [[UIView alloc]initWithFrame:CGRectMake(0,WZ_APP_SIZE.height, WZ_APP_SIZE.width, WZ_APP_SIZE.height - collectionOriginY)];
    [self.sliderEditView setBackgroundColor:DARK_BACKGROUND_COLOR];
    
    
    self.sliderEditOk = [[UIButton alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width/2,self.sliderEditView.frame.size.height - self.bottomBarView.frame.size.height, WZ_APP_SIZE.width/2, self.bottomBarView.frame.size.height)];
    [self.sliderEditOk setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
    [self.sliderEditOk addTarget:self action:@selector(sliderEditOkClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.sliderEditOk setSelected:YES];
    [self.sliderEditView addSubview:self.sliderEditOk];
    
    self.sliderEditCancel = [[UIButton alloc]initWithFrame:CGRectMake(0,self.sliderEditView.frame.size.height - self.bottomBarView.frame.size.height, WZ_APP_SIZE.width/2, self.bottomBarView.frame.size.height)];
    //[self.sliderEditCancel setTitle:@"取 消" forState:UIControlStateNormal];
    [self.sliderEditCancel setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [self.sliderEditCancel setBackgroundColor:DARK_BACKGROUND_COLOR];
    [self.sliderEditCancel addTarget:self action:@selector(sliderEditCancelClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.sliderEditView addSubview:self.sliderEditCancel];
    
    [self.sliderEditView addSubview:self.effectFilterSliderView];
    [self.view addSubview:self.sliderEditView];
}

-(void)initCropView
{
    self.cropScrollView = [[ImageCropScrollView alloc]initWithFrame:CGRectMake(0, self.topBarView.frame.size.height, WZ_APP_SIZE.width, WZ_APP_SIZE.width)];
    [self.cropScrollView setBackgroundColor:DARK_BACKGROUND_COLOR];
    [self.view addSubview:self.cropScrollView];
    
    
    self.cropButtonView = [[UIView alloc]initWithFrame:CGRectMake(0,WZ_APP_SIZE.height, WZ_APP_SIZE.width,WZ_APP_SIZE.height - collectionOriginY)];
    [self.cropButtonView setBackgroundColor:DARK_BACKGROUND_COLOR];
    [self.view addSubview:self.cropButtonView];
    
    self.centerPhotoButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, WZ_APP_SIZE.width/2,collectionHeight)];
    [self.centerPhotoButton setImage:[UIImage imageNamed:@"centerPhoto"] forState:UIControlStateNormal];
    [self.centerPhotoButton addTarget:self action:@selector(centerPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.cropButtonView addSubview:self.centerPhotoButton];
    
    self.adaptiveButton = [[UIButton alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width/2, 0, WZ_APP_SIZE.width/2, collectionHeight)];
    [self.adaptiveButton setImage:[UIImage imageNamed:@"adaptive_s"] forState:UIControlStateNormal];
    [self.adaptiveButton setImage:[UIImage imageNamed:@"adaptive"] forState:UIControlStateSelected];
    [self.adaptiveButton addTarget:self action:@selector(adaptiveButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.cropButtonView addSubview:self.adaptiveButton];
    
    self.cropCancel = [[UIButton alloc]initWithFrame:CGRectMake(0, collectionHeight, WZ_APP_SIZE.width/2, self.cropButtonView.frame.size.height - collectionHeight)];
    [self.cropCancel setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [self.cropCancel addTarget:self action:@selector(cropEditCancelClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.cropCancel setSelected:YES];
    [self.cropButtonView addSubview:self.cropCancel];
    
    self.cropOK = [[UIButton alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width/2, collectionHeight, WZ_APP_SIZE.width/2, self.cropButtonView.frame.size.height - collectionHeight)];
    [self.cropOK setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
    [self.cropOK addTarget:self action:@selector(cropEditOkClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.cropOK setSelected:YES];
    [self.cropButtonView addSubview:self.cropOK];
}


-(void)initTopContainerView
{
    [self.topBarView setBackgroundColor:DARK_BACKGROUND_COLOR];
    float topBarViewHeight = self.topBarView.frame.size.height;
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(8, (topBarViewHeight - 24)/2, 24, 24)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBarView addSubview:backButton];
    UIButton *nextButton = [[UIButton alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width-58, (topBarViewHeight - 40)/2, 58, 40)];
    [nextButton setTitle:@"继续" forState:UIControlStateNormal];
    [nextButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
    [nextButton setBigButtonAppearance];
    [nextButton setTitleColor:THEME_COLOR_DARK forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBarView addSubview:nextButton];
    
    float scrollViewWidth = WZ_APP_SIZE.width - 60 - 32;
    CGRect rect = CGRectMake(40, 0, scrollViewWidth, CGRectGetHeight(self.topBarView.bounds));
    self.imageSelectScrollView = [[UIScrollView alloc]initWithFrame:rect];
    [self.topBarView addSubview:self.imageSelectScrollView];
    self.imageSelectIcon = [[NSMutableArray alloc]init];
    float imageWidth = 52;
    float imageSpacing =  (self.imageSelectScrollView.frame.size.height - imageWidth)/2;
    NSInteger contentNum = MIN(9, self.imagesAndInfo.count+1);
    [self.imageSelectScrollView setContentSize:CGSizeMake((imageWidth+imageSpacing)*contentNum ,self.imageSelectScrollView.frame.size.height)];
    [self.filteredImages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FilterSelectImageView *imageView = [[FilterSelectImageView alloc]initWithFrame:CGRectMake((imageWidth+imageSpacing)*idx, imageSpacing, imageWidth, imageWidth)];
        imageView.tag = idx;
        imageView.image = (UIImage *)obj;
        UITapGestureRecognizer *selectImageViewTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectImage:)];
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(beginDeleteImages:)];
        [imageView addGestureRecognizer:longPressGesture];
        [imageView addGestureRecognizer:selectImageViewTapGesture];
        [imageView setUserInteractionEnabled:YES];
        
        UIImageView *deleteImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
        deleteImageView.image = [UIImage imageNamed:@"delete_info_red"];
        UITapGestureRecognizer *deleteImageViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(deleteImageView:)];
        [deleteImageView addGestureRecognizer:deleteImageViewTap];
        [deleteImageView setUserInteractionEnabled:YES];
        [deleteImageView setHidden:YES];
        [imageView addSubview:deleteImageView];
        
        if (idx == 0)
        {
            [self.filteredImageView removeFromSuperview];
            self.filteredImageView = self.filteredImageViews[0];
            self.filteredImageView.inputImage = self.filteredImages[idx];
            [self.view addSubview:self.filteredImageView];
            imageView.selected = YES;
            self.selectedImageView = imageView;
        }
        
        [self.imageSelectScrollView addSubview:imageView];
        [self.imageSelectIcon addObject:imageView];
        
      
    }];
    if (self.imagesAndInfo.count <9)
    {
        UIImageView *addImageView = [[UIImageView alloc]initWithFrame:CGRectMake( (imageWidth+imageSpacing)*self.imagesAndInfo.count, imageSpacing,imageWidth, imageWidth)];
        addImageView.image = [UIImage imageNamed:@"filter_addImage"];
        [addImageView.layer setCornerRadius:2.0f];
        addImageView.backgroundColor = THEME_COLOR_DARK_GREY;
        UITapGestureRecognizer *addImageViewTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addImage:)];
        [addImageView addGestureRecognizer:addImageViewTapGesture];
        [addImageView setUserInteractionEnabled:YES];
        [self.imageSelectScrollView addSubview:addImageView];
        [self.imageSelectIcon addObject:addImageView];
    }
    
    [self.view addSubview:self.topBarView];

}

-(void)initTopEffectView
{
    self.effectTopBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WZ_APP_SIZE.width, self.topBarView.frame.size.height)];
    self.effectTopBarView.backgroundColor = DARK_BACKGROUND_COLOR;
    
    CGRect rect = CGRectMake((WZ_APP_SIZE.width-100)/2, 0, 100, CGRectGetHeight(self.topBarView.bounds));
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:rect];
    titleLabel.text = @"";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    self.effectTopBarTitleLabel = titleLabel;
    [self.effectTopBarView addSubview:self.effectTopBarTitleLabel];
    [self.effectTopBarView setHidden:YES];
    [self.view addSubview:self.effectTopBarView];

}

-(void)initBottomContainerView
{
    if (isIPHONE_4s)
    {
        bottombarHeight = 50;
    }
    else if (isIPHONE_5)
    {
        bottombarHeight = 60;
    }
    else if (isIPHONE_6)
    {
       bottombarHeight = 60;
    }
    else if (isIPHONE_6P)
    {
        bottombarHeight = 80;
    }
    self.bottomBarView = [[UIView alloc]initWithFrame:CGRectMake(0, WZ_APP_SIZE.height - bottombarHeight, WZ_APP_SIZE.width, bottombarHeight)];
    [self.view addSubview:self.bottomBarView];
    
    float buttonWidth = WZ_APP_SIZE.width/3;
    
    [self.bottomBarView setBackgroundColor:DARK_BACKGROUND_COLOR];
    self.filterButton = [[UIButton alloc]initWithFrame:CGRectMake(buttonWidth, 0, buttonWidth, self.bottomBarView.frame.size.height)];
    [self.filterButton setImage:[UIImage imageNamed:@"滤镜"] forState:UIControlStateNormal];
    [self.filterButton setImage:[UIImage imageNamed:@"滤镜_s"] forState:UIControlStateSelected];
    //[self.filterButton setTitle:@"滤 镜" forState:UIControlStateNormal];
    self.filterButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.filterButton setTitleColor:THEME_COLOR_WHITE forState:UIControlStateNormal];
   // [self.filterButton setBackgroundColor:THEME_COLOR_DARK];
    [self.filterButton addTarget:self action:@selector(filterButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.filterButton setSelected:YES];
    [self.bottomBarView addSubview:self.filterButton];
    
    self.effectButton = [[UIButton alloc]initWithFrame:CGRectMake(buttonWidth*2, 0,buttonWidth, self.bottomBarView.frame.size.height)];

    [self.effectButton setImage:[UIImage imageNamed:@"工具"] forState:UIControlStateNormal];
    [self.effectButton setImage:[UIImage imageNamed:@"工具_s"] forState:UIControlStateSelected];
    [self.effectButton setTintColor:[UIColor whiteColor]];
    [self.effectButton setBackgroundColor:[UIColor clearColor]];
    [self.effectButton addTarget:self action:@selector(effectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBarView addSubview:self.effectButton];
    
    self.cropButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, buttonWidth, self.bottomBarView.frame.size.height)];
    [self.cropButton setImage:[UIImage imageNamed:@"剪裁"] forState:UIControlStateNormal];
    [self.cropButton setImage:[UIImage imageNamed:@"剪裁_s"] forState:UIControlStateSelected];
    [self.cropButton addTarget:self action:@selector(cropButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBarView addSubview:self.cropButton];
    
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

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.editType == EDIT_TYPE_FILTER)
    {
        return self.filters.count;
    }
    else if (self.editType == EDIT_TYPE_EFFECT)
    {
        return self.effectDescriptions.count;
        
    }
    return self.filterDescriptions.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.editType == EDIT_TYPE_FILTER)
    {
    
        PhotoFilterCollectionViewCell *cell;
        cell = (PhotoFilterCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier1 forIndexPath:indexPath];
        // Configure the cell
        if (cell)
        {
            cell.filteredImageView.contentMode = UIViewContentModeScaleAspectFill;
            cell.filteredImageView.inputImage = self.filteredImageView.inputImage;
            CIFilter *filter = self.filters [indexPath.item];
            cell.filteredImageView.filter = filter;
            NSString *filterName = [[(NSString *) [filter.attributes objectForKey:kCIAttributeFilterDisplayName] componentsSeparatedByString:@" "]lastObject];
            if ([filterName isEqualToString:@"Controls"])
            {
                filterName = @"Normal";
            }
            cell.filterNameLabel.text = self.filterDescriptions[filterName];
            if (self.filteredImageView.filter == cell.filteredImageView.filter)
            {
                
                [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionLeft];
                CGRect cellRect = cell.frame;
                CGRect tempRect = self.selectIndicatorView.frame;
                tempRect.origin.x = cellRect.origin.x + SELECT_INDICATOR_OFFSET;
                self.selectIndicatorView.frame = tempRect;
            }
            return cell;
        }
    }
    else if (self.editType == EDIT_TYPE_EFFECT)
    {
        PhotoEffectCollectionViewCell *cell;
        cell = (PhotoEffectCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier2 forIndexPath:indexPath];
        if (cell)
        {
            FilterParameters *parameters = self.effectDescriptions[indexPath.item];
            cell.effectNameLabel.text = parameters.name;
            [cell.effectIconImageView setContentMode:UIViewContentModeScaleAspectFill];
            [cell.effectIconImageView setImage:[UIImage imageNamed:parameters.name]];
            return cell;
        }
    }
    return nil;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger selectItem  = indexPath.item;
    NSArray *visibleIndexPaths = [collectionView indexPathsForVisibleItems];
    NSInteger firstVisibleItem =[(NSIndexPath *) [visibleIndexPaths objectAtIndex:0]item];
    NSInteger lastVisibleItem = [(NSIndexPath *)[visibleIndexPaths lastObject] item];
    for (NSIndexPath *path in visibleIndexPaths)
    {
        if (path.item>lastVisibleItem)
        {
            lastVisibleItem = path.item;
        }
        if (path.item <firstVisibleItem)
        {
            firstVisibleItem = path.item;
        }
    }
    if (selectItem == firstVisibleItem)
    {
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
    else if (selectItem == lastVisibleItem)
    {
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    }
    
    //indicator
    if (self.editType == EDIT_TYPE_FILTER)
    {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        
        CGRect cellRect = cell.frame;
        CGRect tempRect = self.selectIndicatorView.frame;
        tempRect.origin.x = cellRect.origin.x + SELECT_INDICATOR_OFFSET;
        
        [UIView animateWithDuration:0.3 animations:^() {
            self.selectIndicatorView.frame = tempRect;
        }completion:^(BOOL finished){
            // do nothing
        }];
 
        self.filteredImageView.filter = self.filters[indexPath.item];
    }
    else if (self.editType == EDIT_TYPE_EFFECT)
    {
        __block FilterParameters *parameters  = self.effectDescriptions[indexPath.item];
        __block BOOL isNewFilter = YES;
        
        [self.filteredImageView.preEffectFilters enumerateObjectsUsingBlock:^(FilterParameters *p, NSUInteger idx, BOOL *stop) {
            if ([p.name isEqualToString:parameters.name])
            {
                parameters = p;
                isNewFilter = NO;
                *stop = YES;
            }
        }];
        
        self.effectTopBarTitleLabel.text = parameters.name;
        preEffectValue = parameters.currentValue;
        if (isNewFilter)
        {
            [self.filteredImageView.preEffectFilters addObject:parameters];
            
        }
        [self showSliderEditView];
        self.effectFilterSliderView.delegate = self.filteredImageView;
        self.effectFilterSliderView.parameters = parameters;
        
        //[self.filteredImageView.preEffectFilters addObject:effectFilterDescription];
    }
}

#pragma mark - view animation
-(void)showSliderEditView
{
    [self.topBarView setHidden:YES];
    [self.effectTopBarView setHidden:NO];
    
    CGRect targetFrame = CGRectMake(0, collectionOriginY , WZ_APP_SIZE.width,  WZ_APP_SIZE.height - collectionOriginY);
    [UIView animateWithDuration:0.3 animations:^{
        self.sliderEditView.frame = targetFrame;
    }];
}
-(void)hideSliderEditView
{

    [self.effectTopBarView setHidden:YES];
    [self.topBarView setHidden:NO];
    
    CGRect targetFrame = CGRectMake(0, WZ_APP_SIZE.height , WZ_APP_SIZE.width,  WZ_APP_SIZE.height - collectionOriginY);
    [UIView animateWithDuration:0.3 animations:^{
        self.sliderEditView.frame = targetFrame;
    }];
    
}

-(void)showCropView
{
    [self.topBarView setHidden:YES];
    if (!self.effectTopBarView)
    {
        [self initTopEffectView];
    }
    [self.effectTopBarView setHidden:NO];
    self.effectTopBarTitleLabel.text = @"裁剪";
    
    [self.cropScrollView setHidden:NO];
    [self.cropButtonView setHidden:NO];
    [self.filteredImageView setHidden:YES];
    
    CGRect targetFrame = CGRectMake(0, collectionOriginY , WZ_APP_SIZE.width,  WZ_APP_SIZE.height - collectionOriginY);
    [UIView animateWithDuration:0.3 animations:^{
        self.cropButtonView.frame = targetFrame;
        
    } completion:^(BOOL finished) {
       // [self.view bringSubviewToFront:self.cropButtonView];
    }];
}

-(void)hideCropView
{
    [self.effectTopBarView setHidden:YES];
    [self.topBarView setHidden:NO];
    [self.filteredImageView setHidden:NO];
    [self.cropScrollView setHidden:YES];
    CGRect targetFrame = CGRectMake(0, WZ_APP_SIZE.height, WZ_APP_SIZE.width,  WZ_APP_SIZE.height - collectionOriginY);
    [UIView animateWithDuration:0.3 animations:^{
        self.cropButtonView.frame = targetFrame;
    } completion:^(BOOL finished) {
        [self filterButtonClick:self.filterButton];
    }];
}
#pragma mark - method
-(void)saveAllImagesInfo
{
    NSMutableArray *newImagesAndInfo = [[NSMutableArray alloc]init];
    [self.imagesAndInfo enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        FilteredImageView *filterImageView = self.filteredImageViews[idx];
        BOOL filterUsed = [[filterImageView.filter.attributes objectForKey:kCIAttributeFilterName] isEqualToString: @"CIColorControls"] ? NO : YES;
        BOOL effectUsed = filterImageView.preEffectFilters.count ==0?NO:YES;
        NSString *needSave = filterUsed || effectUsed?@"true":@"false";
        
        NSMutableDictionary *imageAndInfo = [[NSMutableDictionary alloc]init];
        [imageAndInfo setObject:filterImageView.outputImage forKey:@"image"];
        [imageAndInfo setObject:needSave forKey:@"needSave"];
        [imageAndInfo setObject:[obj objectForKey:@"imageInfo"] forKey:@"imageInfo"];
        [newImagesAndInfo addObject:imageAndInfo];
    }];
    self.imagesAndInfo = newImagesAndInfo;
}

#pragma mark - button action
-(void)backBarButtonClick:(UIButton *)sender
{
    self.imagesAndInfo = [[NSMutableArray alloc]init];
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"addPhotoFromAlubm" object:nil userInfo:@{@"imagesAndInfo":self.imagesAndInfo}];
}

-(void)nextButtonPressed:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.filterBlock)
        {
            [self saveAllImagesInfo];
            self.filterBlock(self.imagesAndInfo);
        }
    }];
}

-(void)filterButtonClick:(UIButton *)sender
{
    if (self.editType == EDIT_TYPE_FILTER)
    {
        return;
    }
    else
    {

        if (_photoEffectCollectionView)
        {
            [self.photoEffectCollectionView setHidden:YES];
        }
        if ( _cropScrollView)
        {
            [self.cropButtonView setHidden:YES];
            [self.cropScrollView setHidden:YES];
            
        }
        self.editType = EDIT_TYPE_FILTER;
        if (!_photoFilterCollectionView)
        {
            [self initPhotoFilterCollectionView];
            [self.photoFilterCollectionView reloadData];
        }
        [self.photoFilterCollectionView setHidden:NO];
        
        [self.effectTopBarView setHidden:YES];
        [self.topBarView setHidden:NO];
        
        [self.filterButton setSelected:YES];
        [self.effectButton setSelected:NO];
        [self.cropButton setSelected:NO];
        self.topBarTitleLabel.text = @"滤镜";
        
        [self.filteredImageView setHidden:NO];
    }
    
}
-(void)effectButtonClick:(UIButton *)sender
{
    if (self.editType == EDIT_TYPE_EFFECT)
    {
        return;
    }
    else
    {
        if (_cropScrollView)
        {
            [self.cropScrollView setHidden:YES];
            [self.cropButtonView setHidden:YES];
        }
        if (_photoFilterCollectionView)
        {
            [self.photoFilterCollectionView setHidden:NO];
        }
        self.editType = EDIT_TYPE_EFFECT;
        if (!_photoEffectCollectionView)
        {
            [self initPhotoEffectCollectionView];
            [self.photoEffectCollectionView reloadData];
            [self initSliderEditView];
            [self initTopEffectView];
           
        }
        [self.photoEffectCollectionView setHidden:NO];
        
        [self.filterButton setSelected:NO];
        [self.effectButton setSelected:YES];
        [self.cropButton setSelected:NO];
        
        [self.effectTopBarView setHidden:YES];
        [self.topBarView setHidden:NO];
        
        self.topBarTitleLabel.text = @"工具";
        [self.filteredImageView setHidden:NO];


        
        
    }
}

-(void)sliderEditOkClick:(UIButton *)sender
{
    if (self.effectFilterSliderView.parameters.currentValue == self.effectFilterSliderView.parameters.defaultValue)
    {
        [self.filteredImageView deletePreEffectFilter:self.effectFilterSliderView.parameters];
    }
    [self hideSliderEditView];
}
-(void)sliderEditCancelClick:(UIButton *)sender
{
    self.effectFilterSliderView.parameters.currentValue = preEffectValue;
    if (preEffectValue == self.effectFilterSliderView.parameters.defaultValue)
    {
        [self.filteredImageView deletePreEffectFilter:self.effectFilterSliderView.parameters];
    }
    [self hideSliderEditView];
}
-(void)selectImageSelectIcon:(FilterSelectImageView *)selectedImageView
{
    NSInteger oldSelectIndex = self.selectedImageView.tag;
    [self.selectedImageView setSelected:NO];
    self.filteredImages[oldSelectIndex] = self.filteredImageView.inputImage;
    self.selectedImageView.image = self.filteredImageView.outputImage;
    [self.filteredImageView removeFromSuperview];
    
    NSInteger newSelectIndex = selectedImageView.tag;
    self.filteredImageView = self.filteredImageViews[newSelectIndex];
    self.selectedImageView = selectedImageView;
    [self.selectedImageView setSelected:YES];
    self.filteredImageView.inputImage = self.filteredImages[newSelectIndex];
    [self.view addSubview:self.filteredImageView];
    [self filterButtonClick:nil];
    [self.photoFilterCollectionView reloadData];
}

-(void)selectImage:(UITapGestureRecognizer *)gesture
{
    FilterSelectImageView *selectedImageView = (FilterSelectImageView *) gesture.view;
    NSInteger oldSelectIndex = self.selectedImageView.tag;
    [self.selectedImageView setSelected:NO];
    self.filteredImages[oldSelectIndex] = self.filteredImageView.inputImage;
    self.selectedImageView.image = self.filteredImageView.outputImage;
    [self.filteredImageView removeFromSuperview];
    
    NSInteger newSelectIndex = selectedImageView.tag;
    self.filteredImageView = self.filteredImageViews[newSelectIndex];
    self.selectedImageView = selectedImageView;
    [self.selectedImageView setSelected:YES];
    self.filteredImageView.inputImage = self.filteredImages[newSelectIndex];
    [self.view addSubview:self.filteredImageView];
    [self filterButtonClick:nil];
    [self.photoFilterCollectionView reloadData];
}
-(void)addImage:(UIGestureRecognizer *)gesture
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    [self saveAllImagesInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addPhotoFromAlubm" object:nil userInfo:@{@"imagesAndInfo":self.imagesAndInfo}];
}

-(void)cropButtonClick:(UIButton *)sender
{
    if (self.editType == EDIT_TYPE_CROP)
    {
        return;
    }
    else
    {
        [self.filterButton setSelected:NO];
        [self.effectButton setSelected:NO];
        [self.cropButton setSelected:YES];
        
        if (_photoEffectCollectionView)
        {
            [self.photoEffectCollectionView setHidden:YES];
        }
        if (_photoFilterCollectionView)
        {
            [self.photoFilterCollectionView setHidden:YES];
        }
        
        self.editType = EDIT_TYPE_CROP;
        if (!_cropScrollView)
        {
            [self initCropView];
        }
        
         self.filteredImageView.inputImage = [self.imagesAndInfo[self.selectedImageView.tag] objectForKey:@"image"];
        self.cropScrollView.unfilteredImage = self.filteredImageView.inputImage;
        [self.cropScrollView displayImage:self.filteredImageView.outputImage];
        [self showCropView];
        
    }
}


-(void)centerPhotoButtonClick:(UIButton *)sender
{
    [self.cropScrollView setImageViewInCenter];
}


-(void)adaptiveButtonClick:(UIButton *)sender
{
    if (self.adaptiveButton.selected)
    {

        self.filteredImageView.inputImage = [self.imagesAndInfo[self.selectedImageView.tag] objectForKey:@"image"];
        self.cropScrollView.unfilteredImage = self.filteredImageView.inputImage;
        [self.cropScrollView displayImage:self.filteredImageView.outputImage];
        self.adaptiveButton.selected = NO;
    }
    else
    {
        
        [self.cropScrollView adaptImageView];
        self.filteredImageView.inputImage = self.cropScrollView.unfilteredImage;
        [self.cropScrollView displayImage:self.filteredImageView.outputImage];
        self.adaptiveButton.selected = YES;
    }
}

-(void)cropEditOkClick:(id)sender
{
    [self hideCropView];
    self.filteredImages[self.selectedImageView.tag] = self.selectedImageView.image = [self.cropScrollView capture];
    self.filteredImageView.inputImage = self.selectedImageView.image;
}

-(void)cropEditCancelClick:(id)sender
{
    [self hideCropView];
    self.filteredImageView.inputImage = self.selectedImageView.image;
   
}

#pragma mark - images add and delete
-(void)beginDeleteImages:(UIGestureRecognizer *)gesture
{
    UIImageView *imageView =(UIImageView*)gesture.view;
    [self BeginWobble:imageView];
}
-(void)endDeleteImages
{
    [self EndWobble];
}
-(void)deleteImageView:(UIGestureRecognizer *)gesture
{
    FilterSelectImageView *imageView =(FilterSelectImageView *)[gesture.view superview];
    //最后一张图，直接返回选择页面
    if (self.imagesAndInfo.count == 1)
    {
        [self backBarButtonClick:nil];
        return;
    }
    //delete image
    [self removeImageFromTheScrollView:imageView];
}
-(void)removeImageFromTheScrollView:(FilterSelectImageView *)imageView
{
    
    NSInteger tag = imageView.tag;
    if (tag <0 || tag >9)
    {
        return;
    }
    float imageWidth = 52;
    float imageSpacing =  (self.imageSelectScrollView.frame.size.height - imageWidth)/2;
    float transWidth = imageWidth + imageSpacing;
    if (imageView.selected)
    {
        FilterSelectImageView *selectImageView;
        if (imageView.tag<self.imageSelectIcon.count-1 && imageView.tag>0)
        {
            selectImageView = self.imageSelectIcon[imageView.tag-1];
        }
        {
            selectImageView = self.imageSelectIcon[1];
        }
        [self selectImageSelectIcon:selectImageView];
        
    }
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        imageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
    }];
    for (NSInteger i = tag+1;i <self.imageSelectIcon.count;i++)
    {
        UIImageView *imageView = self.imageSelectIcon[i];
        CGRect frame = imageView.frame;
        frame.origin.x -= transWidth;
        CFTimeInterval delayT = 0.2*(i - tag);
        [UIView animateWithDuration:0.2 delay:delayT options:UIViewAnimationOptionTransitionNone animations:^{
            imageView.frame = frame;
        } completion:nil];
    }
    
    
    //delete the view and the image
    [self.imageSelectIcon removeObject:imageView];
    [self.filteredImageViews removeObjectAtIndex:tag];
    [self.filteredImages removeObjectAtIndex:tag];
    [self.imagesAndInfo removeObjectAtIndex:tag];
    

    //reset tag
    for (NSInteger i = 0;i<self.imagesAndInfo.count;i++)
    {
        UIImageView *imageView = self.imageSelectIcon[i];
        imageView.tag = i;
    }
    
    CGSize contentSize = self.imageSelectScrollView.contentSize;
    if ((self.imagesAndInfo.count < 8))
    {
        contentSize.width -= transWidth;
        [self.imageSelectScrollView setContentSize:contentSize];

    }
    else
    {

        UIImageView *addImageView = [[UIImageView alloc]initWithFrame:CGRectMake( contentSize.width - imageWidth -imageSpacing, imageSpacing,imageWidth, imageWidth)];
        addImageView.image = [UIImage imageNamed:@"filter_addImage"];
        [addImageView.layer setCornerRadius:2.0f];
        addImageView.backgroundColor = THEME_COLOR_DARK_GREY;
        UITapGestureRecognizer *addImageViewTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addImage:)];
        [addImageView addGestureRecognizer:addImageViewTapGesture];
        [addImageView setUserInteractionEnabled:YES];
        [self.imageSelectScrollView addSubview:addImageView];
        [self.imageSelectIcon addObject:addImageView];
    }
    
    
}

-(void)BeginWobble:(UIImageView *)view
{
    for (UIView *v in view.subviews)
    {
        if ([v isKindOfClass:[UIImageView class]])
        {
            [v setHidden:NO];
        }
    }
    view.transform = CGAffineTransformMakeRotation(-0.1);
    
    [UIView animateWithDuration:0.15
                          delay:0.0
                        options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         view.transform = CGAffineTransformMakeRotation(0.1);
                     } completion:nil];
}

-(void)EndWobble
{
    for (UIView *view in self.imageSelectScrollView.subviews)
    {
        if ([view isKindOfClass:[FilterSelectImageView class]])
        {
            for (UIView *v in view.subviews)
            {
                if ([v isMemberOfClass:[UIImageView class]])
                    [v setHidden:YES];
            }
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^
             {
                 view.transform=CGAffineTransformIdentity;
   
             } completion:nil];
        }
    }
}
#pragma mark -touch delegate
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   if (![self.imageSelectScrollView isExclusiveTouch])
   {
       [self EndWobble];
   }
}

@end
