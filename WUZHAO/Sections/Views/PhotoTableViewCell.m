//
//  PhotoTableViewCell.m
//  WUZHAO
//
//  Created by yiyi on 14-12-15.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "PhotoTableViewCell.h"
#import "UIImageView+WebCache.h"

@implementation PhotoTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setWhatsGoingOnItem:(WhatsGoingOn *)whatsGoingOnItem
{
    _whatsGoingOnItem = whatsGoingOnItem;
    self.likeLabel.text = [NSString stringWithFormat:@"%@ 次赞", whatsGoingOnItem.likeCount];
    if (whatsGoingOnItem.attributedComment)
    {
        self.commentLabel.attributedText = whatsGoingOnItem.attributedComment;
        
    }
    else
    {
        self.commentLabel.attributedText = [self.commentLabel filterLinkWithContent:whatsGoingOnItem.comment];
    }
    [self.homeCellImageView sd_setImageWithURL:[NSURL URLWithString:whatsGoingOnItem.imageUrlString]
                              placeholderImage:[UIImage imageNamed:@"placeholder"]];
    self.homeCellImageView.backgroundColor = [UIColor blackColor];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
