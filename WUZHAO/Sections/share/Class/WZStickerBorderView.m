//
//  WZStickerBorderView.m
//  WUZHAO
//
//  Created by yiyi on 15/8/12.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "WZStickerBorderView.h"
#import "macro.h"

#define kUserResizableViewGlobalInset 5.0
#define kUserResizableViewDefaultMinWidth 10.0
#define kUserResizableViewDefaultMinHeight 10.0
#define kUserResizableViewInteractiveBorderSize 8.0

@implementation WZStickerBorderView
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Clear background to ensure the content view shows through.
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, THEME_COLOR_DARK.CGColor);
    CGContextAddRect(context, CGRectInset(self.bounds, kUserResizableViewInteractiveBorderSize/2, kUserResizableViewInteractiveBorderSize/2));
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
}
@end
