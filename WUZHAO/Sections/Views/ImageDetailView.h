//
//  ImageDetailView.h
//  WUZHAO
//
//  Created by yiyi on 15/8/19.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageDetailView : UIView

-(instancetype)initWithImages:(NSArray *)images currentImageIndex:(NSInteger)index;

-(instancetype)initWithImageUrls:(NSArray *)imageUrls currentImageIndex:(NSInteger)index;

-(instancetype)initWithImageUrls:(NSArray *)imageUrls currentImageIndex:(NSInteger)index placeHolderImages:(NSArray *)placeHolderImages;

-(void)setImagesInfo:(NSArray *)info;

-(void)show;

@end
