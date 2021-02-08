//
//  CustomAlertView.m
//  WMYLink
//
//  Created by yizhi on 2020/12/3.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#import "CustomAlertView.h"
#import <Masonry.h>
#import "CustomResultContentView.h"

@interface CustomAlertView()
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *confirmButton;

@property (assign, nonatomic) CustomAlertViewType type;
@property (copy, nonatomic) SimpleBlock confirmBlock;

@property (strong, nonatomic) CustomResultContentView *resultContentView;
@end
@implementation CustomAlertView

const CGFloat alertViewCornerRadius = 5;

#pragma mark - public

+ (void)showInfo:(NSString *)message confirmBlock:(SimpleBlock)block {
    [self showCustomAlertViewWithType:CustomAlertViewTypeInfo title:@"" message:message confirmBlock:block];
}

+ (void)showConfirm:(NSString *)message confirmBlock:(SimpleBlock)block {
    [self showCustomAlertViewWithType:CustomAlertViewTypeConfirm title:@"" message:message confirmBlock:block];
}

+ (void)showError:(NSString *)title message:(NSString *)message confirmBlock:(SimpleBlock)block {
    [self showCustomAlertViewWithType:CustomAlertViewTypeError title:title message:message confirmBlock:block];
}

+ (void)showErrorConfirm:(NSString *)title message:(NSString *)message confirmBlock:(SimpleBlock)block {
    [self showCustomAlertViewWithType:CustomAlertViewTypeErrorConfirm title:title message:message confirmBlock:block];
}

#pragma mark - lazy load

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    return _contentView;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:16];
        _messageLabel.textColor = UIColorFromRGB(0x333333);
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
        [_cancelButton setTitleColor:THEME_COLOR forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_cancelButton addTarget:self action:@selector(didClickCancelButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.backgroundColor = THEME_COLOR;
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_confirmButton addTarget:self action:@selector(didClickConfirmButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (CustomResultContentView *)resultContentView {
    if (!_resultContentView) {
        _resultContentView = [[CustomResultContentView alloc] init];
    }
    return _resultContentView;
}

#pragma mark - init

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, COMMON_SCREEN_WIDTH, COMMON_SCREEN_HEIGHT);
        self.backgroundColor = POP_BACKGROUND_COLOR;

        [self addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.mas_equalTo(50);
            make.right.mas_equalTo(-50);
            make.height.mas_equalTo(160);
        }];
        [self.contentView setCornerRadius:alertViewCornerRadius];
        
        [self.contentView addSubview:self.messageLabel];
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(40);
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
        }];
        
        [self.contentView addSubview:self.cancelButton];
        [self.contentView layoutIfNeeded];
        [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.bottom.mas_equalTo(-16);
            make.height.mas_equalTo(36);
            make.width.mas_equalTo((self.contentView.width - 15 * 2 - 5) / 2);
        }];
        [self.cancelButton setCornerRadius:2 borderColor:THEME_COLOR borderWidth:1];
        
        [self.contentView addSubview:self.confirmButton];
        [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-15);
            make.bottom.mas_equalTo(-16);
            make.height.mas_equalTo(36);
            make.left.equalTo(self.cancelButton.mas_right).offset(5);
        }];
        [self.confirmButton setCornerRadius:2];
        //水平，固定间隔，等宽排列
        //适合固定组件的布局，不方便更新约束
//        NSArray *buttons = @[self.cancelButton, self.confirmButton];
//        [buttons mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:5 leadSpacing:15 tailSpacing:15];
//        [buttons mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.bottom.mas_equalTo(-16);
//            make.height.mas_equalTo(36);
//        }];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"dealloc");
}

#pragma mark - private

+ (void)showCustomAlertViewWithType:(CustomAlertViewType)type title:(NSString *)title message:(NSString *)message confirmBlock:(SimpleBlock)block {
    CustomAlertView *alertView = [[CustomAlertView alloc] init];
    alertView.type = type;
    if (block) { alertView.confirmBlock = block; }
    switch (type) {
        case CustomAlertViewTypeInfo: {
            [alertView.cancelButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(0);
            }];
            [alertView.confirmButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-77);
                make.left.equalTo(alertView.cancelButton.mas_right).offset(77 - 15);
            }];
            alertView.messageLabel.text = message;
            [alertView.confirmButton setTitle:@"知道了" forState:UIControlStateNormal];
            break;
        }
        case CustomAlertViewTypeConfirm: {
            alertView.messageLabel.text = message;
            break;
        }
        case CustomAlertViewTypeError: {
            [alertView.contentView removeFromSuperview];
            [alertView addSubview:alertView.resultContentView];
            [alertView.resultContentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(93);
                make.right.mas_equalTo(-92);
                make.height.equalTo(alertView.resultContentView.mas_width).multipliedBy(186/190.0);
                make.centerY.equalTo(alertView);
            }];
            @weakify(alertView);
            [alertView.resultContentView setupErrorContent:title message:message cancel:^{
                @strongify(alertView);
                [alertView hideCustomAlertView];
            } confirm:^{
                @strongify(alertView);
                [alertView hideCustomAlertView];
            }];
            break;
        }
        case CustomAlertViewTypeSuccess: {
            [alertView.contentView removeFromSuperview];

            [alertView addTapToHide];
            break;
        }
        case CustomAlertViewTypeErrorConfirm: {
            [alertView.contentView removeFromSuperview];
            [alertView addSubview:alertView.resultContentView];
            [alertView.resultContentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(93);
                make.right.mas_equalTo(-92);
                make.height.equalTo(alertView.resultContentView.mas_width).multipliedBy(186/190.0);
                make.centerY.equalTo(alertView);
            }];
            @weakify(alertView);
            [alertView.resultContentView setupErrorConfirmContent:title message:message cancel:^{
                @strongify(alertView);
                [alertView hideCustomAlertView];
            } confirm:^{
                @strongify(alertView);
                [alertView hideCustomAlertView];
                if (alertView.confirmBlock) {
                    alertView.confirmBlock();
                }
            }];
            break;
        }
    }
    [KEY_WINDOW addSubview:alertView];
    if (type == CustomAlertViewTypeInfo || type == CustomAlertViewTypeConfirm) {
        [alertView.contentView addPopAnimation];
    } else {
        [alertView.resultContentView addPopAnimation];
    }
}

- (void)hideCustomAlertViewWithoutAnimation {
    [self removeFromSuperview];
}

- (void)hideCustomAlertView {
    [self addFadeAnimation];
}

- (void)addTapToHide {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCustomAlertView)];
    [self addGestureRecognizer:tap];
}

- (void)didClickCancelButton {
    [self hideCustomAlertView];
}

- (void)didClickConfirmButton {
    [self hideCustomAlertView];
    if (self.confirmBlock) {
        self.confirmBlock();
    }
}

@end
