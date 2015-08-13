//
//  PhotoText.h
//  WUZHAO
//
//  Created by yiyi on 15/8/12.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, TEXTCOLOR)
{
    TEXTCOLOR_WHITE,
    TEXTCOLOR_BLACK
};

typedef NS_ENUM(NSInteger, TEXTDIRECTION)
{
    TEXTDIRECTION_LANDSCAPE,
    TEXTDIRECTION_PORTRAIT
};


@interface PhotoText : NSObject
@property (nonatomic, strong) NSString *textString;
@property (nonatomic) NSInteger textSize;
@property (nonatomic) TEXTCOLOR textColor;
@property (nonatomic) CGFloat textAngle;
@property (nonatomic) TEXTDIRECTION textDirection;
@property (nonatomic,strong) NSString *textFont;
@property (nonatomic) CGPoint textPoint;

+(NSArray *)textTempletes;
@end



