//
//  appScreen.h
//  WUZHAO
//
//  Created by yiyi on 14-12-19.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#ifndef WUZHAO_MACRO_h
#define WUZHAO_MACRO_h

//Debug logging
#if 1
#define WZLog(x, ...) NSLog(x, ##__VA_ARGS__);
#else
#define WZLog(x, ...) 
#endif

#define WUZHAO_APP_SIZE [[UIScreen mainScreen] applicationFrame].size
#define WUZHAO_APP_FRAME [UIScreen mainScreen] applicationFrame]

//notification
#define kCapturedPhotoSuccessfully              @"caputuredPhotoSuccessfully"
#define kNotificationOrientationChange          @"kNotificationOrientationChange"
#define kNotificationTakePicture  @"kNotificationTakePicture"

#define kImage                                  @"image"
#define kFilterImage                            @"image"
#define kAudioAmrName                           @"amrName"
#define kAudioDuration                          @"audioDuration"

//weakself
#define WEAKSELF_WZ __weak __typeof(&*self)weakSelf_WZ = self;


//color
#define rgba_WZ(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

//字体颜色
//#define THEME_COLOR rgba_WZ(120, 194, 196, 1.0)
//#define THEME_COLOR rgba_WZ(153,224,253,1.0)
//#define THEME_COLOR_DARK rgba_WZ(49,175,223,1.0)
#define THEME_COLOR rgba_WZ(90,187,149,1.0)
#define THEME_COLOR_DARK rgba_WZ(88,152,125,1.0)

#define THEME_COLOR_PARENT rgba_WZ(90,187,149, 0.5)
#define THEME_COLOR_DARK_PARENT rgba_WZ(88,152,125,0.5)

#define THEME_COLOR_DARKER rgba_WZ(49,120,175, 1)
#define THEME_COLOR_DARKER_PARENT rgba_WZ(49,120,175,0.5)


#define THEME_COLOR_WHITE rgba_WZ(255,255,255,1.0)

#define THEME_COLOR_LIGHT_GREY rgba_WZ(160,160,160,1.0)
#define THEME_COLOR_LIGHT_GREY_PARENT rgba_WZ(200,200,200,0.5)
#define THEME_COLOR_LIGHT_GREY_MORE_PARENT rgba_WZ(200,200,200,0.3)

#define THEME_COLOR_DARK_GREY rgba_WZ(40,45,50,1.0)
#define THEME_COLOR_DARK_GREY_BIT_PARENT rgba_WZ(40,45,50,0.9)
#define THEME_COLOR_DARK_GREY_PARENT rgba_WZ(40,45,50,0.5)

#define THEME_COLOR_DARKER_GREY rgba_WZ(20,20,25,1.0)
#define THEME_COLOR_DARKER_GREY_PARENT rgba_WZ(20,20,25,0.5)
#define THEME_COLOR_BLACK rgba_WZ(0,0,0,1.0)
#define THEME_COLOR_BLACK_PARENT rgba_WZ(0,0,0,0.8)


//控件相关颜色
#define VIEW_COLOR_BLACK rgba_WZ(21,22,26,1.0)
#define VIEW_COLOR_DRAKGREY rgba_WZ(45,45,45,1.0)
#define VIEW_COLOR_WHITEGREY rgba_WZ(250,250,252,1.0)
#define VIEW_COLOR_LIGHTGREY rgba_WZ(221,221,221,1.0)

//frame and size
#define WZ_DEVICE_BOUNDS    [[UIScreen mainScreen] bounds]
#define WZ_DEVICE_SIZE      [[UIScreen mainScreen] bounds].size

#define WZ_APP_FRAME        [[UIScreen mainScreen] applicationFrame]
#define WZ_APP_SIZE         [[UIScreen mainScreen] applicationFrame].size

#define SELF_CON_FRAME      self.view.frame
#define SELF_CON_SIZE       self.view.frame.size
#define SELF_VIEW_FRAME     self.frame
#define SELF_VIEW_SIZE      self.frame.size



// 是否iPad
#define isIPHONE_6 (WZ_DEVICE_SIZE.width == 375)
#define isIPHONE_6P (WZ_DEVICE_SIZE.width == 414)
#define isIPHONE_5 (WZ_DEVICE_SIZE.width == 320)
#define isIPHONE_4s (WZ_DEVICE_SIZE.height == 480)

#define isPad_SC (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)//设备类型改为Universal才能生效
#define isPad_AllTargetMode_WZ ([[UIDevice currentDevice].model rangeOfString:@"iPad"].location != NSNotFound)//设备类型为任何类型都能生效

//系统版本
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue] 
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

//iPhone5及以上设备，按钮的位置放在下面。iPhone5以下的按钮放上面。
#define isHigherThaniPhone4_WZ ((isPad_AllTargetMode_WZ && [[UIScreen mainScreen] applicationFrame].size.height <= 960 ? NO : ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? ([[UIScreen mainScreen] currentMode].size.height > 960 ? YES : NO) : NO)))




#if __IPHONE_6_0 // iOS6 and later

#   define kTextAlignmentCenter_SC    NSTextAlignmentCenter
#   define kTextAlignmentLeft_SC      NSTextAlignmentLeft
#   define kTextAlignmentRight_SC     NSTextAlignmentRight

#   define kTextLineBreakByWordWrapping_SC      NSLineBreakByWordWrapping
#   define kTextLineBreakByCharWrapping_SC      NSLineBreakByCharWrapping
#   define kTextLineBreakByClipping_SC          NSLineBreakByClipping
#   define kTextLineBreakByTruncatingHead_SC    NSLineBreakByTruncatingHead
#   define kTextLineBreakByTruncatingTail_SC    NSLineBreakByTruncatingTail
#   define kTextLineBreakByTruncatingMiddle_SC  NSLineBreakByTruncatingMiddle

#else // older versions

#   define kTextAlignmentCenter_SC    UITextAlignmentCenter
#   define kTextAlignmentLeft_SC      UITextAlignmentLeft
#   define kTextAlignmentRight_SC     UITextAlignmentRight

#   define kTextLineBreakByWordWrapping_SC       UILineBreakModeWordWrap
#   define kTextLineBreakByCharWrapping_SC       UILineBreakModeCharacterWrap
#   define kTextLineBreakByClipping_SC           UILineBreakModeClip
#   define kTextLineBreakByTruncatingHead_SC     UILineBreakModeHeadTruncation
#   define kTextLineBreakByTruncatingTail_SC     UILineBreakModeTailTruncation
#   define kTextLineBreakByTruncatingMiddle_SC   UILineBreakModeMiddleTruncation

#endif


#define WZ_FONT_NAME @"Helvetica"
#define WZ_FONT_NAME_BOLD @"Helvetica-Bold"



#define WZ_FONT_COMMON_SIZE [UIFont fontWithName:WZ_FONT_NAME size:14]
#define WZ_FONT_COMMON_BOLD_SIZE [UIFont fontWithName:WZ_FONT_NAME_BOLD size:14]


#define WZ_FONT_SMALLER_SIZE [UIFont fontWithName:WZ_FONT_NAME size:13]
#define WZ_FONT_SMALLER_BOLD_SIZE [UIFont fontWithName:WZ_FONT_NAME_BOLD size:13]

#define WZ_FONT_SMALL_SIZE [UIFont fontWithName:WZ_FONT_NAME size:12]
#define WZ_FONT_SMALL_BOLD_SIZE [UIFont fontWithName:WZ_FONT_NAME_BOLD size:12]

#define WZ_FONT_SMALLP_SIZE [UIFont fontWithName:WZ_FONT_NAME size:13]
#define WZ_FONT_SMALLP_BOLD_SIZE [UIFont fontWithName:WZ_FONT_NAME_BOLD size:13]

#define WZ_FONT_READONLY [UIFont fontWithName:WZ_FONT_NAME size:14]
#define WZ_FONT_READONLY_BOLD [UIFont fontWithName:WZ_FONT_NAME_BOLD size:14]

#define WZ_FONT_SMALL_READONLY [UIFont fontWithName:WZ_FONT_NAME size:12]
#define WZ_FONT_SMALL_READONLY_BOLD [UIFont fontWithName:WZ_FONT_NAME_BOLD size:12]

#define WZ_FONT_SMALLP_READONLY [UIFont fontWithName:WZ_FONT_NAME size:13]
#define WZ_FONT_SMALLP_READONLY_BOLD [UIFont fontWithName:WZ_FONT_NAME_BOLD size:13]

#define WZ_FONT_LARGE_READONLY [UIFont fontWithName:WZ_FONT_NAME size:16]
#define WZ_FONT_LARGE_READONLY_BOLD [UIFont fontWithName:WZ_FONT_NAME_BOLD size:16]

#define WZ_FONT_LARGE_SIZE [UIFont fontWithName:WZ_FONT_NAME size:15]
#define WZ_FONT_LARGE_BOLD_SIZE [UIFont fontWithName:WZ_FONT_NAME_BOLD size:15]

#define WZ_FONT_TITLE [UIFont fontWithName:WZ_FONT_NAME size:17]
#define WZ_FONT_TITLE_BOLD [UIFont fontWithName:WZ_FONT_NAME_BOLD size:17]


//userListTableViewStyle
#define UserListStyle1 @"UserListTableViewCellSimple"
#define UserListStyle2 @"UserListTableViewCellWithFollowButton"
#define UserListStyle3 @"UserListTableViewCellWithBigPhotoAndFollowButton"


//homeTableViewStyle
#define homeTableViewStyle1 @"myTimeLine"
#define homeTableViewStyle2 @"photoDetail"


#endif
