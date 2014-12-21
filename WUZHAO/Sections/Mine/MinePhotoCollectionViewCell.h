//
//  MinePhotoCollectionViewCell.h
//  Dtest3
//
//  Created by yiyi on 14-11-6.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WhatsGoingOn.h"
@interface MinePhotoCollectionViewCell : UICollectionViewCell
@property (nonatomic,strong) IBOutlet UIImageView  *cellImageView;
@property (nonatomic,strong) WhatsGoingOn * cellWhatsGoingOnItem;
@end
