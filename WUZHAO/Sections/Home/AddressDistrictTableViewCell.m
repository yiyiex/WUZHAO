//
//  AddressPOITableViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/8/31.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "AddressDistrictTableViewCell.h"
#import "DistrictItemCollectionViewCell.h"
#import "UIImageView+WebCache.h"



@implementation AddressDistrictTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self initViews];
}

-(void)initViews
{
    [self.collectionView setScrollEnabled:NO];
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView registerNib:[UINib nibWithNibName:@"DistrictItemCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"DistrictItem"];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - collectionview delegate and datasource
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float width = (self.collectionView.frame.size.width-32)/3;
    float height = width*9/16;
    return CGSizeMake(width, height);
}


-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 8.0f;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 4.0f;
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section

{
    return UIEdgeInsetsMake(8, 8, 0, 8);
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DistrictItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DistrictItem" forIndexPath:indexPath];
    if (!cell)
    {
        cell = [[DistrictItemCollectionViewCell alloc]init];
    }
    District *district = self.DistrictList[indexPath.item];
    cell.DistrictNameLabel.text = district.districtName;
    [cell.districtImage sd_setImageWithURL:[NSURL URLWithString:district.defaultImageUrl]];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.DistrictList.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    District *district = self.DistrictList[indexPath.item];
    if ([self.delegate respondsToSelector:@selector(gotoDistrictPageWithDisctrict:)])
    {
        [self.delegate gotoDistrictPageWithDisctrict:district];
    }

}

@end
