//
//  PhotoCollectionViewCell.h
//  WUZHAO
//
//  Created by yiyi on 14-12-17.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WhatsGoingOn.h"

@interface PhotoCollectionViewCell : UICollectionViewCell
@property (nonatomic,strong) IBOutlet UIImageView  *cellImageView;
@property (nonatomic, strong) IBOutlet UILabel *imageCountLabel;


-(void) hideImageCountLabel;
-(void) showImageCountLabel:(NSInteger)count;

-(void)configureWithContent:(WhatsGoingOn *)content;
@end
