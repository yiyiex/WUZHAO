//
//  HomeTableCell.m
//  Dtest3
//
//  Created by yiyi on 14-10-23.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "HomeTableCell.h"
#import "UIImageView+WebCache.h"

#import "WhatsGoingOn.h"

#import "WPHotspotLabel.h"

@implementation HomeTableCell

- (void)setAvatorImage
{
    self.HomeCellAvatorImageView.layer.cornerRadius = self.HomeCellAvatorImageView.frame.size.width/3.5;
    self.HomeCellAvatorImageView.clipsToBounds = YES;
    
}
- (void)setWhatsGoinOnItem:(WhatsGoingOn *)whatsGoinOnItem
{
    _whatsGoinOnItem = whatsGoinOnItem;
    self.likeLabel.text = [NSString stringWithFormat:@"%@ 次赞", whatsGoinOnItem.likeCount];
    if (whatsGoinOnItem.attributedComment)
    {
        self.commentLabel.attributedText = whatsGoinOnItem.attributedComment;
        
    }
    else
    {
        self.commentLabel.attributedText = [self.commentLabel filterLinkWithContent:whatsGoinOnItem.comment];
    }
    [self.HomeCellImageView sd_setImageWithURL:[NSURL URLWithString:whatsGoinOnItem.imageUrlString]
                              placeholderImage:[UIImage imageNamed:@"placeholder"]];
    self.HomeCellImageView.backgroundColor = [UIColor blackColor];
    
}


- (void)awakeFromNib {
    // Initialization code
    NSLog(@"init a cell");
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

@end
