//
//  Values.h
//  WMYLink
//
//  Created by yuyuyu on 2020/11/30.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#ifndef Values_h
#define Values_h

#pragma mark - number
#define COMMON_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define COMMON_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define COMMON_SCREEN_SCALE [UIScreen mainScreen].scale
#define COMMON_STATUS_BAR_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height
#define COMMON_SAFE_AREA_BOTTOM_HEIGHT ({\
CGFloat height = 0;\
if (@available(iOS 11.0, *)) {\
    height = [UIApplication sharedApplication].windows.firstObject.safeAreaInsets.bottom;\
}\
height;\
})
#define IS_NOTCH_SCREEN COMMON_STATUS_BAR_HEIGHT >= 44.f
#define IS_BIG_SCREEN COMMON_SCREEN_HEIGHT >= 736.f
#define VIDEO_RECT_TOP 83.f
#define VIDEO_RECT_BOTTOM 77.f
#define NOTCH_SCREEN_VIDEO_RECT_TOP 121.f
#define NOTCH_SCREEN_VIDEO_RECT_BOTTOM 223.f

#define COMMON_INNER_SPACE 8
#define COMMON_BORDER_WIDTH 1
#define COMMON_TEXTFIELD_HEIGHT 30

#define COMMON_CELL_HEIGHT 44

#pragma mark - color
#define THEME_COLOR UIColorFromRGB(0x4285f4)
#define LIGHT_THEME_COLOR UIColorFromRGB(0x187aff)
#define BORDER_COLOR UIColorFromRGB(0xcecece)
#define POP_BACKGROUND_COLOR [[UIColor blackColor] colorWithAlphaComponent:0.65]
#define BACKGROUND_COLOR UIColorFromRGB(0xf5f5f5)
#define HALF_WHITE_COLOR [[UIColor whiteColor] colorWithAlphaComponent:0.5]


#pragma mark - object
#define KEY_WINDOW [UIApplication sharedApplication].windows.firstObject

#pragma mark - key
#define PUBLIC_KEY @""
#define DEFAULT_TOKEN @""

#pragma mark - notification
#define UNAUTHORIZED_NOTIFICATION @"RequestUnauthorizedNotifiction"

#pragma mark - app info
#define APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#pragma mark - app id
#define WECHAT_APPID @""
#define UNIVERSAL_LINK @""

#endif /* Values_h */
