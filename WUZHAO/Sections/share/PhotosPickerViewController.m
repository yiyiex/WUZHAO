//
//  PhotosPickerViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/7/1.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "PhotosPickerViewController.h"
#import "PhotoPickerCollectionViewCell.h"
#import "PhotoAlbumTableViewCell.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "macro.h"

@interface PhotosPickerViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSInteger selectedImageCount;
    NSString *currentSelectAlbumName;
}

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray *assets;
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (strong, nonatomic) UITableView *albumTableView;

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *titleLabelIcon;

@property (strong, nonatomic) NSMutableArray *imagesAndInfo;
@property (strong, nonatomic) UILabel *imageCountLabel;
@property (strong, nonatomic) UIButton *nextButton;
@property (strong, nonatomic) NSMutableArray *albumMenuItems;

@end

@implementation PhotosPickerViewController

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.topView];
    [self.view insertSubview:self.collectionView belowSubview:self.topView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    selectedImageCount = 0;
    [self getAllAlbumList];
    // Do any additional setup after loading the view.
    [self loadPhotos];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(NSMutableArray *)imagesAndInfo
{
    if (!_imagesAndInfo)
    {
        _imagesAndInfo = [[NSMutableArray alloc]init];
    }
    return _imagesAndInfo;
}

-(void)setTitleLabelText:(NSString *)text withIcon:(NSString *)iconName
{
    self.titleLabel.text = text;
    [self.titleLabel sizeToFit];
    self.titleLabel.center = self.topView.center;
    self.titleLabelIcon.image = [UIImage imageNamed:iconName];
    CGRect Rect = self.titleLabelIcon.frame;
    Rect.origin.x = self.titleLabel.frame.origin.x + self.titleLabel.frame.size.width;
    [self.titleLabelIcon setFrame:Rect];
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
            if (currentSelectAlbumName)
            {
                if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:currentSelectAlbumName]) {
                    [self.assets removeAllObjects];
                    [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
                }
            }
            else
            {
                if ([[group valueForProperty:ALAssetsGroupPropertyType]integerValue] == ALAssetsGroupSavedPhotos) {
                    [self.assets removeAllObjects];
                    [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
                    currentSelectAlbumName = [group valueForProperty:ALAssetsGroupPropertyName];
                }
            }
            [self setTitleLabelText:currentSelectAlbumName withIcon:@"arrow_down"];
            
            
        }
        
        if (group == nil)
        {
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

- (void)backAction {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cropAction {
    
    
    [self backAction];
    if (self.selectedImagesBlock) {
        
        self.selectedImagesBlock(self.imagesAndInfo);
        //self.cropBlock(self.imageScrollView.capture,self.imageInfo);
    }
    
}

- (UIView *)topView {
    if (_topView == nil) {
        CGFloat topViewHeight = 44.0f;
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), topViewHeight);
        self.topView = [[UIView alloc] initWithFrame:rect];
        self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.topView.backgroundColor = [UIColor clearColor];
        self.topView.clipsToBounds = YES;
        
        rect = CGRectMake(0, 0, 32, CGRectGetHeight(self.topView.bounds));
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = rect;
        [backBtn setImage:[UIImage imageNamed:@"back.png"]
                 forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:backBtn];
        
        rect = CGRectMake((CGRectGetWidth(self.topView.bounds)-100)/2-10, (CGRectGetHeight(self.topView.bounds) -20)/2, 100,20);
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:rect];
        titleLabel.text = @"选择照片";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        self.titleLabelIcon = [[UIImageView alloc]initWithFrame:CGRectMake(titleLabel.frame.origin.x +100 , (CGRectGetHeight(self.topView.bounds) -20)/2, 20, 20)];
        self.titleLabelIcon.image = [UIImage imageNamed:@"arrow_down"];
        [self.topView addSubview:self.titleLabelIcon];
        
        self.titleLabel = titleLabel;
        UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(titleLabelClick)];
        UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(titleLabelClick)];
        [self.titleLabel addGestureRecognizer:tapGesture1];
        [self.titleLabel setUserInteractionEnabled:YES];
        [self.titleLabelIcon addGestureRecognizer:tapGesture2];
        [self.titleLabelIcon setUserInteractionEnabled:YES];
        [self.topView addSubview:self.titleLabel];
        
        //selected images count label
        rect = CGRectMake(CGRectGetWidth(self.topView.bounds)-75, 0, 22, CGRectGetHeight(self.topView.bounds));
        self.imageCountLabel= [[UILabel alloc]initWithFrame:rect];
        self.imageCountLabel.text = [NSString stringWithFormat:@"%ld/9",(long)selectedImageCount];
        self.imageCountLabel.font = [UIFont systemFontOfSize:14.0f];
        self.imageCountLabel.textColor = [UIColor whiteColor];
        [self.topView addSubview:self.imageCountLabel];
        
        rect = CGRectMake(CGRectGetWidth(self.topView.bounds)-60, 0, 60, CGRectGetHeight(self.topView.bounds));
        self.nextButton = [[UIButton alloc] initWithFrame:rect];
        [self.nextButton setTitle:@"继续" forState:UIControlStateNormal];
        [self.nextButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
        [self.nextButton setTitleColor:THEME_COLOR_LIGHT_GREY forState:UIControlStateNormal];
        [self.nextButton addTarget:self action:@selector(cropAction) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:self.nextButton];

    }
    return _topView;
}


- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        CGFloat colum = 3.0, spacing = 2.0;
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
        _collectionView.allowsMultipleSelection = YES;
        
        [_collectionView registerClass:[PhotoPickerCollectionViewCell class] forCellWithReuseIdentifier:@"PhotoCollectionViewCell"];
        
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
        _albumTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,self.topView.bounds.size.height, self.topView.bounds.size.width, 0)];
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

-(void)hideOrShowAlbumTableView
{
    
    if (self.albumTableView.frame.size.height >0)
    {
        CGRect topFrame = self.topView.frame;
        CGRect newTableFrame = CGRectMake(0,topFrame.size.height, topFrame.size.width, 0);
        [UIView animateWithDuration:0.3 animations:^{
             [self.albumTableView setFrame:newTableFrame];
        } completion:^(BOOL finished) {
            [self setTitleLabelText:currentSelectAlbumName withIcon:@"arrow_down"];
            //self.titleLabelIcon.image = [UIImage imageNamed:@"arrow_down"];
        }];
       
    }
    else
    {
        CGRect topFrame = self.topView.frame;
        CGRect newTableFrame = CGRectMake(0,topFrame.size.height, topFrame.size.width, self.view.frame.size.height - topFrame.size.height);
        [UIView animateWithDuration:0.3 animations:^{
            [self.albumTableView setFrame:newTableFrame];
        } completion:^(BOOL finished) {
            [self setTitleLabelText:currentSelectAlbumName withIcon:@"arrow_up"];
           // self.titleLabelIcon.image = [UIImage imageNamed:@"arrow_up"];
        }];
    }
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
    static NSString *CellIdentifier = @"PhotoCollectionViewCell";
    
    PhotoPickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageWithCGImage:[[self.assets objectAtIndex:indexPath.row] thumbnail]];
    
    return cell;
}

#pragma mark - Collection View Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (selectedImageCount ==9)
    {
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        return;
    }
    selectedImageCount ++;
    [self.nextButton setTitleColor:THEME_COLOR_DARK forState:UIControlStateNormal];
    [self.nextButton setEnabled:YES];
    self.imageCountLabel.text = [NSString stringWithFormat:@"%ld/9",(long)selectedImageCount];
    ALAsset * asset = [self.assets objectAtIndex:indexPath.row];
    UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage scale:1.0f orientation:UIImageOrientationUp];
   // UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage scale:asset.defaultRepresentation.scale orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
    ALAssetRepresentation *rep = [[self.assets objectAtIndex:indexPath.row]defaultRepresentation];
    NSDictionary *imageInfo = rep.metadata;
    [self.imagesAndInfo addObject:@{@"image":image,@"imageInfo":imageInfo,@"indexPath":indexPath}];
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    selectedImageCount --;
    if (selectedImageCount == 0)
    {
        [self.nextButton setTitleColor:THEME_COLOR_LIGHT_GREY forState:UIControlStateNormal];
        [self.nextButton setEnabled:NO];
    }
    [self.imagesAndInfo enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        if ([item objectForKey:@"indexPath"] == indexPath)
        {
            [self.imagesAndInfo removeObjectAtIndex:idx];
            *stop = YES;
        }
    }];
    self.imageCountLabel.text = [NSString stringWithFormat:@"%ld/9",(long)selectedImageCount];
}

#pragma mark - TableView Delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"albumTableViewCell" forIndexPath:indexPath];
    NSDictionary *data = [self.albumMenuItems objectAtIndex:indexPath.row];
    cell.albumLastImageView.image = data[@"albumImage"];
    [cell.albumLastImageView.layer setCornerRadius:2.0f];
    [cell.albumLastImageView.layer setMasksToBounds:YES];
    cell.albumNameLabel.text = data[@"albumName"];
    cell.albumPhotoNumLabel.text = [data[@"albumPhotoNum"] stringValue];
    if ([cell.albumNameLabel.text isEqualToString:currentSelectAlbumName])
    {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
       // [cell setSelected:YES];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setBackgroundColor:[UIColor blackColor]];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"select %@",[self.albumMenuItems objectAtIndex:indexPath.row]);
    currentSelectAlbumName = [[self.albumMenuItems objectAtIndex:indexPath.row] valueForKey:@"albumName"];
    [self hideOrShowAlbumTableView];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - gesture action
-(void)titleLabelClick
{
    [self hideOrShowAlbumTableView];
}

@end
