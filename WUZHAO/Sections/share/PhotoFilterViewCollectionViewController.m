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

#import "PhotoCommon.h"
#import "captureMacro.h"
#import "macro.h"
#import "UIButton+ChangeAppearance.h"
#import "UIImage+Color.h"

#import "AddImageInfoViewController.h"

#define SELECT_INDICATOR_OFFSET 0
typedef NS_ENUM(NSInteger, EDIT_TYPE)
{
    EDIT_TYPE_FILTER = 1,
    EDIT_TYPE_EFFECT = 2
};

@interface PhotoFilterViewCollectionViewController ()
{
    float preEffectValue;
    
    float collectionOriginY;
    float collectionHeight;
    float collectionCellWidth;
}
@property (nonatomic, strong) UICollectionView *photoFilterCollectionView;
@property (nonatomic, strong) UICollectionView *photoEffectCollectionView;

@property (nonatomic, strong) NSMutableArray *filters;
@property (nonatomic, strong) NSMutableDictionary *filterDescriptions;
@property (nonatomic, strong) NSMutableArray *effectDescriptions;

@property (nonatomic, weak) IBOutlet UIView *topBarView;
@property (nonatomic, strong) UILabel *topBarTitleLabel;

@property (nonatomic, strong) UIView *effectTopBarView;
@property (nonatomic, strong) UILabel *effectTopBarTitleLabel;

@property (nonatomic, weak) IBOutlet UIView *bottomBarView;
@property (nonatomic, strong) UIButton *filterButton;
@property (nonatomic, strong) UIButton *effectButton;

@property (nonatomic, strong) UIView *sliderEditView;
@property (nonatomic, strong) UIButton *sliderEditOk;
@property (nonatomic, strong) UIButton *sliderEditCancel;
@property (nonatomic, strong) FilterSliderView *effectFilterSliderView;

@property (nonatomic, strong) UIView *selectIndicatorView;

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
        _selectIndicatorView = [[UIView alloc]initWithFrame:CGRectMake(0, collectionHeight - 8 , 66, 2)];
        [_selectIndicatorView setBackgroundColor:THEME_COLOR_DARK];
    }
    return _selectIndicatorView;
}

-(void)caculateCollectionRelationSize
{
     collectionOriginY = 50 + WZ_APP_SIZE.width;
     collectionHeight = WZ_APP_SIZE.height - collectionOriginY - 60;
     collectionCellWidth =  collectionHeight>100? collectionHeight/2: collectionHeight -20;
    

    
}
-(void )initPhotoFilterCollectionView
{
    if (!_photoFilterCollectionView)
    {

        [self caculateCollectionRelationSize];
        UICollectionViewFlowLayout *collectionLayout = [[UICollectionViewFlowLayout alloc]init];
        collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        if (collectionHeight >100)
        {
            collectionLayout.itemSize = CGSizeMake(collectionCellWidth, collectionCellWidth + 30);
            [PhotoFilterCollectionViewCell setLabelheight:20];
            
        }
        else
        {
            collectionLayout.itemSize = CGSizeMake(collectionCellWidth, collectionCellWidth);
            [PhotoFilterCollectionViewCell setLabelheight:0];
        }
        collectionLayout.minimumInteritemSpacing = 10;
        collectionLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 0);
        _photoFilterCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 50 + WZ_APP_SIZE.width, WZ_APP_SIZE.width, collectionHeight) collectionViewLayout:collectionLayout];
        _photoFilterCollectionView.dataSource = self;
        _photoFilterCollectionView.delegate = self;
        [_photoFilterCollectionView registerClass:[PhotoFilterCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier1];
        [PhotoFilterCollectionViewCell setCellWidth:collectionCellWidth];
        
        [self.view addSubview:_photoFilterCollectionView];
        
    }
}
-(void )initPhotoEffectCollectionView
{
    if (!_photoEffectCollectionView)
    {
        UICollectionViewFlowLayout *collectionLayout = [[UICollectionViewFlowLayout alloc]init];
        collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        if (collectionHeight >100)
        {
            collectionLayout.itemSize = CGSizeMake(collectionCellWidth, collectionCellWidth + 30);
            [PhotoEffectCollectionViewCell setLabelheight:20];
            
        }
        else
        {
            collectionLayout.itemSize = CGSizeMake(collectionCellWidth, collectionCellWidth);
            [PhotoEffectCollectionViewCell setLabelheight:0];
        }
        collectionLayout.minimumInteritemSpacing = 10;
        collectionLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 0);
        _photoEffectCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 50 + WZ_APP_SIZE.width, WZ_APP_SIZE.width, collectionHeight) collectionViewLayout:collectionLayout];
        _photoEffectCollectionView.dataSource = self;
        _photoEffectCollectionView.delegate = self;
        [PhotoEffectCollectionViewCell setCellWidth:collectionCellWidth];
        [_photoEffectCollectionView registerClass:[PhotoEffectCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier2];
        [self.view addSubview:_photoEffectCollectionView];

    }
}

-(void)initSliderEditView
{
    self.sliderEditView = [[UIView alloc]initWithFrame:CGRectMake(0, WZ_APP_SIZE.height, WZ_APP_SIZE.width, WZ_APP_SIZE.height - 50 -WZ_APP_SIZE.width)];
    [self.sliderEditView setBackgroundColor:DARK_BACKGROUND_COLOR];
    
    if (!_effectFilterSliderView)
    {
        _effectFilterSliderView = [[FilterSliderView alloc]initWithFrame:CGRectMake(0, 0, WZ_APP_SIZE.width, collectionHeight)];
        _effectFilterSliderView.delegate = self.filteredImageView;
    }
    
    [self.sliderEditView addSubview:_effectFilterSliderView];
    
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
    
    
    [self.view addSubview:self.sliderEditView];
    
    
   
}

-(FilterSliderView *)effectFilterSliderView
{
    if (!_effectFilterSliderView)
    {
        _effectFilterSliderView = [[FilterSliderView alloc]initWithFrame:CGRectMake(0, 0, WZ_APP_SIZE.width, 140)];
       // [self.view addSubview:_effectFilterSliderView];
        [_effectFilterSliderView setHidden:YES];
    }
    return _effectFilterSliderView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTopContainerView];
    [self initBottomContainerView];

    //filteredImageView
    self.editType = EDIT_TYPE_FILTER;
    self.filteredImageView.inputImage = self.stillImage;
    self.filteredImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.filteredImageView.filter = self.filters[0];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self initPhotoFilterCollectionView];
    
    // Do any additional setup after loading the view.
}


-(void)initTopContainerView
{
    [self.topBarView setBackgroundColor:DARK_BACKGROUND_COLOR];
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(13, 13, 24, 24)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBarView addSubview:backButton];
    UIButton *nextButton = [[UIButton alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width-70, 5, 70, 40)];
    [nextButton setTitle:@"继续" forState:UIControlStateNormal];
    [nextButton setBigButtonAppearance];
    [nextButton setTitleColor:THEME_COLOR_DARK forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBarView addSubview:nextButton];
    
    CGRect rect = CGRectMake((WZ_APP_SIZE.width-100)/2, 0, 100, CGRectGetHeight(self.topBarView.bounds));
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:rect];
    titleLabel.text = @"选择滤镜";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    self.topBarTitleLabel = titleLabel;
    [self.topBarView addSubview:titleLabel];
    
    [self.view addSubview:self.topBarView];

}

-(void)initTopEffectView
{
    self.effectTopBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WZ_APP_SIZE.width, 50)];
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
    [self.bottomBarView setBackgroundColor:DARK_BACKGROUND_COLOR];
    self.filterButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, WZ_APP_SIZE.width/2, self.bottomBarView.frame.size.height)];
    [self.filterButton setImage:[UIImage imageNamed:@"滤镜"] forState:UIControlStateNormal];
    [self.filterButton setImage:[UIImage imageNamed:@"滤镜_s"] forState:UIControlStateSelected];
    //[self.filterButton setTitle:@"滤 镜" forState:UIControlStateNormal];
    self.filterButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.filterButton setTitleColor:THEME_COLOR_WHITE forState:UIControlStateNormal];
   // [self.filterButton setBackgroundColor:THEME_COLOR_DARK];
    [self.filterButton addTarget:self action:@selector(filterButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.filterButton setSelected:YES];
    [self.bottomBarView addSubview:self.filterButton];
    
    self.effectButton = [[UIButton alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width/2, 0,WZ_APP_SIZE.width/2, self.bottomBarView.frame.size.height)];

    [self.effectButton setImage:[UIImage imageNamed:@"工具"] forState:UIControlStateNormal];
    [self.effectButton setImage:[UIImage imageNamed:@"工具_s"] forState:UIControlStateSelected];
    [self.effectButton setTintColor:[UIColor whiteColor]];
    [self.effectButton setBackgroundColor:[UIColor clearColor]];
    [self.effectButton addTarget:self action:@selector(effectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBarView addSubview:self.effectButton];
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
        if ([collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier1 forIndexPath:indexPath])
        {
            cell = (PhotoFilterCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier1 forIndexPath:indexPath];
        }
        else
        {
            cell = [[PhotoFilterCollectionViewCell alloc]init];
            [collectionView registerClass:[PhotoFilterCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier1];
        }
        
        // Configure the cell
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
        return cell;
    }
    else if (self.editType == EDIT_TYPE_EFFECT)
    {
        PhotoEffectCollectionViewCell *cell;
        if ([collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier2 forIndexPath:indexPath])
        {
            cell = (PhotoEffectCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier2 forIndexPath:indexPath];
        }
        else
        {
            cell = [[PhotoEffectCollectionViewCell alloc]init];
            [collectionView registerClass:[PhotoEffectCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier2];
        }
        FilterParameters *parameters = self.effectDescriptions[indexPath.item];
        cell.effectNameLabel.text = parameters.name;
        [cell.effectIconImageView setContentMode:UIViewContentModeScaleAspectFill];
        [cell.effectIconImageView setImage:[UIImage imageNamed:parameters.name]];
        return cell;
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
                //parameters = p;
                isNewFilter = NO;
                *stop = YES;
            }
        }];
        self.effectFilterSliderView.parameters = parameters;
        self.effectTopBarTitleLabel.text = parameters.name;
        preEffectValue = parameters.currentValue;
        
        if (isNewFilter)
        {
            [self.filteredImageView.preEffectFilters addObject:parameters];
        }
        [self showSliderEditView];
        
        //[self.filteredImageView.preEffectFilters addObject:effectFilterDescription];
    }
}

#pragma mark - view animation
-(void)showSliderEditView
{
    [self.topBarView setHidden:YES];
    [self.effectTopBarView setHidden:NO];
    
    CGRect targetFrame = CGRectMake(0, 50 + WZ_APP_SIZE.width , WZ_APP_SIZE.width,  WZ_APP_SIZE.height - 50 - WZ_APP_SIZE.width);
    [UIView animateWithDuration:0.3 animations:^{
        self.sliderEditView.frame = targetFrame;
    }];
}
-(void)hideSliderEditView
{

    [self.effectTopBarView setHidden:YES];
    [self.topBarView setHidden:NO];
    
    CGRect targetFrame = CGRectMake(0, WZ_APP_SIZE.height , WZ_APP_SIZE.width,  WZ_APP_SIZE.height - 50 - WZ_APP_SIZE.width);
    [UIView animateWithDuration:0.3 animations:^{
        self.sliderEditView.frame = targetFrame;
    }];
    
}

#pragma mark - method


#pragma mark - button action
-(void)backBarButtonClick:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)nextButtonPressed:(UIButton *)sender
{
    [self backBarButtonClick:nil];
    if (self.filterBlock)
    {
        UIImage *postImage = [self.filteredImageView outputImage];
        
        BOOL filterUsed = [[self.filteredImageView.filter.attributes objectForKey:kCIAttributeFilterName] isEqualToString: @"CIColorControls"] ? NO : YES;
        BOOL effectUsed = self.filteredImageView.preEffectFilters.count ==0?NO:YES;
        BOOL needSave = filterUsed || effectUsed;
        self.filterBlock(postImage,needSave);
    }


}

-(void)filterButtonClick:(UIButton *)sender
{
    if (self.editType == EDIT_TYPE_FILTER)
    {
        return;
    }
    if (self.editType == EDIT_TYPE_EFFECT)
    {
        self.editType = EDIT_TYPE_FILTER;
       // [self.filterButton setBackgroundColor:THEME_COLOR_DARK];
       // [self.effectButton setBackgroundColor:[UIColor blackColor]];
        [self.filterButton setSelected:YES];
        [self.effectButton setSelected:NO];
        if (self.photoEffectCollectionView)
        {
            self.topBarTitleLabel.text = @"选择滤镜";
            [self.photoEffectCollectionView setHidden:YES];
            [self.view sendSubviewToBack:self.photoEffectCollectionView];
        }
    }
}
-(void)effectButtonClick:(UIButton *)sender
{
    if (self.editType == EDIT_TYPE_EFFECT)
    {
        return;
    }
    if (self.editType == EDIT_TYPE_FILTER)
    {
        self.editType = EDIT_TYPE_EFFECT;
        [self.filterButton setSelected:NO];
        [self.effectButton setSelected:YES];
        self.topBarTitleLabel.text = @"工具";
        if (!self.photoEffectCollectionView)
        {
            [self initPhotoEffectCollectionView];
            [self.photoEffectCollectionView reloadData];
            [self initSliderEditView];
            [self initTopEffectView];
           
        }
        [self.view sendSubviewToBack:self.photoFilterCollectionView];
        [self.photoEffectCollectionView setHidden:NO];
        
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
    [self.filteredImageView deletePreEffectFilter:self.effectFilterSliderView.parameters];
    [self hideSliderEditView];
}


@end
