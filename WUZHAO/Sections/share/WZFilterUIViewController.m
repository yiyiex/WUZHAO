//
//  WZFilterUIViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/1/28.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "WZFilterUIViewController.h"
#import "AddImageInfoViewController.h"

#import "CIFilter+LUT.h"
#import "FeSlideFilterView.h"

#import "PhotoCommon.h"

#import "macro.h"

@interface WZFilterUIViewController ()<FeSlideFilterViewDataSource,FeSlideFilterViewDelegate,UIScrollViewDelegate>

@property (nonatomic,strong) NSArray *arrTitleFilter;
@property (nonatomic,strong) NSMutableArray *arrPhoto;


@property (nonatomic,strong) FeSlideFilterView *slideFilterView;

@property (nonatomic,strong) UIScrollView *selectFilterScrollView;


-(void) initCommon;

-(void) initFeslideFilterView;

-(void) initPhotoFilter;

@end

@implementation WZFilterUIViewController
@synthesize slideFilterView = _slideFilterView;
@synthesize originalImage = _originalImage;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTitle];
    [self initPhotoFilter];
    [self initFeslideFilterView];
    [self initSelectFilterScrollView];
    [self fillSelectFilterScrollView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(instancetype) initWithImage:(UIImage *)image delegate:(id<WZFilterUIViewControllerDelegate>)delegate
{
    self = [self init];
    if (self)
    {
        self.originalImage = image;
        self.delegate = delegate;
    }
    return self;
}

-(void) initCommon
{
    
}
-(void) initTitle
{
    _arrTitleFilter = @[@"Los Angeles",@"Paris",@"London",@"Rio",@"Original"];
}

-(void) initSelectFilterScrollView
{
    _selectFilterScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 80+30+WUZHAO_APP_SIZE.width, WUZHAO_APP_SIZE.width, WUZHAO_APP_SIZE.height-150-WUZHAO_APP_SIZE.width)];
    _selectFilterScrollView.delegate = self;
    _selectFilterScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _selectFilterScrollView.showsHorizontalScrollIndicator = NO;
    _selectFilterScrollView.showsVerticalScrollIndicator = NO;
   // _selectFilterScrollView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:_selectFilterScrollView];

    
}
-(void) fillSelectFilterScrollView
{
    CGFloat X = 0;
    CGFloat Y = _selectFilterScrollView.frame.origin.y;
    CGFloat W = 80;
    CGFloat H = _selectFilterScrollView.frame.size.height;
    for (NSInteger i = 0 ;i <self.numberOfFilter; i++)
    {
    
        UILabel *filterLabel = [[UILabel alloc]initWithFrame:CGRectMake(X, 0, W, H)];
        filterLabel.backgroundColor = THEME_COLOR;
        filterLabel.textColor = [UIColor whiteColor];
        filterLabel.textAlignment = NSTextAlignmentCenter;
        filterLabel.text = _arrTitleFilter[i];
        //响应点击选择
        UITapGestureRecognizer *selectFilterClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickFilterSelecter:)];
        [filterLabel addGestureRecognizer:selectFilterClick];
        
        [_selectFilterScrollView addSubview:filterLabel];
        X += W;
        X += 2;
    }
    _selectFilterScrollView.contentSize = CGSizeMake(MAX(X, _selectFilterScrollView.frame.size.width+1), 0);
}
-(void) initFeslideFilterView
{
    NSInteger frameWith = WUZHAO_APP_SIZE.width;
    CGRect frame = CGRectMake(0, 80,frameWith,frameWith);
    _slideFilterView = [[FeSlideFilterView alloc] initWithFrame:frame];
    _slideFilterView.dataSource = self;
    _slideFilterView.delegate = self;
    
    [self.view addSubview:_slideFilterView];
    
    // Btn
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 40, 40);
    [btn setBackgroundImage:[UIImage imageNamed:@"done"] forState:UIControlStateNormal];
    
    _slideFilterView.doneBtn = btn;
}
-(void) initPhotoFilter
{
    _arrPhoto = [NSMutableArray arrayWithCapacity:5];
    UIImage *beginImage;
    if (_originalImage)
    {
        beginImage = _originalImage;
    }
    else
    {
        beginImage = [self imageDependOnDevice];
    }
    
    for (NSInteger i = 0; i < 5; i++)
    {
        if (i == 4)
        {
            [_arrPhoto addObject:beginImage];
        }
        else
        {
            NSString *nameLUT = [NSString stringWithFormat:@"filter_lut_%ld",i + 1];
            
            //////////
            // FIlter with LUT
            // Load photo
            
            // Create filter
            CIFilter *lutFilter = [CIFilter filterWithLUT:nameLUT dimension:64];
            
            // Set parameter
            CIImage *ciImage = [[CIImage alloc] initWithImage:beginImage];
            [lutFilter setValue:ciImage forKey:@"inputImage"];
            CIImage *outputImage = [lutFilter outputImage];
            
            CIContext *context = [CIContext contextWithOptions:[NSDictionary dictionaryWithObject:(__bridge id)(CGColorSpaceCreateDeviceRGB()) forKey:kCIContextWorkingColorSpace]];
            
            UIImage *newImage = [UIImage imageWithCGImage:[context createCGImage:outputImage fromRect:outputImage.extent]];
            
            
            [_arrPhoto addObject:newImage];
        }
    }
}

#pragma mark -UIGestureRecognizer selector
-(void)clickFilterSelecter:(UITapGestureRecognizer *)gesture
{
    UILabel *selectFilterLabel = (UILabel *)gesture.view;
    NSString *filterName = selectFilterLabel.text;
    NSInteger filterNum = [_arrTitleFilter indexOfObject:filterName];
    [_slideFilterView selectFilterAtIndex:filterNum];
}
#pragma mark -----FeslideFilterDelegate and Datasource
-(NSInteger)numberOfFilter
{
    return 5;
}

-(NSString *)FeSlideFilterView:(FeSlideFilterView *)sender titleFilterAtIndex:(NSInteger)index
{
    return _arrTitleFilter[index];
}

-(NSString *)kCAContentGravityForLayer
{
    return kCAGravityResizeAspectFill;
}

-(UIImage *)FeSlideFilterView:(FeSlideFilterView *)sender imageFilterAtIndex:(NSInteger)index
{
    return _arrPhoto[index];
}
-(void)FeSlideFilterView:(FeSlideFilterView *)sender didBeginSlideFilterAtIndex:(NSInteger)index
{
    
}
-(void)FeSlideFilterView:(FeSlideFilterView *)sender didEndSlideFilterAtIndex:(NSInteger)index
{
    
}
-(void)FeSlideFilterView:(FeSlideFilterView *)sender didTapDoneButtonAtIndex:(NSInteger)index
{
  /*
    if ([self.delegate respondsToSelector:@selector(FilterController:didEndFilterThePhoto:)])
    {
        [self.delegate FilterController:self didEndFilterThePhoto:_arrPhoto[index]];
    }
   */
    [PhotoCommon saveImageToPhotoAlbum:_arrPhoto[index]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Share" bundle:nil];
    
    AddImageInfoViewController *addImageInfoCon = [storyboard instantiateViewControllerWithIdentifier:@"addImageInfo"];
    [addImageInfoCon setPostImage:_arrPhoto[index]];
    [self.navigationController pushViewController:addImageInfoCon animated:YES];
    
}
#pragma mark - Private
-(UIImage *) imageDependOnDevice
{
    UIImage *imageOriginal;
    imageOriginal = [UIImage imageNamed:@"image.png"];
    return imageOriginal;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
