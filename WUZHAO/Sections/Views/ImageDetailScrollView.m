//
//  ImageDetailScrollView.m
//  WUZHAO
//
//  Created by yiyi on 15/8/28.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "ImageDetailScrollView.h"
#import "ImageDetailItem.h"

@implementation ImageDetailScrollView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    __block CGRect frame = self.bounds;
    
    CGFloat w = frame.size.width ;
    
    frame.size.width =w - Margin;
    
    [self.subviews enumerateObjectsUsingBlock:^(ImageDetailItem *photoItemView, NSUInteger idx, BOOL *stop) {
        
        CGFloat x = w * photoItemView.pageIndex;
        
        frame.origin.x = x;
        
        [UIView animateWithDuration:.01 animations:^{
            photoItemView.frame = frame;
            
        }];
        
    }];
    
    
    if(!_isScrollToIndex){
        
        //显示第index张图
        CGFloat offsetX = w * _index;
        
        [self setContentOffset:CGPointMake(offsetX, 0) animated:NO];
        
        _isScrollToIndex = YES;
    }
    
}


@end
