//
//  TWPhotoPickerController.m
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "TWPhotoPickerController.h"
#import "TWPhotoCollectionViewCell.h"
#import "TWPhotoAlbumListTableViewCell.h"
#import "TWImageScrollView.h"
#import "IGLDropDownItem.h"
#import "IGLDropDownMenu.h"
#import "PhotoCommon.h"
#import "macro.h"
#import <Photos/Photos.h>

@interface TWPhotoPickerController ()<UICollectionViewDataSource, UICollectionViewDelegate ,UITableViewDelegate,UITableViewDataSource>
{
    CGFloat beginOriginY;
}
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIImageView *maskView;
@property (strong, nonatomic) TWImageScrollView *imageScrollView;

@property (strong, nonatomic) NSMutableArray *assets;
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;

@property (nonatomic,strong) PHFetchResult *fetchResult;

@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) UITableView *albumTableView;

@property (strong, nonatomic) NSDictionary *imageInfo;

@property (strong, nonatomic) NSMutableArray *albumMenuItems;
@property (nonatomic, strong) NSString *currentSelectAlbumName;
@end

@implementation TWPhotoPickerController

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.topView];
    [self.view insertSubview:self.collectionView belowSubview:self.topView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getAllAlbumList];
    // Do any additional setup after loading the view.
    [self loadPhotos];
}

- (NSMutableArray *)assets {
    if (_assets == nil) {
        _assets = [[NSMutableArray alloc] init];
    }
    return _assets;
}

- (ALAssetsLibrary *)assetsLibrary {
    if (_assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}


-(NSMutableArray *)albumMenuItems
{
    if (!_albumMenuItems)
    {
        _albumMenuItems = [[NSMutableArray alloc]init];
    }
    return _albumMenuItems;
}

- (void)getAllAlbumList
{
    [self.albumMenuItems removeAllObjects];
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if ([group numberOfAssets]>0)
        {
            __block UIImage *groupLastImage;
            [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *innerstop) {
                if (result)
                {
                    UIImage *image = [UIImage imageWithCGImage:[result thumbnail]];
                    groupLastImage = image;
                    *innerstop = YES;
                    
                }
            }];
            NSDictionary *album = @{@"albumName":[group valueForProperty:ALAssetsGroupPropertyName],@"albumPersistentID":[group valueForProperty:ALAssetsGroupPropertyPersistentID],@"albumImage":[groupLastImage copy],@"albumType":[group valueForProperty:ALAssetsGroupPropertyType],@"albumPhotoNum":[NSNumber numberWithInteger:[group numberOfAssets]]};
            [self.albumMenuItems insertObject:album atIndex:0];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"get album list error");
    }];
}

- (void)loadPhotos {
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if (result) {

            [self.assets insertObject:result atIndex:0];
        }
        
    };
    
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        if ([group numberOfAssets] > 0)
        {
            if (self.currentSelectAlbumName)
            {
                if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:self.currentSelectAlbumName]) {
                    [self.assets removeAllObjects];
                    [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
                }
            }
            else
            {
                if ([[group valueForProperty:ALAssetsGroupPropertyType]integerValue] == ALAssetsGroupSavedPhotos) {
                    [self.assets removeAllObjects];
                    [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
                    self.currentSelectAlbumName = [group valueForProperty:ALAssetsGroupPropertyName];
                }
            }
        }
        
        if (group == nil)
        {
            if (self.assets.count)
            {
                ALAsset * asset = [self.assets objectAtIndex:0];
                UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage scale:asset.defaultRepresentation.scale orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
                [self.imageScrollView displayImage:image];
            }
            [self.collectionView reloadData];
        }
        
        
    };

    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:listGroupBlock failureBlock:^(NSError *error) {
        NSLog(@"Load Photos Error: %@", error);
    }];
    NSLog(@"Load Photos Error: %u",ALAssetsGroupAll);
    
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIView *)topView {
    if (_topView == nil) {
        CGFloat handleHeight = 44.0f;
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds)+handleHeight*2);
        self.topView = [[UIView alloc] initWithFrame:rect];
        self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.topView.backgroundColor = [UIColor clearColor];
        self.topView.clipsToBounds = YES;
        
        rect = CGRectMake(0, 0, CGRectGetWidth(self.topView.bounds), handleHeight);
        UIView *navView = [[UIView alloc] initWithFrame:rect];//26 29 33
        //navView.backgroundColor = [[UIColor colorWithRed:26.0/255 green:29.0/255 blue:33.0/255 alpha:1] colorWithAlphaComponent:.8f];
        navView.backgroundColor = [UIColor blackColor];
        [self.topView addSubview:navView];
        
        rect = CGRectMake(0, 0, 60, CGRectGetHeight(navView.bounds));
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = rect;
        [backBtn setImage:[UIImage imageNamed:@"back.png"]
                 forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [navView addSubview:backBtn];
        
        rect = CGRectMake((CGRectGetWidth(navView.bounds)-100)/2, 0, 100, CGRectGetHeight(navView.bounds));

        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:rect];
        titleLabel.text = @"选择照片";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        [navView addSubview:titleLabel];
        
        rect = CGRectMake(CGRectGetWidth(navView.bounds)-70, 0, 70, CGRectGetHeight(navView.bounds));
        UIButton *cropBtn = [[UIButton alloc] initWithFrame:rect];
        [cropBtn setTitle:@"继续" forState:UIControlStateNormal];
        [cropBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
        [cropBtn setTitleColor:THEME_COLOR_DARK forState:UIControlStateNormal];
        [cropBtn addTarget:self action:@selector(cropAction) forControlEvents:UIControlEventTouchUpInside];
        [navView addSubview:cropBtn];
        
        rect = CGRectMake(0, CGRectGetHeight(self.topView.bounds)-handleHeight, CGRectGetWidth(self.topView.bounds), handleHeight);
        UIView *dragView = [[UIView alloc] initWithFrame:rect];
        dragView.backgroundColor = navView.backgroundColor;
        dragView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self.topView addSubview:dragView];
        
        UIImage *img = [UIImage imageNamed:@"menuIcon"];
        rect = CGRectMake((CGRectGetWidth(dragView.bounds)-44)/2, (CGRectGetHeight(dragView.bounds)-44)/2, 44, 44);
        UIImageView *gripView = [[UIImageView alloc] initWithFrame:rect];
        gripView.image = img;
        [gripView setContentMode:UIViewContentModeCenter];
        [dragView addSubview:gripView];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
        [dragView addGestureRecognizer:panGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
        [dragView addGestureRecognizer:tapGesture];
        
        [tapGesture requireGestureRecognizerToFail:panGesture];
        
        UITapGestureRecognizer *gripViewTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gripViewTapAction:)];
        [gripView addGestureRecognizer:gripViewTapGesture];
        [gripView setUserInteractionEnabled:YES];
        
        rect = CGRectMake(0, handleHeight, CGRectGetWidth(self.topView.bounds), CGRectGetHeight(self.topView.bounds)-handleHeight*2);
        self.imageScrollView = [[TWImageScrollView alloc] initWithFrame:rect];
        [self.topView addSubview:self.imageScrollView];
        [self.topView sendSubviewToBack:self.imageScrollView];
        
        [self drawGridWithFrame:rect inLayer:self.topView.layer];
       // self.maskView = [[UIImageView alloc] initWithFrame:rect];
        
       // self.maskView.image = [UIImage imageNamed:@"straighten-grid.png"];
        //[self.topView insertSubview:self.maskView aboveSubview:self.imageScrollView];
    }
    return _topView;
}

-(void)drawGridWithFrame:(CGRect)rect inLayer:(CALayer *)layer
{
    CGRect rect1 = CGRectMake(rect.origin.x, rect.origin.y+rect.size.width/3, rect.size.width, 0.5);
    [PhotoCommon drawALineWithFrame:rect1 andColor:THEME_COLOR_LIGHT_GREY_PARENT inLayer:layer];
    CGRect rect2 = CGRectMake(rect.origin.x, rect.origin.y+rect.size.width/3*2, rect.size.width, 0.5);
    [PhotoCommon drawALineWithFrame:rect2 andColor:THEME_COLOR_LIGHT_GREY_PARENT inLayer:layer];
    CGRect rect3 = CGRectMake(rect.origin.x+rect.size.width/3, rect.origin.y, 0.5, rect.size.height);
    [PhotoCommon drawALineWithFrame:rect3 andColor:THEME_COLOR_LIGHT_GREY_PARENT inLayer:layer];
    CGRect rect4 = CGRectMake(rect.origin.x+rect.size.width/3*2, rect.origin.y, 0.5, rect.size.height);
    [PhotoCommon drawALineWithFrame:rect4 andColor:THEME_COLOR_LIGHT_GREY_PARENT inLayer:layer];
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        CGFloat colum = 4.0, spacing = 2.0;
        CGFloat value = floorf((CGRectGetWidth(self.view.bounds) - (colum - 1) * spacing) / colum);
        
        UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize                     = CGSizeMake(value, value);
        layout.sectionInset                 = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.minimumInteritemSpacing      = spacing;
        layout.minimumLineSpacing           = spacing;
        
        CGRect rect = CGRectMake(0, CGRectGetMaxY(self.topView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-CGRectGetHeight(self.topView.bounds));
        _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        
        [_collectionView registerClass:[TWPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"TWPhotoCollectionViewCell"];
        
//        rect = CGRectMake(0, 0, 60, layout.sectionInset.top);
//        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        backBtn.frame = rect;
//        [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
//        [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
//        [_collectionView addSubview:backBtn];
//        
//        rect = CGRectMake((CGRectGetWidth(_collectionView.bounds)-140)/2, 0, 140, layout.sectionInset.top);
//        UILabel *titleLabel = [[UILabel alloc] initWithFrame:rect];
//        titleLabel.text = @"CAMERA ROLL";
//        titleLabel.textAlignment = NSTextAlignmentCenter;
//        titleLabel.backgroundColor = [UIColor clearColor];
//        titleLabel.textColor = [UIColor whiteColor];
//        titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
//        [_collectionView addSubview:titleLabel];
    }
    return _collectionView;
}

-(UITableView *)albumTableView
{
    if (_albumTableView == nil)
    {
        _albumTableView = [[UITableView alloc]init];
        [_albumTableView registerNib:[UINib nibWithNibName:@"AlbumListTableViewCell" bundle:nil] forCellReuseIdentifier:@"albumTableViewCell"];
    }
    _albumTableView.delegate = self;
    _albumTableView.dataSource = self;
    [_albumTableView setBackgroundColor:[UIColor blackColor]];
    [_albumTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_albumTableView setSeparatorColor:[UIColor grayColor]];
   // [_albumTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.view addSubview:_albumTableView];
  //  _albumTableView.backgroundColor = [UIColor blackColor];
    return _albumTableView;
}

-(void)hideAlbumTableView
{

    if (self.albumTableView.frame.size.height >0)
    {
        CGRect topFrame = self.topView.frame;
        CGFloat dragBarHeight = 44.0f;
        CGRect newTableFrame = CGRectMake(0,topFrame.size.height + topFrame.origin.y - dragBarHeight, topFrame.size.width, 0);
        [self.albumTableView setFrame:newTableFrame];
    }
}


- (void)backAction {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cropAction {
    [self backAction];
    if (self.cropBlock) {
        self.cropBlock(self.imageScrollView.capture,self.imageInfo);
    }
   
}

- (void)panGestureAction:(UIPanGestureRecognizer *)panGesture {
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            CGRect topFrame = self.topView.frame;
            CGFloat endOriginY = self.topView.frame.origin.y;
            if (endOriginY > beginOriginY) {
                topFrame.origin.y = (endOriginY - beginOriginY) >= 20 ? 0 : -(CGRectGetHeight(self.topView.bounds)-20-44);
            } else if (endOriginY < beginOriginY) {
                topFrame.origin.y = (beginOriginY - endOriginY) >= 20 ? -(CGRectGetHeight(self.topView.bounds)-20-44) : 0;
            }
            
            [self hideAlbumTableView];
            CGRect collectionFrame = self.collectionView.frame;
            collectionFrame.origin.y = CGRectGetMaxY(topFrame);
            collectionFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame);

            [UIView animateWithDuration:.3f animations:^{
                self.topView.frame = topFrame;
                self.collectionView.frame = collectionFrame;
            }];
            break;
        }
        case UIGestureRecognizerStateBegan:
        {
            beginOriginY = self.topView.frame.origin.y;
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [panGesture translationInView:self.view];
            CGRect topFrame = self.topView.frame;
            topFrame.origin.y = translation.y + beginOriginY;
            
            CGRect collectionFrame = self.collectionView.frame;
            collectionFrame.origin.y = CGRectGetMaxY(topFrame);
            collectionFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame);
            if (topFrame.origin.y <= 0 && (topFrame.origin.y >= -(CGRectGetHeight(self.topView.bounds)-20-44))) {
                self.topView.frame = topFrame;
                self.collectionView.frame = collectionFrame;
            }
            
            break;
        }
        default:
            break;
    }
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tapGesture
{

    [self focusToTopViewOrCollectionView];

    
}
-(void)gripViewTapAction:(UIGestureRecognizer *)tapGesture
{
    if (self.topView.frame.origin.y == 0)
    {
        [self focusToTopViewOrCollectionView];
    }
    CGRect topFrame = self.topView.frame;
    CGFloat dragBarHeight = 44.0f;
    if (self.albumTableView.frame.size.height >0)
    {
        CGRect newTableFrame = CGRectMake(0, 20 +dragBarHeight, topFrame.size.width, 0);
        [UIView animateWithDuration:.3f animations:^{
            self.albumTableView.frame = newTableFrame;
        }];
    }
    else
    {
        CGRect oldTableFrame = CGRectMake(0, 20 + dragBarHeight, topFrame.size.width, 0);
        [self.albumTableView setFrame:oldTableFrame];
        [self.albumTableView reloadData];
        
        
        CGRect newTableFrame = CGRectMake(0, 20 + dragBarHeight, self.view.bounds.size.width,300);
       // [UIView animateWithDuration:.3f animations:^{
       //     self.albumTableView.frame = newTableFrame;
       // }];
        [UIView animateWithDuration:.3f delay:.2f usingSpringWithDamping:3.0f initialSpringVelocity:2.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.albumTableView.frame = newTableFrame;
        } completion:nil];
    }
    
    
}
-(void)focusToTopViewOrCollectionView
{
    [self hideAlbumTableView];
     CGRect topFrame = self.topView.frame;
     topFrame.origin.y = topFrame.origin.y == 0 ? -(CGRectGetHeight(self.topView.bounds)-20-44) : 0;
     
     CGRect collectionFrame = self.collectionView.frame;
     collectionFrame.origin.y = CGRectGetMaxY(topFrame);
     collectionFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame);
     [UIView animateWithDuration:.3f animations:^{
     self.topView.frame = topFrame;
     self.collectionView.frame = collectionFrame;
     }];
}


#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TWPhotoCollectionViewCell";
    
    TWPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageWithCGImage:[[self.assets objectAtIndex:indexPath.row] thumbnail]];
    
    return cell;
}

#pragma mark - Collection View Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    ALAsset * asset = [self.assets objectAtIndex:indexPath.row];
    UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage scale:asset.defaultRepresentation.scale orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
    [self.imageScrollView displayImage:image];
    ALAssetRepresentation *rep = [[self.assets objectAtIndex:indexPath.row]defaultRepresentation];
    self.imageInfo = rep.metadata;
    if (self.topView.frame.origin.y != 0) {
        [self focusToTopViewOrCollectionView];

    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSLog(@"velocity:%f", velocity.y);
    if (velocity.y >= 2.0 && self.topView.frame.origin.y == 0) {
        [self focusToTopViewOrCollectionView];
    }
}

#pragma mark - TableView Delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TWPhotoAlbumListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"albumTableViewCell" forIndexPath:indexPath];
    NSDictionary *data = [self.albumMenuItems objectAtIndex:indexPath.row];
    cell.albumLastImageView.image = data[@"albumImage"];
    [cell.albumLastImageView.layer setCornerRadius:2.0f];
    [cell.albumLastImageView.layer setMasksToBounds:YES];
    cell.albumNameLabel.text = data[@"albumName"];
    cell.albumPhotoNumLabel.text = [data[@"albumPhotoNum"] stringValue];
    if ([cell.albumNameLabel.text isEqualToString:self.currentSelectAlbumName])
    {
        [cell.albumNameLabel setTextColor:THEME_COLOR_DARK];
        [cell.albumNameLabel setFont:WZ_FONT_LARGE_BOLD_SIZE];
    }
    else
    {
        [cell.albumNameLabel setTextColor:[UIColor whiteColor]];
        [cell.albumNameLabel setFont:WZ_FONT_LARGE_SIZE];
    }
    [cell.albumPhotoNumLabel setFont:WZ_FONT_COMMON_SIZE];
    [cell.albumPhotoNumLabel setTextColor:[UIColor whiteColor]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setBackgroundColor:[UIColor blackColor]];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TWPhotoAlbumListTableViewCell *cell = (TWPhotoAlbumListTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.albumNameLabel.textColor = THEME_COLOR_DARK;
    [cell.albumNameLabel setFont:WZ_FONT_LARGE_BOLD_SIZE];
    NSLog(@"select %@",[self.albumMenuItems objectAtIndex:indexPath.row]);
    self.currentSelectAlbumName = [[self.albumMenuItems objectAtIndex:indexPath.row] valueForKey:@"albumName"];
    [self gripViewTapAction:nil];
    [self loadPhotos];

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.albumMenuItems.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}



@end
