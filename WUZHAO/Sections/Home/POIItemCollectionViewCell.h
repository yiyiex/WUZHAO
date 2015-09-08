//
//  POIItemCollectionViewCell.h
//  WUZHAO
//
//  Created by yiyi on 15/8/31.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface POIItemCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UILabel *POINameLabel;

-(void)setPOIName:(NSString *)POIName;

@end
