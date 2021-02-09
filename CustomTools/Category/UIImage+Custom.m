//
//  UIImage+Custom.m
//  WMYLink
//
//  Created by yuyuyu on 2020/12/1.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import "UIImage+Custom.h"

@implementation UIImage (Custom)

#pragma mark - iconfont

+ (UIImage *)iconWithFontSize:(CGFloat)size text:(NSString *)text {
    return [self iconWithFontName:@"iconfont" size:size text:text color:[UIColor colorWithWhite:1 alpha:1]];//默认图标白色
}

+ (UIImage *)iconWithFontSize:(CGFloat)size text:(NSString *)text color:(UIColor *)color {
    return [self iconWithFontName:@"iconfont" size:size text:text color:color];
}

+ (UIImage *)iconWithFontName:(NSString *)fontName size:(CGFloat)size text:(NSString *)text color:(UIColor *)color {
    CGFloat realSize = [UIFont getAdapterFontSize:size] * COMMON_SCREEN_SCALE;
    UIFont *font = [UIFont fontWithName:fontName size:realSize];
    UIGraphicsBeginImageContext(CGSizeMake(realSize, realSize));
 
    [text drawAtPoint:CGPointZero withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName: color}];
    
    UIImage *image = [UIImage imageWithCGImage:UIGraphicsGetImageFromCurrentImageContext().CGImage scale:COMMON_SCREEN_SCALE orientation:UIImageOrientationUp];
    UIGraphicsEndImageContext();
    
    return image;
}


#pragma mark - image color

+ (UIImage *)imageWithColor:(UIColor *)color {
//    CGRect rect = CGRectMake(0.0f, 0.0f, width, width);
//    UIGraphicsBeginImageContext(rect.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, [color CGColor]);
//    CGContextFillRect(context, rect);
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    UIImage *image = [self imageWithColor:color width:1];
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color width:(CGFloat)width {
    return [self imageWithColor:color width:width andBorderColor:color borderWidth:0];
}

+ (UIImage *)imageWithColor:(UIColor *)color width:(CGFloat)width andBorderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth {
    CGSize size = CGSizeMake(width + 2 * borderWidth, width + 2 * borderWidth);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    //底层border
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.width) cornerRadius:size.width / 2];
    // Set the color: Sets the fill and stroke colors in the current drawing context. Should be implemented by subclassers.
    [borderColor set];
    //填充path内部区域
    [borderPath fill];
    //简单的说，就是一个path调用addClip之后，它所在的context的可见区域就变成了它的“fill area”，接下来的绘制，如果在这个区域外都会被无视。
    [borderPath addClip];
    
    //上层内容
    UIBezierPath *contentPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(borderWidth, borderWidth, width, width) cornerRadius:width / 2];
    [color set];
    [contentPath fill];
    
    UIImage *clipImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return clipImage;
}

+ (UIImage *)gradientImageWithColors:(NSArray<UIColor *> *)colors size:(CGSize)size {
    if (CGSizeEqualToSize(size, CGSizeZero)) { size = CGSizeMake(1, 1); }
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);

    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = rect;
    gradientLayer.startPoint = CGPointMake(0, 0.5);
    gradientLayer.endPoint = CGPointMake(1, 0.5);
    NSMutableArray *cgColors = [NSMutableArray arrayWithCapacity:colors.count];
    for (UIColor *color in colors) {
        [cgColors addObject:(__bridge id)color.CGColor];
    }
    gradientLayer.colors = cgColors;

    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [gradientLayer renderInContext:context];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIColor *)gradientColorWithColors:(NSArray<UIColor *> *)colors {
    UIImage *image = [self gradientImageWithColors:colors size:CGSizeMake(1, 1)];
    return [UIColor colorWithPatternImage:image];
}

#pragma mark - stretch clip

+ (UIImage *)getStretchedImage:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    UIEdgeInsets insets = UIEdgeInsetsMake(image.size.height / 2, image.size.width / 2, image.size.width / 2, image.size.height / 2);//要缩放的区域
    UIImage *newImage = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    return newImage;
}

+ (UIImage *)clipImage:(UIImage *)image {
    CGFloat cropRatio = 3 / 5.0;
    CGSize size = image.size;
    CGFloat width, height;
    if (size.width > size.height) {
        height = size.height;
        width = height / cropRatio;
        if (width > size.width) {
            width = size.width;
            height = width * cropRatio;
        }
    } else {
        width = size.width;
        height = width * cropRatio;
        if (height > size.height) {
            height = size.height;
            width = height / cropRatio;
        }
    }
    CGRect rect = CGRectMake(0, (size.height - height) / 2, width, height);
    return [self clipImage:image toRect:rect];
}

+ (UIImage *)clipImage:(UIImage *)image toRect:(CGRect)rect {
    CGImageRef newImageRef = CGImageCreateWithImageInRect(image.CGImage, rect);//按照给定的矩形区域进行剪裁
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(newImageRef);
    return newImage;
}

+ (UIImage *)clipCameraPicture:(UIImage *)image toInsets:(UIEdgeInsets)insets {
    CGFloat scale = image.size.width / COMMON_SCREEN_WIDTH;
    CGFloat top = insets.top * scale;
    CGFloat left = insets.left * scale;
    CGFloat right = insets.right * scale;
    CGFloat bottom = insets.bottom * scale;
    //UIImageOrientationRight CGImage的宽高和UIImage的宽高相反
    CGRect cropRect = CGRectMake(top, left, image.size.height - top - bottom, image.size.width - left - right);
    CGImageRef newImageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect);//按照给定的矩形区域进行剪裁
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:image.scale orientation:image.imageOrientation];
    return newImage;
}

@end
