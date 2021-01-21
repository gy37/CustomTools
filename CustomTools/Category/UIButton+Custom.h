//
//  UIButton+Custom.h
//  WMYLink
//
//  Created by yizhi on 2020/11/30.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (Custom)
- (void)setupButtonWithIconName:(NSString *)icon iconSize:(CGFloat)iconSize iconColor:(UIColor *)color;
- (void)setupButtonWithIconNames:(NSArray<NSString *> *)icons iconSize:(CGFloat)iconSize iconColor:(UIColor *)color;
- (void)setupButtonWithTitle:(NSString *)title titleSize:(CGFloat)titleSize titleColor:(UIColor *)color;
- (void)setupButtonWithTitle:(NSString *)title titleSize:(CGFloat)titleSize iconName:(NSString *)icon;
- (void)setupButtonWithTitle:(NSString *)title titleSize:(CGFloat)titleSize iconNames:(NSArray<NSString *> *)icons;
- (void)setupButtonWithTitle:(NSString *)title titleSize:(CGFloat)titleSize iconNames:(NSArray<NSString *> *)icons iconSize:(CGFloat)iconSize iconColor:(UIColor *)color;
- (void)setupButtonWithTopImageName:(NSString *)imageName bottomTitle:(NSString *)title;
- (void)setupButtonWithTopImage:(UIImage *)image bottomTitle:(NSString *)title;
- (void)setupButtonToTopBottomPosition;
@end

NS_ASSUME_NONNULL_END
