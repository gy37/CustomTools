//
//  UITextField+Custom.m
//  WMYLink
//
//  Created by yizhi on 2020/11/30.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#import "UITextField+Custom.h"

@implementation UITextField (Custom)

const int loginTextFieldRightImageViewTag = 1000;
BOOL isShow = NO;
NSArray *rightIcons;
const CGFloat loginTextFieldIconWidth = 24;

#pragma mark - method swizzle

+ (void)load {
    static dispatch_once_t fontToken;
    dispatch_once(&fontToken, ^{
        [self exchangeInstanceMethod:@selector(awakeFromNib) withMethod:@selector(awakeFromNibAndSetFont)];
    });
}

- (void)awakeFromNibAndSetFont {
    CGFloat adapterSize = [UIFont getAdapterFontSize:self.font.pointSize];
    self.font = [UIFont fontWithDescriptor:self.font.fontDescriptor size:adapterSize];
    [self awakeFromNibAndSetFont];
}

#pragma mark - setup

- (void)setupTextFieldWithIcon:(NSString *)iconName placeholder:(NSString *)placeholder {
    [self setupTextFieldWithIcon:iconName placeholder:placeholder rightIcons:nil];
}

- (void)setupTextFieldWithIcon:(NSString *)iconName placeholder:(NSString *)placeholder rightIcons:(nullable NSArray<NSString *> *)rightIcons {
    //左侧图标
    UIImageView *leftImageView = [[UIImageView alloc] initWithImage:[UIImage iconWithFontSize:loginTextFieldIconWidth text:iconName color:HALF_WHITE_COLOR]];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, loginTextFieldIconWidth + COMMON_INNER_SPACE, loginTextFieldIconWidth)];
    [leftView addSubview:leftImageView];
    leftImageView.center = leftView.center;
    self.leftView = leftView;
    self.leftViewMode = UITextFieldViewModeAlways;

    //placeholder
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:placeholder attributes:@{ NSForegroundColorAttributeName:HALF_WHITE_COLOR }];
    self.attributedPlaceholder = attrString;
    
    //border
    CGFloat left = loginTextFieldIconWidth + COMMON_INNER_SPACE;
    [self layoutIfNeeded];//获取布局之后view的frame
    [self addBorder:HALF_WHITE_COLOR position:CustomViewBorderPositionBottom offsets:CustomViewBorderOffsetsMake(0, left) isDashed:NO];
    
    if (rightIcons) {
        [self setupRightView:rightIcons];
    }
}

- (void)setupRightView:(NSArray<NSString *> *)icons {
    rightIcons = icons;
    //右侧图标
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, loginTextFieldIconWidth + COMMON_INNER_SPACE, loginTextFieldIconWidth)];
    UIImageView *rightImageView = [[UIImageView alloc] initWithImage:[UIImage iconWithFontSize:loginTextFieldIconWidth text:rightIcons[0] color:HALF_WHITE_COLOR]];
    rightImageView.tag = loginTextFieldRightImageViewTag;
    rightImageView.center = rightView.center;
    [rightView addSubview:rightImageView];
    self.rightView = rightView;
    self.rightViewMode = UITextFieldViewModeAlways;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPassword:)];
    [self.rightView addGestureRecognizer:tap];
}

- (void)showPassword:(UITapGestureRecognizer *)tap {
    isShow = !isShow;
    UIImageView *rightImageView = [self.rightView viewWithTag:loginTextFieldRightImageViewTag];
    rightImageView.image = [UIImage iconWithFontSize:loginTextFieldIconWidth text:rightIcons[isShow] color:HALF_WHITE_COLOR];
    self.secureTextEntry = !isShow;
}

@end
