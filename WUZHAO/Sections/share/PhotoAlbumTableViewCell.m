//
//  PhotoAlbumTableViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/7/1.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "PhotoAlbumTableViewCell.h"
#import "macro.h"
#define CELLHEIGHT 56
@implementation PhotoAlbumTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.albumNameLabel.textColor = selected? THEME_COLOR_DARK : THEME_COLOR_WHITE;
    self.albumNameLabel.font = selected?  WZ_FONT_LARGE_BOLD_SIZE :WZ_FONT_LARGE_SIZE;
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

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.albumNameLabel.textColor = selected? THEME_COLOR_DARK : THEME_COLOR_WHITE;
    self.albumNameLabel.font = selected?  WZ_FONT_LARGE_BOLD_SIZE :WZ_FONT_LARGE_SIZE;
}

@end