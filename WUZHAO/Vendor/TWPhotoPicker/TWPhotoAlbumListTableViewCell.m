//
//  TWPhotoAlbumListTableViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/5/8.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "TWPhotoAlbumListTableViewCell.h"
#define CELLHEIGHT 56
@implementation TWPhotoAlbumListTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        self.albumLastImageView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 4, CELLHEIGHT-8, CELLHEIGHT-8)];
        self.albumNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CELLHEIGHT, CELLHEIGHT/2 -15, 30, 30)];
        [self.contentView addSubview:self.albumLastImageView];
        [self.contentView addSubview:self.albumNameLabel];
    }
    return self;
}


@end
