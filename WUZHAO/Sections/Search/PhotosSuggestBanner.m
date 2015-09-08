//
//  PhotosSuggestCollectionHeader.m
//  WUZHAO
//
//  Created by yiyi on 15/8/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "PhotosSuggestBanner.h"

@implementation PhotosSuggestBanner

- (void)awakeFromNib {
    // Initialization code
    [self initViews];
}

-(void)initViews
{
    self.bannerScrollView.minimumPageAlpha = 1.0f;
    self.bannerScrollView.minimumPageScale = 1.0f;
   // self.bannerScrollView.pageControl = self.bannerPageControl;
}

-(void)setDataSource:(id<PagedFlowViewDataSource>)dataSource
{
    self.bannerScrollView.dataSource = dataSource;
}

-(void)setDelegate:(id<PagedFlowViewDelegate>)delegate
{
    self.bannerScrollView.delegate = delegate;
}

@end
