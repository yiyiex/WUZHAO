//
//  captureMacro.h
//  WUZHAO
//
//  Created by yiyi on 15/6/1.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#ifndef WUZHAO_captureMacro_h
#define WUZHAO_captureMacro_h

//height

#if __isIPHONE_4s
#define CAMERA_TOPVIEW_HEIGHT   0
#else
#define CAMERA_TOPVIEW_HEIGHT   50
#endif


#define CAMERA_MENU_VIEW_HEIGH  50  //menu
#define CAMERA_BUTTON_WIDTH  70 //cameraButton
#define CAMERA_PHOTO_CHOOSE_BUTTON_WIDTH 50//photoChoose Button

//color
#define BOTTOM_CONTAINER_COLOR rgba_WZ(23,24,26,1.0)
#define MENU_CONTAINER_COLOR rgba_WZ(23,24,26,0.9)

#define DARK_BACKGROUND_COLOR rgba_WZ(23,24,26,1.0)
#define DARK_PARENT_BACKGROUND_COLOR rgba_WZ(23,24,26,0.9)



//对焦
#define ADJUSTINT_FOCUS @"adjustingFocus"
#define LOW_ALPHA   0.7f
#define HIGH_ALPHA  1.0f

#endif
