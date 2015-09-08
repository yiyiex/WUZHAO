//
//  AddressPOITableViewCell.h
//  WUZHAO
//
//  Created by yiyi on 15/8/31.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "District.h"
#import "POI.h"

@protocol AddressDistrictTableViewCellDelegate;

@interface AddressDistrictTableViewCell : UITableViewCell <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) id<AddressDistrictTableViewCellDelegate> delegate;

@property (nonatomic, strong) NSArray *DistrictList;
@end

@protocol AddressDistrictTableViewCellDelegate <NSObject>
-(void)gotoDistrictPageWithDisctrict:(District *)district;

@end


