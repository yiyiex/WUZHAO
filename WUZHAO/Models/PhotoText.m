//
//  PhotoText.m
//  WUZHAO
//
//  Created by yiyi on 15/8/12.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "PhotoText.h"
#import "macro.h"

@implementation PhotoText

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        
        self.textString = @"双击修改文字";
        self.textPoint = CGPointMake(WZ_APP_SIZE.width/2, WZ_APP_SIZE.width/2);
        self.textAngle = 0;
        self.textColor = TEXTCOLOR_WHITE;
        self.textFont = WZ_FONT_NAME;
        self.textSize = 18;
        self.textDirection = TEXTDIRECTION_LANDSCAPE;
    }
    return self;
}

+(NSArray *)textTempletes
{
    //TO DO
    // generate the text template
    
    return @[];
}


@end
