//
//  DynamicResizingCellProtocol.h
//  WUZHAO
//
//  Created by yiyi on 15/5/6.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

@protocol DynamicResizingCellProtocol;

static CGFloat DynamicTableViewCellAccessoryWidth = 33;

static NSMutableArray *cellArray;

typedef id(^setupCellBlock) (id<DynamicResizingCellProtocol>cellToSetup);

@protocol DynamicResizingCellProtocol <NSObject>
+(CGSize)sizeForCellWithDefaultSize:(CGSize)defaultSize setupCellBlock:(setupCellBlock)block;
@end
