//
//  DynamicResizingTableViewCell.m
//  WUZHAO
//
//  Created by yiyi on 15/5/6.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "DynamicResizingTableViewCell.h"

@implementation DynamicResizingTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(void)initialize
{
    cellArray = [NSMutableArray array];
}

+(CGSize)sizeForCellWithDefaultSize:(CGSize)defaultSize setupCellBlock:(setupCellBlock)block
{
    __block UITableViewCell *cell = nil;
    
    [cellArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ( [obj isKindOfClass:[[self class] class]])
        {
            cell = obj;
            *stop = YES;
        }
    }];
    if (!cell)
    {
        cell = [[[self class]alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DynamicSizingCell"];
        cell.frame = CGRectMake(0 , 0, defaultSize.width, defaultSize.height);
        [cellArray addObject:cell];
    }
    cell = block((id<DynamicResizingCellProtocol>)cell);
    
    CGSize size = [((UITableViewCell *)cell).contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    size.width = MAX(defaultSize.width, size.width);
    return size;
}
@end
