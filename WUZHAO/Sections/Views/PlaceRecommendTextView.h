//
//  PlaceRecommendTextView.h
//  WUZHAO
//
//  Created by yiyi on 15/8/5.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "LinkTextView.h"
#import "POI.h"

@protocol  PlaceRecommendTextViewDelegate;

@interface PlaceRecommendTextView : LinkTextView
@property (nonatomic, weak) id<PlaceRecommendTextViewDelegate> placeRecommendTextViewDelegate;
-(void) linkPOINameWithPOI:(POI *)poi;

@end

@protocol PlaceRecommendTextViewDelegate <NSObject>

-(void) PlaceRecommendTextView:(PlaceRecommendTextView *)placeRecommendTextView didClickPOI:(POI *)poi;

@optional
-(void) didClickUnlinedTextOnplaceRecommendTextView:(PlaceRecommendTextView *)placeRecommendTextView;

@end