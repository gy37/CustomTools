//
//  UIImage+Custom.h
//  WMYLink
//
//  Created by yizhi on 2020/12/1.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Custom)

//iconfont
+ (UIImage *)iconWithFontSize:(CGFloat)size text:(NSString *)text;
+ (UIImage *)iconWithFontSize:(CGFloat)size text:(NSString *)text color:(UIColor *)color;
+ (UIImage *)iconWithFontName:(NSString *)fontName size:(CGFloat)size text:(NSString *)text color:(UIColor *)color;

//image color
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color width:(CGFloat)width;
+ (UIImage *)imageWithColor:(UIColor *)color width:(CGFloat)width andBorderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth;
+ (UIImage *)gradientImageWithColors:(NSArray<UIColor *> *)colors size:(CGSize)size;
+ (UIColor *)gradientColorWithColors:(NSArray<UIColor *> *)colors;

//stretch & clip
+ (UIImage *)getStretchedImage:(NSString *)imageName;
+ (UIImage *)clipImage:(UIImage *)image;
+ (UIImage *)clipImage:(UIImage *)image ofRect:(CGRect)rect;
@end

NS_ASSUME_NONNULL_END
