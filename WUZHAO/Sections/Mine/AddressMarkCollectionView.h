//
//  AddressMarkCollectionView.h
//  WUZHAO
//
//  Created by yiyi on 15/7/23.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressMarkCollectionView : UIView

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UICollectionView *photoCollectionView;


-(void)setDatasource:(id<UICollectionViewDataSource>)datasource;
-(void)setDelegate:(id<UICollectionViewDelegate>)delegate;

-(void)resizeWithContentCount:(float)count;

-(void)setTitleNum:(NSInteger)num;

-(void)showView;

-(void)hideView;


@end
