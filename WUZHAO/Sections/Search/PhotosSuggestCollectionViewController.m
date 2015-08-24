//
//  PhotosSuggestCollectionViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/8/9.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "PhotosSuggestCollectionViewController.h"
#import "PhotosSuggestCollectionHeader.h"
#import "PhotoCollectionViewCell.h"
#import "HomeTableViewController.h"
#import "SubjectViewController.h"

#import "QDYHTTPClient.h"
#import "SVProgressHUD.h"
#import "Subject.h"
#import "macro.h"
#import "UIImageView+WebCache.h"

#define bannerHeight 164

@interface PhotosSuggestCollectionViewController ()
@property (nonatomic, strong) NSArray *subjectList;

@end

@implementation PhotosSuggestCollectionViewController

static NSString * const reuseIdentifier = @"photoCollectionViewCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupRefreshControl];
    [self.collectionView registerNib:[UINib nibWithNibName:@"PhotosCollectionCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"PhotosSuggestCollectionHeader" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"banner"];
    
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.datasource.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell *cell =(PhotoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[PhotoCollectionViewCell alloc]init];
    }
    [cell configureWithContent:self.datasource[indexPath.item]];
    return cell;
}
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    PhotosSuggestCollectionHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"banner" forIndexPath:indexPath];
    [self fillBannerWithHeaderView:header];
    return header;
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(WZ_APP_SIZE.width, 0);
    /*
    if (self.subjectList.count <=0)
    {
        return CGSizeMake(WZ_APP_SIZE.width, 0);
    }
    else
    {
        return CGSizeMake(WZ_APP_SIZE.width, bannerHeight);
    }*/
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
    return CGSizeMake((self.collectionView.frame.size.width-4)/3, (self.collectionView.frame.size.width-4)/3);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WhatsGoingOn *item = self.datasource[indexPath.item];
    if (item)
    {
        [self gotoPhotoDetailPageWithItem:item];
    }
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
    NSInteger userId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    [[QDYHTTPClient sharedInstance]explorephotoWithUserId:userId whenComplete:^(NSDictionary *returnData)
    {
        self.shouldRefreshData = YES;
        if ([returnData objectForKey:@"data"])
        {
            self.datasource = [[returnData objectForKey:@"data"]mutableCopy];
            [self loadData];
        }
        else if ([returnData objectForKey:@"error"])
        {
            [SVProgressHUD showErrorWithStatus:[returnData objectForKey:@"error"]];
        }
        [self endRefreshing];
        
    }];
}
-(void)getLatestSubjects
{
    [[QDYHTTPClient sharedInstance]getSubjectListBannerWhenComplete:^(NSDictionary *result) {
        if ([result objectForKey:@"data"])
        {
            self.subjectList = [result objectForKey:@"data"];
            [self loadData];
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
-(void)fillBannerWithHeaderView:(PhotosSuggestCollectionHeader *)header
{
    for (UIView *view in header.bannerScrollView.subviews)
    {
        if ([view isKindOfClass:[UIImageView class]])
        {
            [view removeFromSuperview];
        }
    }
    if (self.subjectList.count >0)
    {
        [header.bannerPageControl setPageIndicatorTintColor:[UIColor whiteColor]];
        [header.bannerPageControl setNumberOfPages:self.subjectList.count];
        [header.bannerPageControl setCurrentPage:0];
        [header.bannerScrollView setContentSize:CGSizeMake(WZ_APP_SIZE.width*self.subjectList.count, bannerHeight)];
        [header.bannerScrollView setPagingEnabled:YES];
        [self.collectionView.panGestureRecognizer requireGestureRecognizerToFail:header.bannerScrollView.panGestureRecognizer];
        [self.subjectList enumerateObjectsUsingBlock:^(Subject *obj, NSUInteger idx, BOOL *stop) {
            UIImageView *subjectImageView = [[UIImageView alloc]initWithFrame:CGRectMake(idx*WZ_APP_SIZE.width, 2, WZ_APP_SIZE.width, bannerHeight-4)];
            [subjectImageView sd_setImageWithURL:[NSURL URLWithString:obj.backgroundImageUrlString]];
            [subjectImageView setContentMode:UIViewContentModeScaleToFill];
            subjectImageView.tag = idx;
            [subjectImageView setUserInteractionEnabled:YES];
            UITapGestureRecognizer *subjectImageTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(subjectImageTapped:)];
            [subjectImageView addGestureRecognizer:subjectImageTap];
            [header.bannerScrollView addSubview:subjectImageView];
            
            UIView *maskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, subjectImageView.frame.size.width, subjectImageView.frame.size.height)];
            [maskView.layer setBackgroundColor:[THEME_COLOR_DARK_GREY_PARENT CGColor]];
            maskView.layer.cornerRadius = 3.0f;
            maskView.layer.masksToBounds = YES;
            [subjectImageView addSubview:maskView];
            
            UILabel *titleLabel = [[UILabel alloc]init];
            [titleLabel setTextColor:[UIColor whiteColor]];
            [titleLabel setFont:WZ_FONT_HIRAGINO_MID_SIZE];
            [titleLabel setTextAlignment:NSTextAlignmentCenter];
            titleLabel.text = obj.title;
            [titleLabel sizeToFit];
            [titleLabel setCenter:subjectImageView.center];
            [subjectImageView addSubview:titleLabel];
            
            
            
        }];
    }
}

#pragma mark - action
-(void)subjectImageTapped:(UIGestureRecognizer *)gesture;
{
    UIImageView *imageView =(UIImageView *) gesture.view;
    Subject *subject = self.subjectList[imageView.tag];
    [self gotoSubjectPageWithSubject:subject];
}

#pragma mark - transition
-(void)gotoSubjectPageWithSubject:(Subject *)subject
{
    SubjectViewController *subjectViewController = [[SubjectViewController alloc]init];
    subjectViewController.subject = subject;
    [self pushToViewController:subjectViewController animated:YES hideBottomBar:YES];
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
