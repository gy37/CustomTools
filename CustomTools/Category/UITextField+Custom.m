//
//  UITextField+Custom.m
//  WMYLink
//
//  Created by yuyuyu on 2020/11/30.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import "UITextField+Custom.h"

@implementation UITextField (Custom)

const int loginTextFieldRightImageViewTag = 1000;
const NSInteger loginTextFieldRightButtonTag = 1010;
BOOL isShow = NO;
NSArray *rightIcons;
const CGFloat loginTextFieldIconWidth = 24;
const CGFloat innerSpace = 24;

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

- (void)setupRightView:(NSArray<NSString *> *)icons {
    
}

- (void)setupTextFieldWithIcon:(NSString *)iconName placeholder:(NSString *)placeholder rightIcons:(nullable NSArray<NSString *> *)rightIcons isPassword:(BOOL)isPassword {
    self.text = @"";
    if (isPassword) self.secureTextEntry = YES;
    
    //左侧图标
    UIImageView *leftImageView = [[UIImageView alloc] initWithImage:[iconName containsString:@"U0000"]?[UIImage iconWithFontSize:loginTextFieldIconWidth text:iconName color:HALF_WHITE_COLOR]:[UIImage imageNamed:iconName]];
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
        
    if (rightIcons && rightIcons.count > 0) {
        [self setupRightView:rightIcons isPassword:isPassword];
    }
}

- (void)setupRightView:(NSArray<NSString *> *)icons isPassword:(BOOL)isPassword {
    rightIcons = icons;
    //右侧图标
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, loginTextFieldIconWidth + innerSpace, loginTextFieldIconWidth)];
    UIImageView *rightImageView = [[UIImageView alloc] initWithImage:[rightIcons[0] containsString:@"U0000"]?[UIImage iconWithFontSize:loginTextFieldIconWidth text:rightIcons[0] color:HALF_WHITE_COLOR]:[UIImage imageNamed:rightIcons[0]]];
    rightImageView.tag = loginTextFieldRightImageViewTag;
    rightImageView.center = rightView.center;
    [rightView addSubview:rightImageView];
    self.rightView = rightView;
    self.rightViewMode = UITextFieldViewModeAlways;
    
    if (isPassword) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPassword:)];
        [self.rightView addGestureRecognizer:tap];
    } else {
        self.rightView.userInteractionEnabled = NO;
    }
}

- (void)showPassword:(UITapGestureRecognizer *)tap {
    isShow = !isShow;
    UIImageView *rightImageView = [self.rightView viewWithTag:loginTextFieldRightImageViewTag];
    rightImageView.image = [UIImage iconWithFontSize:loginTextFieldIconWidth text:rightIcons[isShow] color:HALF_WHITE_COLOR];
    self.secureTextEntry = !isShow;
}

- (void)setupTextFieldWithLeftString:(NSString *)leftString placeholder:(NSString *)placeholder rightString:(NSString *)rightString {
    self.text = @"";
    self.secureTextEntry = NO;

    //左侧空白
    CGRect leftFrame = CGRectMake(0, 0, loginTextFieldIconWidth, loginTextFieldIconWidth);
    UIView *leftView = [[UIView alloc] initWithFrame:leftFrame];
    self.leftView = leftView;
    self.leftViewMode = UITextFieldViewModeAlways;
    if (leftString.length) {
        leftFrame.size.width = leftFrame.size.width + innerSpace + 30;
        leftView.frame = leftFrame;
        //左侧按钮
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftButton setBackgroundColor:self.backgroundColor];
        [leftButton setTitleColor:UIColorFromRGB(0x4285f4) forState:UIControlStateNormal];
        [leftButton setTitle:leftString forState:UIControlStateNormal];
        leftButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [leftView addSubview:leftButton];
        leftButton.size = CGSizeMake(30, 20);
        leftButton.center = leftView.center;
    }

    //placeholder
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:placeholder attributes:@{ NSForegroundColorAttributeName:UIColorFromRGB(0xc5c5c5) }];
    self.attributedPlaceholder = attrString;
    
    //右侧空白
    CGRect rightFrame = CGRectMake(0, 0, loginTextFieldIconWidth, loginTextFieldIconWidth);
    UIView *rightView = [[UIView alloc] initWithFrame:rightFrame];
    self.rightView = rightView;
    self.rightViewMode = UITextFieldViewModeAlways;
    if (rightString.length) {
        rightFrame.size.width = rightFrame.size.width + 8 + 120;
        rightView.frame = rightFrame;
        //右侧按钮
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightButton setBackgroundColor:self.backgroundColor];
        [rightButton setTitleColor:UIColorFromRGB(0x4285f4) forState:UIControlStateNormal];
        [rightButton setTitle:rightString forState:UIControlStateNormal];
        rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
        rightButton.tag = loginTextFieldRightButtonTag;
        [rightView addSubview:rightButton];
        rightButton.size = CGSizeMake(120, 20);
        rightButton.center = rightView.center;
    }
}
@end
