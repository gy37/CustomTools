//
//  UIButton+Custom.m
//  WMYLink
//
//  Created by yizhi on 2020/11/30.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#import "UIButton+Custom.h"

@implementation UIButton (Custom)
const CGFloat buttonIconfontSize = 16;

#pragma mark - method swizzle

//不能写在UIView里面，会和UIDatePicker冲突，UIDatePicker也重写了setBackgroundColor方法？
+ (void)load {
    static dispatch_once_t buttonToken;
    dispatch_once(&buttonToken, ^{
        [self exchangeInstanceMethod:@selector(setBackgroundColor:) withMethod:@selector(setBackgroundColorWithGradientLayer:)];
        [self exchangeInstanceMethod:@selector(awakeFromNib) withMethod:@selector(awakeFromNibAndSetFont)];
    });
}

- (void)setBackgroundColorWithGradientLayer:(UIColor *)color {
    if (color) {
        //GradientLayer添加在当前view的sublayers的倒数第二个，层级高于view.layer
        //设置button的背景颜色时，设置的是button.layer的颜色，低于GradientLayer层级，所以背景颜色无法生效
        //使用method_exchangeImplementations，在load时替换button的setBackgroundColor方法为setBackgroundColorWithGradientLayer
        //设置背景颜色时，先移除GradientLayer，在调用setBackgroundColor方法
        [self removeGradientLayer];
        //注意：必须调用自己的方法名，此时setBackgroundColorWithGradientLayer已被替换为setBackgroundColor
        [self setBackgroundColorWithGradientLayer:color];
    }
}

- (void)awakeFromNibAndSetFont {
    CGFloat adapterSize = [UIFont getAdapterFontSize:self.titleLabel.font.pointSize];
    self.titleLabel.font = [UIFont fontWithDescriptor:self.titleLabel.font.fontDescriptor size:adapterSize];
    [self awakeFromNibAndSetFont];
}

#pragma mark - common

- (void)setupButtonWithIconName:(NSString *)icon iconSize:(CGFloat)iconSize iconColor:(UIColor *)color {
    [self setupButtonWithTitle:@"" titleSize:0 iconNames:@[icon] iconSize:iconSize iconColor:color];
}

- (void)setupButtonWithIconNames:(NSArray<NSString *> *)icons iconSize:(CGFloat)iconSize iconColor:(UIColor *)color {
    [self setupButtonWithTitle:@"" titleSize:0 iconNames:icons iconSize:iconSize iconColor:color];
}

- (void)setupButtonWithTitle:(NSString *)title titleSize:(CGFloat)titleSize titleColor:(UIColor *)color {
    [self setupButtonWithTitle:title titleSize:titleSize iconNames:@[] iconSize:0 iconColor:color];
}

- (void)setupButtonWithTitle:(NSString *)title titleSize:(CGFloat)titleSize iconName:(NSString *)icon {
    [self setupButtonWithTitle:title titleSize:titleSize iconNames:@[icon] iconSize:buttonIconfontSize iconColor:[UIColor whiteColor]];
}

- (void)setupButtonWithTitle:(NSString *)title titleSize:(CGFloat)titleSize iconNames:(NSArray<NSString *> *)icons {
    [self setupButtonWithTitle:title titleSize:titleSize iconNames:icons iconSize:buttonIconfontSize iconColor:[UIColor whiteColor]];
}

- (void)setupButtonWithTitle:(NSString *)title titleSize:(CGFloat)titleSize iconNames:(NSArray<NSString *> *)icons iconSize:(CGFloat)iconSize iconColor:(UIColor *)color {
    if (titleSize != 0) self.titleLabel.font = [UIFont systemFontOfSize:titleSize];
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitleColor:color forState:UIControlStateNormal];
    self.backgroundColor = [UIColor clearColor];
    if (icons.count >= 1 && icons[0] && icons[0].length > 0) {
        [self setImage:[UIImage iconWithFontSize:iconSize text:icons[0] color:color] forState:UIControlStateNormal];
        [self setImage:[UIImage iconWithFontSize:iconSize text:icons[0] color:color] forState:UIControlStateNormal | UIControlStateHighlighted];
    }
    if (icons.count >= 2 && icons[1] && icons[1].length > 0) {
        [self setImage:[UIImage iconWithFontSize:iconSize text:icons[1] color:color] forState:UIControlStateSelected];
        [self setImage:[UIImage iconWithFontSize:iconSize text:icons[1] color:color] forState:UIControlStateSelected | UIControlStateHighlighted];
    }
    if (titleSize > 0 && iconSize > 0) {
        self.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2);
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, -2);
    }
}

#pragma mark - position
- (void)setupButtonWithTopImageName:(NSString *)imageName bottomTitle:(NSString *)title {
    [self setupButtonWithTopImage:[UIImage imageNamed:imageName] bottomTitle:title];
}
    
- (void)setupButtonWithTopImage:(UIImage *)image bottomTitle:(NSString *)title {
    [self setImage:image forState:UIControlStateNormal];
    [self setImage:image forState:UIControlStateHighlighted];
    [self setTitle:title forState:UIControlStateNormal];
    [self setupButtonToTopBottomPosition];
}

- (void)setupButtonToTopBottomPosition {
    CGSize labelSize = self.titleLabel.intrinsicContentSize;
    CGSize imageSize = self.imageView.size;
    //A positive value shrinks, or insets, that edge—moving it closer to the center of the button.正值会向button中心压缩
    //A negative value expands, or outsets, that edge.负值会向button边缘扩大
    //向上向右扩展image
    self.imageEdgeInsets = UIEdgeInsetsMake(-labelSize.height - COMMON_INNER_SPACE / 2, 0, 0, -labelSize.width);
    //向左向下扩展title
    self.titleEdgeInsets = UIEdgeInsetsMake(0, -imageSize.width, -imageSize.height - COMMON_INNER_SPACE / 2, 0);
}

@end
