//
//  MineViewController.h
//  Dtest3
//
//  Created by yiyi on 14-11-6.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MinePhotoCollectionViewCell.h"
@interface MineViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *imageArrary;
    NSArray *_objects;
    NSArray *_commentsOfObjects;
}
@property (strong,nonatomic)IBOutlet UICollectionView *allPicCollectionView;
@property (nonatomic,strong)IBOutlet UIImage *mineIconImage;
@end
