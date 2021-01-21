//
//  UIView+Custom.h
//  WMYLink
//
//  Created by yizhi on 2020/12/1.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CustomViewBorderPosition) {
    CustomViewBorderPositionTop = 0x01 << 0,
    CustomViewBorderPositionLeft = 0x01 << 1,
    CustomViewBorderPositionBottom = 0x01 << 2,
    CustomViewBorderPositionRight = 0x01 << 3,
    CustomViewBorderPositionAll = 0x0f
};

typedef struct {
    CGFloat top;
    CGFloat left;
} CustomViewBorderOffsets;

@interface UIView (Custom)
- (void)updateNSLayoutConstraint:(NSLayoutAttribute)attribute constant:(CGFloat)constant;
- (void)updateOtherViewRealtedNSLayoutConstraint:(NSLayoutAttribute)attribute constant:(CGFloat)constant;

- (void)addGradientLayerColors:(NSArray<UIColor *> *)colors;
//设置背景颜色时，需要先调用移除GradientLayer，否则会重叠
//原来在UIView中用method swizzle重写了setBackgroundColor，后来发现会UIDatePicker显示异常，所以去掉了
- (void)removeGradientLayer;

- (void)setCornerRadiusHalfHeight;
- (void)setCornerRadius:(CGFloat)radius;
- (void)setCornerRadius:(CGFloat)radius corners:(UIRectCorner)corners;
- (void)setBorderColor:(UIColor *)color borderWidth:(CGFloat)width;
- (void)setCornerRadius:(CGFloat)radius borderColor:(UIColor *)color borderWidth:(CGFloat)width;
- (void)addShadowColor:(UIColor *)color;
- (void)addShadowColor:(UIColor *)color cornerRadius:(CGFloat)radius;

- (void)addBorder:(UIColor *)color isDashed:(BOOL)isDashed;
- (void)addBorder:(UIColor *)color width:(CGFloat)width isDashed:(BOOL)isDashed;
- (void)addBorder:(UIColor *)color position:(CustomViewBorderPosition)position isDashed:(BOOL)isDashed;
CustomViewBorderOffsets CustomViewBorderOffsetsMake(CGFloat top, CGFloat left);
- (void)addBorder:(UIColor *)color position:(CustomViewBorderPosition)position offsets:(CustomViewBorderOffsets)offsets isDashed:(BOOL)isDashed;
- (void)removeBorder;

- (void)addPopAnimation;
- (void)addFadeAnimation;
- (void)addPresentAnimation;
- (void)addDismissAnimation;
//completionBlock中需要调用[self.layer removeAnimationForKey:key];方法手动移除动画，否则会内存泄漏
- (void)addAnimation:(NSString *)keyPath values:(NSArray *)values duration:(CGFloat)duration animationKey:(NSString *)key completion:(nullable SimpleBlock)block;
- (void)addBlurEffectTransitionAnimationWithSubtype:(CATransitionSubtype)subtype;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;

@end

NS_ASSUME_NONNULL_END
