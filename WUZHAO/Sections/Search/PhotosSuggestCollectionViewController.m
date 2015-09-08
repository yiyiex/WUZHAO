//
//  PhotosSuggestCollectionViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/8/9.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "PhotosSuggestCollectionViewController.h"
#import "PhotoCollectionViewCell.h"
#import "HomeTableViewController.h"
#import "SubjectViewController.h"
#import "SuggestPhotosCollectionReusableView.h"
#import "PhotosSuggestBanner.h"
#import "SearchViewController.h"


#import "QDYHTTPClient.h"
#import "SVProgressHUD.h"
#import "Subject.h"
#import "macro.h"
#import "UIImageView+WebCache.h"

#define bannerWidth WZ_APP_SIZE.width
#define bannerHeight WZ_APP_SIZE.width*0.4

@interface PhotosSuggestCollectionViewController ()<PagedFlowViewDataSource,PagedFlowViewDelegate>

@property (nonatomic, strong) PhotosSuggestBanner *banner;

@property (nonatomic, strong) NSArray *subjectList;
@property (nonatomic, strong) NSMutableArray *topListDatasource;
@property (nonatomic, strong) NSMutableArray *latestListDatasource;
@property (nonatomic, strong) UIActivityIndicatorView *aiv;

@end

@implementation PhotosSuggestCollectionViewController

static NSString * const reuseIdentifier = @"photoCollectionViewCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupRefreshControl];
    [self.collectionView registerNib:[UINib nibWithNibName:@"PhotosCollectionCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"PhotosSuggestBanner" bundle:nil] forCellWithReuseIdentifier:@"banner"];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UIActivityIndicatorView *)aiv
{
    if (!_aiv)
    {
        _aiv = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _aiv;
}

-(void)viewDidAppear:(BOOL)animated
{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    if ([[NSUserDefaults standardUserDefaults]valueForKey:@"launchIndex"])
    {
        NSInteger launchIndex = [[userdefaults valueForKey:@"launchIndex"]integerValue];
        if (launchIndex == 1 )
        {
            if ([userdefaults valueForKey:@"subjectId"])
            {
                NSInteger subjectId = [[userdefaults valueForKey:@"subjectId"]integerValue];
                if (subjectId >0)
                {
                    Subject *subject = [[Subject alloc]init];
                    subject.subjectId = subjectId;
                    [self gotoSubjectPageWithSubject:subject];
                }
                [userdefaults removeObjectForKey:@"subjectId"];
            }
            [userdefaults removeObjectForKey:@"launchIndex"];
            [userdefaults synchronize];
        }
    }
}


#pragma mark - collection view delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section>0)
    {
        SuggestPhotosCollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headView" forIndexPath:indexPath];
        [view.refreshButton setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
         [view.refreshButton setImage:[UIImage imageNamed:@"refresh_h"] forState:UIControlStateHighlighted];
        [view.refreshButton setTintColor:THEME_COLOR_LIGHT_GREY];
        if (indexPath.section == 1)
        {
            view.headLabel.text = @"最新";
            [view.refreshButton setHidden:YES];
            //[view.refreshButton addTarget:self action:@selector(refreshLatestPhotos:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if (indexPath.section == 2)
        {
            view.headLabel.text= @"精选";
            [view.refreshButton setHidden:NO];
            [view.refreshButton addTarget:self action:@selector(refreshSelectedPhotos:) forControlEvents:UIControlEventTouchUpInside];
        }
        return view;
    }
    return nil;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return CGSizeMake(collectionView.frame.size.width, 0);
    }
    else if (section == 1)
    {
        if (self.latestListDatasource.count >0)
        {
            return CGSizeMake(collectionView.frame.size.width, 40);
        }
        else
        {
            return CGSizeMake(collectionView.frame.size.width, 0);
        }
    }
    else if(section == 2)
    {
        if (self.topListDatasource.count >0)
        {
            return CGSizeMake(collectionView.frame.size.width, 40);
        }
        else
        {
            return CGSizeMake(collectionView.frame.size.width, 0);
        }
    }
    else
    {
        return CGSizeMake(collectionView.frame.size.width, 0);
    }
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 1)
    {
        return self.latestListDatasource.count;
    }
    else if (section == 2)
    {
        return self.topListDatasource.count;
    }
    return 1;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (!self.banner)
        {
            PhotosSuggestBanner *bannerCell = (PhotosSuggestBanner *)[collectionView dequeueReusableCellWithReuseIdentifier:@"banner" forIndexPath:indexPath];
            [bannerCell.bannerScrollView setDelegate:self];
            [bannerCell.bannerScrollView setDataSource:self];
            [bannerCell.bannerScrollView reloadData];
            PagedFlowView *flowView = bannerCell.bannerScrollView;
            
            [self.collectionView.panGestureRecognizer requireGestureRecognizerToFail:flowView.scrollView.panGestureRecognizer];
            if (self.parentViewController.parentViewController.parentViewController)
            {
                UIViewController *viewCon = self.parentViewController.parentViewController.parentViewController;
                if ([viewCon isKindOfClass:[SearchViewController class]])
                {
                    SearchViewController *searchCon = (SearchViewController *)viewCon;
                    
                    UIScrollView *parentScrollView =(UIScrollView *) searchCon.containerView;
                    [parentScrollView.panGestureRecognizer requireGestureRecognizerToFail:flowView.scrollView.panGestureRecognizer];
                }
            }
            self.banner = bannerCell;
        }
        return self.banner;
    }
    if (indexPath.section >0)
    {
        PhotoCollectionViewCell *cell =(PhotoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        if (cell == nil)
        {
            cell = [[PhotoCollectionViewCell alloc]init];
        }
        
        [cell configureWithContent:[self dataAtIndexPath:indexPath]];
        return cell;
    }
    return [[UICollectionViewCell alloc]init];
}


-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0f;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0f;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section >0)
    {
        return CGSizeMake((self.collectionView.frame.size.width-4)/3, (self.collectionView.frame.size.width-4)/3);
    }
    else if (indexPath.section == 0)
    {
        if (self.subjectList.count >0)
        {
            return CGSizeMake(self.collectionView.frame.size.width, bannerHeight);
        }
        else
        {
            return CGSizeMake(self.collectionView.frame.size.width, 0);
        }
    }
    else return CGSizeMake(0, 0);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WhatsGoingOn *item = [self dataAtIndexPath:indexPath];
    if (item)
    {
        [self gotoPhotoDetailPageWithItem:item];
    }
}
-(WhatsGoingOn *)dataAtIndexPath:(NSIndexPath *)indexPath
{
    WhatsGoingOn *item;
    if (indexPath.section == 1)
    {
        item = self.latestListDatasource[indexPath.item];
    }
    else if (indexPath.section == 2)
    {
        item = self.topListDatasource[indexPath.item];
    }
    return item;
}

#pragma mark - transition
-(void)gotoPhotoDetailPageWithItem:(WhatsGoingOn *)item
{
    
    UIStoryboard *whatsNew = [UIStoryboard storyboardWithName:@"WhatsNew" bundle:nil];
    HomeTableViewController *detailPhotoController  = [whatsNew instantiateViewControllerWithIdentifier:@"HomeTableViewController"];
    [detailPhotoController setDatasource:[NSMutableArray arrayWithObject:item]];
    [detailPhotoController setTableStyle:WZ_TABLEVIEWSTYLE_DETAIL];
    [self pushToViewController:detailPhotoController animated:YES hideBottomBar:YES];
    //[detailPhotoController GetLatestDataList];
}

#pragma mark - control the model
-(void)getLatestData
{
    if (!self.shouldRefreshData)
    {
        return;
    }
    self.shouldRefreshData = NO;
    [self getLatestSubjects];
    [self getLatestPhotos];
    [self getSelectedPhotos];
}

-(void)getLatestPhotos
{
    [[QDYHTTPClient sharedInstance]exploreLatestPhotosWhenComplete:^(NSDictionary *returnData) {
        self.shouldRefreshData = YES;
        if ([returnData objectForKey:@"data"])
        {
            self.latestListDatasource = [[returnData objectForKey:@"data"]mutableCopy];
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
        }
        else if ([returnData objectForKey:@"error"])
        {
            [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
        }
        [self endRefreshing];
    }];
}


-(void)getSelectedPhotos
{
    [[QDYHTTPClient sharedInstance]exploreSelectedPhotosWhenComplete:^(NSDictionary *returnData) {
        self.shouldRefreshData = YES;
        if ([returnData objectForKey:@"data"])
        {
            self.topListDatasource = [[returnData objectForKey:@"data"]mutableCopy];
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:2]];
        }
        else if ([returnData objectForKey:@"error"])
        {
            [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
        }
        [self endRefreshing];
    }];
}
-(void)refreshSelectedPhotos:(UIButton *)button
{
    [button addSubview:self.aiv];
    [self.aiv setCenter:CGPointMake(18, 18)];
    [self.aiv startAnimating];
    [button setImage:nil forState:UIControlStateNormal];
    [[QDYHTTPClient sharedInstance]exploreSelectedPhotosWhenComplete:^(NSDictionary *returnData) {
        self.shouldRefreshData = YES;
        if ([returnData objectForKey:@"data"])
        {
            self.topListDatasource = [[returnData objectForKey:@"data"]mutableCopy];
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:2]];
        }
        else if ([returnData objectForKey:@"error"])
        {
            [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
        }
        [self.aiv stopAnimating];
        [self.aiv removeFromSuperview];
        [button setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    }];
    
}
-(void)getLatestSubjects
{
    [[QDYHTTPClient sharedInstance]getSubjectListBannerWhenComplete:^(NSDictionary *result) {
        self.shouldRefreshData = YES;
        if ([result objectForKey:@"data"])
        {
            self.subjectList = [result objectForKey:@"data"];
            NSIndexSet *set = [NSIndexSet indexSetWithIndex:0];
            self.banner = nil;
            [self .collectionView reloadSections:set];
        }
        else if ([result objectForKey:@"error"])
        {
            NSLog(@"get sublect list error");
        }
        else
        {
            NSLog(@"internet request error");
        }
        [self endRefreshing];
    }];
}

#pragma mark - action
-(void)subjectImageTapped:(NSInteger)index
{
    if (![self.subjectList objectAtIndex:index])
        return;
    Subject *subject = self.subjectList[index];
    [self gotoSubjectPageWithSubject:subject];
}

#pragma mark - transition
-(void)gotoSubjectPageWithSubject:(Subject *)subject
{
    SubjectViewController *subjectViewController = [[SubjectViewController alloc]init];
    subjectViewController.subject = subject;
    [self pushToViewController:subjectViewController animated:YES hideBottomBar:YES];
}

#pragma mark - pagedflowView
-(CGSize)sizeForPageInFlowView:(PagedFlowView *)flowView
{
    return CGSizeMake(bannerWidth, bannerHeight);
}
-(UIView *)flowView:(PagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index
{
    Subject *subject = self.subjectList[index];
    
    UIImageView *subjectImageView = [[UIImageView alloc]init];
   // imageView.layer.cornerRadius = 6.0f;
    subjectImageView.layer.masksToBounds = YES;
    [subjectImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    UIView *maskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, bannerWidth, bannerHeight)];
    [maskView.layer setBackgroundColor:[THEME_COLOR_DARK_GREY_MORE_PARENT CGColor]];
    [subjectImageView addSubview:maskView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, bannerWidth, 40)];
    [titleLabel setNumberOfLines:1];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:WZ_FONT_HIRAGINO_MID_SIZE];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.text = subject.title;
    [titleLabel sizeToFit];
    [titleLabel setCenter:CGPointMake(bannerWidth/2, bannerHeight/2)];
    [subjectImageView addSubview:titleLabel];

    [subjectImageView sd_setImageWithURL:[NSURL URLWithString:subject.backgroundImageUrlString]];
    return subjectImageView;
}
-(void)flowView:(PagedFlowView *)flowView didTapPageAtIndex:(NSInteger)index
{
    [self subjectImageTapped:index];
}
-(NSInteger)numberOfPagesInFlowView:(PagedFlowView *)flowView
{
    return self.subjectList.count;
}



@end
