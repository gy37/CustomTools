//
//  CustomActionSheet.m
//  WMYLink
//
//  Created by 高申宇 on 2020/12/5.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#import "CustomActionSheet.h"
#import <Masonry.h>
#import "CustomSheetContentView.h"

@interface CustomActionSheet()
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *confirmButton;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIDatePicker *dateTimePicker;
@property (strong, nonatomic) CustomSheetContentView *sheetContentView;

@property (assign, nonatomic) CustomActionSheetType type;
@property (strong, nonatomic) NSDate *pickedDate;
@property (copy, nonatomic) ConfirmSelectBlock confirmBlock;
@property (copy, nonatomic) ClickedButtonAtIndex clickBlock;
@end
@implementation CustomActionSheet

const CGFloat commonButtonHeight = 44.f;
const CGFloat horizontalButtonHeight = 94.f;

#pragma mark - public

+ (void)showActionSheet:(CustomActionSheetType)type confirmBlock:(ConfirmSelectBlock)confirm {
    NSString *title = type == CustomActionSheetTypeDateSelect ? @"日期选择" : @"时间选择";
    [self showActionSheet:type title:title confirmBlock:confirm];
}

+ (void)showActionSheet:(CustomActionSheetType)type title:(NSString *)title confirmBlock:(ConfirmSelectBlock)confirm {
    CustomActionSheet *actionSheet = [[CustomActionSheet alloc] init];
    actionSheet.type = type;
    actionSheet.titleLabel.text = title;
    if (confirm) { actionSheet.confirmBlock = confirm; }
    if (@available(iOS 13.4, *)) {
        actionSheet.dateTimepicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    } else {
        // Fallback on earlier versions
    }
    NSString *localeIdentifier = @"zh_CN";
    switch (type) {
        case CustomActionSheetTypeDateSelect: {
            actionSheet.dateTimepicker.datePickerMode = UIDatePickerModeDate;
            actionSheet.dateTimePicker.minimumDate = [NSDate date];
            localeIdentifier = @"zh_CN";//显示中文
            actionSheet.dateTimePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier];
            break;
        }
        case CustomActionSheetTypeTimeSelect: {
            actionSheet.dateTimepicker.datePickerMode = UIDatePickerModeTime;
            actionSheet.dateTimePicker.minimumDate = [NSDate date];
            localeIdentifier = @"en_GB";//24小时制
            actionSheet.dateTimePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier];
            break;
        }
        default: {
            break;
        }
    }

    [KEY_WINDOW addSubview:actionSheet];
    [actionSheet.contentView addPresentAnimation];
}

+ (void)showActionSheet:(CustomActionSheetType)type titles:(NSArray<NSString *> *)titles clickedAt:(ClickedButtonAtIndex)clicked {
    [self showActionSheet:type images:@[] titles:titles clickedAt:clicked];
}

+ (void)showActionSheet:(CustomActionSheetType)type images:(NSArray<NSString *> *)images titles:(NSArray<NSString *> *)titles clickedAt:(ClickedButtonAtIndex)click {
    CustomActionSheet *actionSheet = [[CustomActionSheet alloc] init];
    actionSheet.type = type;
    if (click) { actionSheet.clickBlock = click; }
    switch (type) {
        case CustomActionSheetTypeVertical: {
            [actionSheet.contentView removeFromSuperview];
            [actionSheet addSubview:actionSheet.sheetContentView];
            [actionSheet.sheetContentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.equalTo(actionSheet);
                make.height.mas_equalTo(COMMON_SAFE_AREA_BOTTOM_HEIGHT + commonButtonHeight + 6 + commonButtonHeight * titles.count);
            }];
            [actionSheet.sheetContentView layoutIfNeeded];
            [actionSheet.sheetContentView setCornerRadius:10 corners:UIRectCornerTopLeft | UIRectCornerTopRight];
            @weakify(actionSheet);
            [actionSheet.sheetContentView setupSheetOriention:NO titles:titles images:images cancel:^{
                @strongify(actionSheet);
                [actionSheet hideCustomActionSheet];
            } click:^(NSInteger index) {
                @strongify(actionSheet);
                [actionSheet hideCustomActionSheet];
                if (actionSheet.clickBlock) {
                    actionSheet.clickBlock(index);
                }
            }];
            break;
        }
        case CustomActionSheetTypeHorizontal: {
            [actionSheet.contentView removeFromSuperview];
            [actionSheet addSubview:actionSheet.sheetContentView];
            [actionSheet.sheetContentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.equalTo(actionSheet);
                make.height.mas_equalTo(COMMON_SAFE_AREA_BOTTOM_HEIGHT + commonButtonHeight + 6 + horizontalButtonHeight);
            }];
            [actionSheet.sheetContentView layoutIfNeeded];
            [actionSheet.sheetContentView setCornerRadius:10 corners:UIRectCornerTopLeft | UIRectCornerTopRight];
            @weakify(actionSheet);
            [actionSheet.sheetContentView setupSheetOriention:YES titles:titles images:images cancel:^{
                @strongify(actionSheet);
                [actionSheet hideCustomActionSheet];
            } click:^(NSInteger index) {
                @strongify(actionSheet);
                [actionSheet hideCustomActionSheet];
                if (actionSheet.clickBlock) {
                    actionSheet.clickBlock(index);
                }
            }];
            break;
        }
        default: {
            break;
        }
    }

    [KEY_WINDOW addSubview:actionSheet];
    if (type == CustomActionSheetTypeDateSelect || type == CustomActionSheetTypeTimeSelect) {
        [actionSheet.contentView addPresentAnimation];
    } else {
        [actionSheet.sheetContentView addPresentAnimation];
    }
}

#pragma mark - lazy load

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    return _contentView;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
    }
    return _topView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.backgroundColor = [UIColor whiteColor];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:UIColorFromRGB(0x108ee9) forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_cancelButton addTarget:self action:@selector(didClickCancelButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.backgroundColor = [UIColor whiteColor];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:UIColorFromRGB(0x108ee9) forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_confirmButton addTarget:self action:@selector(didClickConfirmButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];//iOS >= 8.2
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIDatePicker *)dateTimepicker {
    if (!_dateTimePicker) {
        _dateTimePicker = [[UIDatePicker alloc] init];
        [_dateTimePicker addTarget:self action:@selector(pickDateTime:) forControlEvents:UIControlEventValueChanged];
    }
    return _dateTimePicker;
}

- (CustomSheetContentView *)sheetContentView {
    if (!_sheetContentView) {
        _sheetContentView = [[CustomSheetContentView alloc] init];
    }
    return _sheetContentView;
}

#pragma mark - init
- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, COMMON_SCREEN_WIDTH, COMMON_SCREEN_HEIGHT);
        self.backgroundColor = POP_BACKGROUND_COLOR;
        
        [self addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.mas_equalTo(260);
        }];
        [self.contentView layoutIfNeeded];
        
        [self.contentView addSubview:self.topView];
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.contentView);
            make.height.mas_equalTo(42);
        }];
        [self.topView layoutIfNeeded];
        [self.topView addBorder:UIColorFromRGB(0xdddddd) position:CustomViewBorderPositionBottom isDashed:NO];
        
        [self.topView addSubview:self.cancelButton];
        [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(10);
            make.bottom.mas_equalTo(-10);
            make.width.mas_equalTo(50);
        }];
        
        [self.topView addSubview:self.confirmButton];
        [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.right.bottom.mas_equalTo(-10);
            make.width.mas_equalTo(50);
        }];
        
        [self.topView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.topView);
            make.left.equalTo(self.cancelButton.mas_right);
            make.right.equalTo(self.confirmButton.mas_left);
        }];
        
        [self.contentView addSubview:self.dateTimepicker];
        [self.dateTimepicker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.contentView);
            make.top.equalTo(self.topView.mas_bottom);
        }];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"dealloc");
}

#pragma mark - private

- (void)hideCustomActionSheetWithoutAnimation {
    [self removeFromSuperview];
}

- (void)hideCustomActionSheet {
    [self addDismissAnimation];
}

- (void)addTapToHide {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCustomActionSheet)];
    [self addGestureRecognizer:tap];
}

- (void)didClickCancelButton {
    [self hideCustomActionSheet];
}

- (void)didClickConfirmButton {
    [self hideCustomActionSheet];
    if (self.confirmBlock) {
        if (!self.pickedDate) { self.pickedDate = [NSDate date]; }
        if (self.type == CustomActionSheetTypeDateSelect) {
            self.confirmBlock([NSString getDateString:self.pickedDate]);
        } else if (self.type == CustomActionSheetTypeTimeSelect) {
            self.confirmBlock([NSString getTimeStringWithoutSeconds:self.pickedDate]);
        }
    }
}

- (void)pickDateTime:(UIDatePicker *)picker {
    self.pickedDate = picker.date;
}
@end
