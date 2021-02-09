//
//  CustomResultContentView.m
//  WMYLink
//
//  Created by yuyuyu on 2020/12/3.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import "CustomResultContentView.h"
#import <Masonry.h>
#import "UIButton+Custom.h"

@interface CustomResultContentView()
@property (strong, nonatomic) UIImageView *contentImageView;
@property (strong, nonatomic) UIButton *closeButton;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *confirmButton;

@property (copy, nonatomic) SimpleBlock closeBlock;
@property (copy, nonatomic) SimpleBlock cancelBlock;
@property (copy, nonatomic) SimpleBlock confirmBlock;
@end
@implementation CustomResultContentView
CGFloat contentMargin = 92;//弹框边距

#pragma mark - public

- (void)setupErrorContent:(NSString *)title message:(NSString *)message cancel:(SimpleBlock)cancel confirm:(SimpleBlock)confirm {
    self.closeBlock = cancel;
    self.cancelBlock = cancel;
    self.confirmBlock = confirm;
    
    self.titleLabel.text = title;
    self.messageLabel.text = message;
    [self.confirmButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-36);
        make.width.mas_equalTo(COMMON_SCREEN_WIDTH - contentMargin * 2 - 36 * 2);
    }];
    [self.confirmButton layoutIfNeeded];
    [self.confirmButton addGradientLayerColors:@[LIGHT_THEME_COLOR, UIColorFromRGB(0x35b2ff)]];
    [self.cancelButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0);
        make.left.mas_equalTo(0);
    }];
}

- (void)setupErrorConfirmContent:(NSString *)title message:(NSString *)message cancel:(SimpleBlock)cancel confirm:(SimpleBlock)confirm {
    self.closeBlock = cancel;
    self.cancelBlock = cancel;
    self.confirmBlock = confirm;
    
    self.titleLabel.text = title;
    self.messageLabel.text = message;
}

#pragma mark - lazy load

- (UIView *)contentImageView {
    if (!_contentImageView) {
        _contentImageView = [[UIImageView alloc] init];
    }
    return _contentImageView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setupButtonWithIconName:@"\U0000e64b" iconSize:10 iconColor:[[UIColor blackColor] colorWithAlphaComponent:0.17]];
        [_closeButton addTarget:self action:@selector(didClickCloseButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];//iOS >= 8.2
        _titleLabel.textColor = UIColorFromRGB(0x191f46);
        _titleLabel.numberOfLines = 1;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:11];
        _messageLabel.textColor = [UIColorFromRGB(0x191f46) colorWithAlphaComponent:0.5];
        _messageLabel.numberOfLines = 2;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _messageLabel;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.backgroundColor = [UIColor whiteColor];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_cancelButton addTarget:self action:@selector(didClickCancelButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.backgroundColor = [UIColor whiteColor];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_confirmButton addTarget:self action:@selector(didClickConfirmButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

#pragma mark - init

- (instancetype)init {
    self = [super init];
    if (self) {
        self.width = 40;//需要设置初始宽度，不然会报约束不能满足错误
        
        [self addSubview:self.contentImageView];
        [self.contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        [self.contentImageView layoutIfNeeded];
        self.contentImageView.image = [UIImage imageNamed:@"alert_bg"];//[UIImage getStretchedImage:@"alert_bg"];

        CGFloat buttonWidth = (COMMON_SCREEN_WIDTH - contentMargin * 2 - 15 * 2 - 18) / 2;
        [self addSubview:self.cancelButton];
        [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.bottom.mas_equalTo(-12);
            make.height.mas_equalTo(28);
            make.width.mas_equalTo(buttonWidth);
        }];
        [self.cancelButton layoutIfNeeded];
        [self.cancelButton setCornerRadiusHalfHeight];
        [self.cancelButton addGradientLayerColors:@[LIGHT_THEME_COLOR, UIColorFromRGB(0x35b2ff)]];
        
        [self addSubview:self.confirmButton];
        [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-15);
            make.bottom.mas_equalTo(-12);
            make.height.mas_equalTo(28);
            make.width.mas_equalTo(buttonWidth);
        }];
        [self.confirmButton layoutIfNeeded];
        [self.confirmButton setCornerRadiusHalfHeight];
        [self.confirmButton addGradientLayerColors:@[LIGHT_THEME_COLOR, UIColorFromRGB(0x35b2ff)]];
        
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).offset(-10);
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
        }];
        
        [self addSubview:self.messageLabel];
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(12);
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
        }];
        
        CGFloat closeButtonOffset = -20;
        if (IS_NOTCH_SCREEN) {
            closeButtonOffset = -30;
        } else if (IS_BIG_SCREEN) {
            closeButtonOffset = -25;
        } else {
            closeButtonOffset = -20;
        }
        [self addSubview:self.closeButton];
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(16);
            make.bottom.equalTo(self.titleLabel.mas_top).offset(closeButtonOffset);
            make.right.mas_equalTo(-6);
        }];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"dealloc");
}

#pragma mark - events

- (void)didClickCancelButton {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

- (void)didClickConfirmButton {
    if (self.confirmBlock) {
        self.confirmBlock();
    }
}

- (void)didClickCloseButton {
    if (self.closeBlock) {
        self.closeBlock();
    }
}

@end
