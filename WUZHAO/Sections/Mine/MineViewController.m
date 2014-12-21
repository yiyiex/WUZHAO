//
//  MineViewController.m
//  Dtest3
//
//  Created by yiyi on 14-11-6.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "MineViewController.h"
#import "MinePhotoCollectionViewCell.h"
#import "MyPhotoDetailViewController.h"
#import "UIImageView+WebCache.h"


@interface MineViewController ()
@property (nonatomic, strong) NSMutableArray * myPhotosCollectionDatasource;
@end

@implementation MineViewController
@synthesize allPicCollectionView;
static NSString * const minePhotoCell = @"minePhotosCell";
//@synthesize collectionView;
- (void)viewDidLoad {
 
    [super viewDidLoad];
    self.myPhotosCollectionDatasource = [[WhatsGoingOn newDataSource]mutableCopy];
    //[self.view addSubview:self.collectionView];
    NSLog(@"the collection x point:%f",self.allPicCollectionView.frame.origin.x);
    NSLog(@"the collection y point:%f",self.allPicCollectionView.frame.origin.y);
    NSLog(@"the width of the collection:%f",self.allPicCollectionView.frame.size.width);
    NSLog(@"the height of the collection:%f",self.allPicCollectionView.frame.size.height);
    //[self.allPicCollectionView registerClass:[MinePhotoCollectionViewCell class] forCellWithReuseIdentifier:minePhotoCell];
    _objects = [NSArray arrayWithObjects:
                @"http://img3.douban.com/view/photo/photo/public/p2206858462.jpg",
                @"http://img3.douban.com/view/photo/photo/public/p2206860902.jpg",
                @"http://img3.douban.com/view/photo/photo/public/p2206861122.jpg",
                @"http://img3.douban.com/view/photo/photo/public/p2206861334.jpg",
                @"http://img5.douban.com/view/photo/photo/public/p2206861688.jpg",
                @"http://img5.douban.com/view/photo/photo/public/p2206861688.jpg",
                @"http://img5.douban.com/view/photo/photo/public/p2206861688.jpg",
                @"http://img5.douban.com/view/photo/photo/public/p2206861688.jpg",
                @"http://img5.douban.com/view/photo/photo/public/p2206861688.jpg",
                @"http://img5.douban.com/view/photo/photo/public/p2206861688.jpg",
                @"http://img5.douban.com/view/photo/photo/public/p2206861688.jpg",
                @"http://img5.douban.com/view/photo/photo/public/p2206861688.jpg",
                @"http://img5.douban.com/view/photo/photo/public/p2206861688.jpg",
                @"http://img5.douban.com/view/photo/photo/public/p2206861688.jpg",
                @"http://img5.douban.com/view/photo/photo/public/p2206861688.jpg",
                @"http://img5.douban.com/view/photo/photo/public/p2206861688.jpg",
                @"http://img5.douban.com/view/photo/photo/public/p2206861688.jpg",
                @"http://img5.douban.com/view/photo/photo/public/p2206861688.jpg",
                @"http://img5.douban.com/view/photo/photo/public/p2206861688.jpg",
                @"http://img5.douban.com/view/photo/photo/public/p2206861688.jpg",
                @"http://img5.douban.com/view/photo/photo/public/p2206861688.jpg",nil];
    _commentsOfObjects = [NSArray arrayWithObjects:@"comments test1",@"comments test2",@"comments test3",@"comments test4",@"comments test5", nil];
    
    //[self.collectionView reloadData];
   
    // Do any additional setup after loading the view.
}
/*
- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(100,0, 372, 400)];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[MinePhotoCollectionViewCell class] forCellWithReuseIdentifier:minePhotoCell];
        [_collectionView setBackgroundColor:[UIColor redColor]];
        
    }
    NSLog(@"init the collectionView");
    return _collectionView;
}
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.myPhotosCollectionDatasource.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MinePhotoCollectionViewCell *cell =(MinePhotoCollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:minePhotoCell forIndexPath:indexPath];
    cell.cellWhatsGoingOnItem = [self.myPhotosCollectionDatasource objectAtIndex:indexPath.row];

    [cell.cellImageView sd_setImageWithURL:[NSURL URLWithString:cell.cellWhatsGoingOnItem.imageUrlString] placeholderImage:[UIImage imageNamed:@"placeholder"] options:indexPath.row ==0?SDWebImageRefreshCached : 0];
    
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake((self.allPicCollectionView.frame.size.width-6)/4,(self.allPicCollectionView.frame.size.width-6)/4);
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(1, 1, 1, 1);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
        
        NSIndexPath *selectedIndexPath = [[self.allPicCollectionView indexPathsForSelectedItems] firstObject];
        MyPhotoDetailViewController *detailViewController = [segue destinationViewController];
        WhatsGoingOn *item = [self.myPhotosCollectionDatasource objectAtIndex:selectedIndexPath.row];
        [detailViewController setWhatsGoingOnItem:item];
    }
}

-(BOOL)collectionView:(UICollectionView *)cv shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(void)collectionView:(UICollectionView *)cv didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MinePhotoCollectionViewCell *cell = (MinePhotoCollectionViewCell *)[cv cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
}
@end
