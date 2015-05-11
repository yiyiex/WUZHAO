//
//  MenuItem.m
//  WUZHAO
//
//  Created by yiyi on 15/5/7.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "MenuItem.h"

@interface MenuItem()

@property (nonatomic, strong) UILabel *itemTitleLabel;


@end

@implementation MenuItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self = [self initWithFrame:frame title:nil];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame title:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.itemTitleLabel = [[UILabel alloc]initWithFrame:frame];
        [self.itemTitleLabel setText:title];
        [self.itemTitleLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    MenuItem *itemCopy = [[MenuItem alloc]init];
    
    itemCopy.itemTitleLabel = _itemTitleLabel;
    itemCopy.itemTitleString = _itemTitleString;
    itemCopy.index = _index;
    
    return itemCopy;
}





@end
