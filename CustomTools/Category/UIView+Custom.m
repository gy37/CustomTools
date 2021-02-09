//
//  UIView+Custom.m
//  WMYLink
//
//  Created by yuyuyu on 2020/12/1.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import "UIView+Custom.h"
#import <objc/runtime.h>

@interface UIView (Custom)<CAAnimationDelegate>
@property (strong, nonatomic) CALayer *gradientLayer;
@property (strong, nonatomic) NSMutableArray *addedLayers;
@property (copy, nonatomic) NSString *animationKey;
@property (copy, nonatomic) SimpleBlock animationCompletionBlock;
@end

@implementation UIView (Custom)
const CGFloat viewDashBorderPaintWidth = 4;
const CGFloat viewDashBorderUnpaintWidth = 4;
const CGFloat viewAnimationDuration = 0.4;
const NSString *addedLayerKey = @"addedLayerKey";
const NSString *animationCompletionBlockKey = @"animationCompletionBlock";
const NSString *animationKeyKey = @"animationKey";
const NSString *gradientLayerKey = @"gradientLayer";

#pragma mark - NSLayoutConstraint

- (void)updateNSLayoutConstraint:(NSLayoutAttribute)attribute constant:(CGFloat)constant {
    for (NSLayoutConstraint *constraint in self.constraints) {
        if ([constraint isMemberOfClass:[NSLayoutConstraint class]] && constraint.firstAttribute == attribute) {
            constraint.constant = constant;
            break;
        }
    }
}

- (void)updateOtherViewRealtedNSLayoutConstraint:(NSLayoutAttribute)attribute constant:(CGFloat)constant {
    for (NSLayoutConstraint *constraint in self.superview.constraints) {
        if (constraint.firstAttribute == attribute && (constraint.firstItem == self || constraint.secondItem == self)) {
            constraint.constant = constant;
            break;
        }
    }
}


#pragma mark - gradient

- (void)addGradientLayerColors:(NSArray<UIColor *> *)colors {
    if (self.gradientLayer) [self.gradientLayer removeFromSuperlayer];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    gradientLayer.startPoint = CGPointMake(0, 0.5);
    gradientLayer.endPoint = CGPointMake(1, 0.5);
    NSMutableArray *cgColors = [NSMutableArray arrayWithCapacity:colors.count];
    for (UIColor *color in colors) {
        [cgColors addObject:(__bridge id)color.CGColor];
    }
    gradientLayer.colors = cgColors;
    self.gradientLayer = gradientLayer;
    [self.layer insertSublayer:gradientLayer below:self.layer.sublayers.lastObject];
}

- (void)removeGradientLayer {
    if (self.gradientLayer) {
        [self.gradientLayer removeFromSuperlayer];
    }
}

#pragma mark - corner

- (void)setCornerRadiusHalfHeight {
    [self setCornerRadius:self.height / 2];
}

- (void)setCornerRadius:(CGFloat)radius {
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}

- (void)setCornerRadius:(CGFloat)radius corners:(UIRectCorner)corners {
// 使用cashapelayer通过mask设置圆角时，在xib中创建的view会有适配问题，需要确定view的frame才能准确地切圆角
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)setBorderColor:(UIColor *)color borderWidth:(CGFloat)width {
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
}

- (void)setCornerRadius:(CGFloat)radius borderColor:(UIColor *)color borderWidth:(CGFloat)width {
    [self setCornerRadius:radius];
    [self setBorderColor:color borderWidth:width];
}

- (void)setCornerRadius:(CGFloat)radius corners:(UIRectCorner)corners borderColor:(UIColor *)color borderWidth:(CGFloat)width {
    [self layoutIfNeeded];
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;

// 使用cashapelayer通过mask设置圆角时，在xib中创建的view会有适配问题，需要确定view的frame才能准确地切圆角
// 还是用cornerRadius来设置
//    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
//    CAShapeLayer * mask  = [[CAShapeLayer alloc] init];
//    mask.lineWidth = width;
//    mask.lineCap = kCALineCapRound;
//    mask.strokeColor = color.CGColor;
//    mask.fillColor = [UIColor redColor].CGColor;
//    mask.path = path.CGPath;
//    [self.layer addSublayer:mask];
}

#pragma mark - shadow

- (void)addShadowColor:(UIColor *)color {
    [self addShadowColor:color cornerRadius:0];
}

- (void)addShadowColor:(UIColor *)color cornerRadius:(CGFloat)radius {
    [self layoutIfNeeded];//获取布局之后view的frame
    [self setCornerRadius:radius];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{//设置shadow会有偏移，延时之后在执行
        CALayer *subLayer = [CALayer layer];
        subLayer.frame = self.frame;
        subLayer.backgroundColor = [UIColor whiteColor].CGColor;//要设置颜色
        subLayer.cornerRadius = radius;
        subLayer.masksToBounds = NO;
        subLayer.shadowColor = color.CGColor;
        subLayer.shadowOffset = CGSizeMake(0, 3);//阴影偏移（x向右，y向下）
        subLayer.shadowOpacity = 1;//阴影透明度
        subLayer.shadowRadius = 7;//阴影半径
        [self.superview.layer insertSublayer:subLayer below:self.layer];
    });
}

#pragma mark - border

CustomViewBorderOffsets CustomViewBorderOffsetsMake(CGFloat top, CGFloat left)
{
    CustomViewBorderOffsets rect;
    rect.top = top;
    rect.left = left;
    return rect;
}

- (void)addBorder:(UIColor *)color isDashed:(BOOL)isDashed {
    [self addBorder:color width:COMMON_BORDER_WIDTH isDashed:isDashed];
}

- (void)addBorder:(UIColor *)color width:(CGFloat)width isDashed:(BOOL)isDashed {
    [self layoutIfNeeded];
    CAShapeLayer *border = [CAShapeLayer layer];
    border.fillColor = [UIColor clearColor].CGColor;
    border.strokeColor = color.CGColor;
    border.frame = self.bounds;
    border.lineWidth = width;
    border.lineCap = kCALineCapRound;
    isDashed ? border.lineDashPattern = @[@(viewDashBorderPaintWidth), @(viewDashBorderUnpaintWidth)] : @"";

    //设置path //使用CGMutablePathRef画四条线不平行？？？改用UIBezierPath
    border.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    
    if (!self.addedLayers) { self.addedLayers = [NSMutableArray array]; }
    [self.addedLayers addObject:border];
    [self.layer addSublayer:border];
}

- (void)addBorder:(UIColor *)color position:(CustomViewBorderPosition)position isDashed:(BOOL)isDashed {
    CustomViewBorderOffsets CustomViewBorderOffsetsZero = CustomViewBorderOffsetsMake(0, 0);
    [self addBorder:color position:position offsets:CustomViewBorderOffsetsZero isDashed:isDashed];
}

- (void)addBorder:(UIColor *)color position:(CustomViewBorderPosition)position offsets:(CustomViewBorderOffsets)offsets isDashed:(BOOL)isDashed {
    [self layoutIfNeeded];//获取布局之后view的frame
    NSArray *dashPattern = isDashed ? @[@(viewDashBorderPaintWidth), @(viewDashBorderUnpaintWidth)] : nil;
    if (position & CustomViewBorderPositionTop) {//top
        CGFloat left = offsets.left;
        CGFloat top = offsets.top;
        CGFloat width = self.width - offsets.left;
        CGFloat height = COMMON_BORDER_WIDTH;
        [self addSingleBorder:color frame:CGRectMake(left, top, width, height) dashPattern:dashPattern];
    }
    if (position & CustomViewBorderPositionLeft) {//left
        CGFloat left = offsets.left;
        CGFloat top = offsets.top;
        CGFloat width = COMMON_BORDER_WIDTH;
        CGFloat height = self.height - offsets.top;
        [self addSingleBorder:color frame:CGRectMake(left, top, width, height) dashPattern:dashPattern];
    }
    if (position & CustomViewBorderPositionBottom) {//bottom
        CGFloat top = self.height + offsets.top;
        CGFloat left = offsets.left;
        CGFloat width = self.width - offsets.left;
        CGFloat height = COMMON_BORDER_WIDTH;
        [self addSingleBorder:color frame:CGRectMake(left, top, width, height) dashPattern:dashPattern];
    }
    if (position & CustomViewBorderPositionRight) {//right
        CGFloat top = offsets.top;
        CGFloat left = self.width + offsets.left;
        CGFloat width = COMMON_BORDER_WIDTH;
        CGFloat height = self.height - offsets.top;
        [self addSingleBorder:color frame:CGRectMake(left, top, width, height) dashPattern:dashPattern];
    }
}

- (void)addSingleBorder:(UIColor *)color frame:(CGRect)frame dashPattern:(NSArray *)dashPattern {
    color = color ? color : BORDER_COLOR;
    CAShapeLayer *border = [CAShapeLayer layer];
    border.fillColor = [UIColor clearColor].CGColor;
    border.strokeColor = color.CGColor;
    border.frame = frame;
    border.lineWidth = COMMON_BORDER_WIDTH;
    border.lineCap = kCALineCapRound;
    border.lineDashPattern = dashPattern;

    //设置path
//    border.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, frame.size.width, frame.size.height)].CGPath;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, frame.size.width, frame.size.height);
    [border setPath:path];
    CGPathRelease(path);
    
    if (!self.addedLayers) { self.addedLayers = [NSMutableArray array]; }
    [self.addedLayers addObject:border];
    [self.layer addSublayer:border];
}

- (void)removeBorder {
    //直接循环删除，会报错reason: '*** Collection <CALayerArray: 0x6000024b6b20> was mutated while being enumerated.'
    for (CALayer *layer in self.addedLayers) {
        [layer removeFromSuperlayer];
    }
}

#pragma mark - animation

- (void)addPopAnimation {
    @weakify(self);
    [self addAnimation:@"transform" values:@[
        [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1.1)],
        [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.01, 1.01, 1.01)],
        [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]
    ] duration:0 animationKey:@"PopAnimation" completion:^{
        @strongify(self);
        [self.layer removeAnimationForKey:@"PopAnimation"];
    }];
}

- (void)addFadeAnimation {
    @weakify(self);
    [self addAnimation:@"opacity" values:@[@1, @0] duration:0 animationKey:@"FadeAnimation" completion:^{
        @strongify(self);
        [self removeFromSuperview];
        [self.layer removeAnimationForKey:@"FadeAnimation"];
    }];
}

- (void)addPresentAnimation {
    //使用bounds.origin.y动画有点奇怪。。
    @weakify(self);
    [self addAnimation:@"position.y" values:@[@(COMMON_SCREEN_HEIGHT + self.height / 2), @(COMMON_SCREEN_HEIGHT - self.height / 2)] duration:0 animationKey:@"PresentAnimation" completion:^{
        @strongify(self);
        [self.layer removeAnimationForKey:@"PresentAnimation"];
    }];
}

- (void)addDismissAnimation {
    UIView *subView;
    if (self.height == COMMON_SCREEN_HEIGHT && self.subviews.firstObject) {
        subView = self.subviews.firstObject;
        @weakify(subView);
        [subView addAnimation:@"position.y" values:@[@(COMMON_SCREEN_HEIGHT - subView.height / 2), @(COMMON_SCREEN_HEIGHT + subView.height / 2)] duration:0 animationKey:@"DismissAnimationFirstStep" completion:^{
            @strongify(subView);
            [subView.layer removeAnimationForKey:@"DismissAnimationFirstStep"];
        }];
    }
    @weakify(self);
    [self addAnimation:@"opacity" values:@[@1, @0] duration:viewAnimationDuration animationKey:@"DismissAnimationSecondStep" completion:^{
        @strongify(self);
        [self.layer removeAnimationForKey:@"DismissAnimationSecondStep"];
        [self removeFromSuperview];
    }];
}

- (void)addBlurEffectTransitionAnimationWithSubtype:(CATransitionSubtype)subtype {
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithFrame:self.bounds];
    blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    [self addSubview:blurView];
    @weakify(self);
    [self addAnimation:@"transition" values:@[subtype] duration:viewAnimationDuration animationKey:@"BlurEffectAnimation" completion:^{
        @strongify(self);
        [self.layer removeAnimationForKey:@"BlurEffectAnimation"];
        [blurView removeFromSuperview];
    }];
}

//TODO:此方法有局限性，每个view只能添加一个动画，多个动画会混乱，之后再解决
- (void)addAnimation:(NSString *)keyPath values:(NSArray *)values duration:(CGFloat)duration animationKey:(NSString *)key completion:(SimpleBlock)block {
    if (key && key.length > 0) self.animationKey = key;
    if (block) self.animationCompletionBlock = block;
    if (values.count < 2) {
        if ([keyPath isEqualToString:@"transition"]) {//转场动画
            CATransition *transition = [CATransition animation];
            transition.duration = duration > 0 ? duration : viewAnimationDuration;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = @"oglFlip";//kCATransitionReveal;
            transition.subtype = values.firstObject;
            transition.fillMode = kCAFillModeForwards;
            transition.removedOnCompletion = NO;
            
            transition.delegate = self;
            [self.layer addAnimation:transition forKey:key];
            self.animationKey = @"transition";//CATransition动画的key为transition，不能修改
        } else {
            NSLog(@"values.count should have at least two items");
        }
    } else if (values.count == 2) {
        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:keyPath];
        basicAnimation.fromValue = values.firstObject;
        basicAnimation.toValue = values.lastObject;
        basicAnimation.duration = duration > 0 ? duration : viewAnimationDuration;
        basicAnimation.removedOnCompletion = NO;//动画结束之后是否移除layer，默认yes；如果要监听animationDidStop事件，需要把该属性只为NO，否则无效
        basicAnimation.fillMode = kCAFillModeForwards;//动画结束之后是否保持最后的状态，默认移除
        basicAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        basicAnimation.delegate = self;
        [self.layer addAnimation:basicAnimation forKey:key];
    } else {
        CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
        keyframeAnimation.values = values;
        keyframeAnimation.duration = duration > 0 ? duration : viewAnimationDuration;
        keyframeAnimation.removedOnCompletion = NO;//动画结束之后是否移除layer，默认yes；如果要监听animationDidStop事件，需要把该属性只为NO，否则无效
        keyframeAnimation.fillMode = kCAFillModeForwards;//动画结束之后是否保持最后的状态，默认移除
        keyframeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        keyframeAnimation.delegate = self;
        [self.layer addAnimation:keyframeAnimation forKey:key];
    }
}

#pragma mark animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([[self.layer animationForKey:self.animationKey] isEqual:anim]) {
        if (self.animationCompletionBlock) {
            self.animationCompletionBlock();
        }
    }
}

#pragma mark - set get

- (void)setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}
- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}
- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}
- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}
- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size.width = size.width;
    frame.size.height = size.height;
    self.frame = frame;
}
- (CGSize)size {
    return self.frame.size;
}


- (void)setGradientLayer:(CALayer *)gradientLayer {
    objc_setAssociatedObject(self, &gradientLayerKey, gradientLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CALayer *)gradientLayer {
    return objc_getAssociatedObject(self, &gradientLayerKey);
}

- (void)setAddedLayers:(NSMutableArray *)addedLayers {
    objc_setAssociatedObject(self, &addedLayerKey, addedLayers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)addedLayers {
    return objc_getAssociatedObject(self, &addedLayerKey);
}

- (void)setAnimationKey:(NSString *)animationKey {
    objc_setAssociatedObject(self, &animationKeyKey, animationKey, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)animationKey {
    return objc_getAssociatedObject(self, &animationKeyKey);
}

- (void)setAnimationCompletionBlock:(SimpleBlock)animationCompletionBlock {
    objc_setAssociatedObject(self, &animationCompletionBlockKey, animationCompletionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (SimpleBlock)animationCompletionBlock {
    return objc_getAssociatedObject(self, &animationCompletionBlockKey);
}

@end
