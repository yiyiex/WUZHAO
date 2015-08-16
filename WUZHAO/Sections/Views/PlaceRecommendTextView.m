//
//  PlaceRecommendTextView.m
//  WUZHAO
//
//  Created by yiyi on 15/8/5.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "PlaceRecommendTextView.h"
#import "macro.h"

@implementation PlaceRecommendTextView
{
    NSDictionary *defaultAttributes;
    NSDictionary *highlightedAttributes;
}

-(void)reset
{
    [super reset];
    self.placeRecommendTextViewDelegate = nil;
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)linkPOINameWithPOI:(POI *)poi
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineSpacing = 4;
    defaultAttributes = @{NSForegroundColorAttributeName:THEME_COLOR_DARK,NSFontAttributeName:WZ_FONT_COMMON_SIZE,NSParagraphStyleAttributeName:paragraphStyle};
    highlightedAttributes = @{NSForegroundColorAttributeName:THEME_COLOR_DARKER,NSFontAttributeName:WZ_FONT_COMMON_SIZE,NSParagraphStyleAttributeName:paragraphStyle};
    LinkedStringRangeTapHandler taphandler = ^(NSRange linkStringRange) {
        if ([self.placeRecommendTextViewDelegate respondsToSelector:@selector(PlaceRecommendTextView:didClickPOI:)])
        {
            [self.placeRecommendTextViewDelegate PlaceRecommendTextView:self didClickPOI:poi];
        }};
    [self linkTextWithString:poi.name defaultAttributes:defaultAttributes highlightAttributes:highlightedAttributes tabHandler:taphandler];
}

@end
