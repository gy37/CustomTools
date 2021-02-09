//
//  UITextField+Custom.h
//  WMYLink
//
//  Created by yuyuyu on 2020/11/30.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (Custom)
- (void)setupTextFieldWithIcon:(NSString *)iconName placeholder:(NSString *)placeholder;
- (void)setupTextFieldWithIcon:(NSString *)iconName placeholder:(NSString *)placeholder rightIcons:(nullable NSArray<NSString *> *)icons;
@end

NS_ASSUME_NONNULL_END
