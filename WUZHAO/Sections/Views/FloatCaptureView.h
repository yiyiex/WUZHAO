//
//  FloatCaptureView.h
//  WUZHAO
//
//  Created by yiyi on 15/8/11.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>


extern NSString * const CaptureViewDidReceiveTouchEventNotification;
extern NSString * const CaptureViewDidTouchDownInsideNotification;

@interface FloatCaptureView : UIView

+(instancetype)sharedInstance;
+(void)show;
+(void)dismiss;
+(void)setHidden:(BOOL)hidden;

+ (void)setOffsetFromCenter:(UIOffset)offset;
+ (void)resetOffsetFromCenter;

@end
