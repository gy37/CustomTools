//
//  CustomSheetContentView.m
//  WMYLink
//
//  Created by yuyuyu on 2020/12/17.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import "CustomSheetContentView.h"
#import <Masonry.h>
#import "UIButton+Custom.h"

@interface CustomSheetContentView()
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIView *topView;

@property (copy, nonatomic) SimpleBlock cancelBlock;
@property (copy, nonatomic) ClickedButtonAtIndex clickBlock;
@end
@implementation CustomSheetContentView
const CGFloat verticalButtonHeight = 44;
const CGFloat horizontalButtonWidth = 75;
const NSInteger buttonTagBase = 10000;

#pragma mark - public

- (void)setupSheetOriention:(BOOL)isHorizontal titles:(NSArray<NSString *> *)titles images:(NSArray<NSString *> *)images cancel:(SimpleBlock)cancel click:(ClickedButtonAtIndex)click {
    self.cancelBlock = cancel;
    self.clickBlock = click;
    [self createButtonsWithOriention:isHorizontal titles:titles images:images];
}

#pragma mark - lazy load

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.backgroundColor = [UIColor whiteColor];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_cancelButton addTarget:self action:@selector(didClickCancelButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = [UIColor whiteColor];
    }
    return _topView;
}

#pragma mark - init

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColorFromRGB(0xf0f0f0) colorWithAlphaComponent:0.98];

        [self addSubview:self.bottomView];
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.mas_equalTo(COMMON_SAFE_AREA_BOTTOM_HEIGHT);
        }];
        
        [self addSubview:self.cancelButton];
        [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.bottom.equalTo(self.bottomView.mas_top);
            make.height.mas_equalTo(verticalButtonHeight);
        }];
        
        [self addSubview:self.topView];
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.bottom.equalTo(self.cancelButton.mas_top).offset(-6);
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

- (void)didClickButton:(UIButton *)button {
    if (self.clickBlock) {
        self.clickBlock(button.tag - buttonTagBase);
    }
}

#pragma mark - private

- (void)createButtonsWithOriention:(BOOL)isHorizontal titles:(NSArray<NSString *> *)titles images:(NSArray<NSString *> *)images {
    NSInteger count = MAX(titles.count, images.count);
    for (NSInteger i = 0; i < count; i ++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor whiteColor];
        [button addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = buttonTagBase + i;
        [self.topView addSubview:button];
        UIImage *image = images.count > i ? [UIImage imageNamed:images[i]] : nil;
        NSString *title = titles.count > i ? titles[i] : @"";
        if (isHorizontal) {
            CGFloat width = (self.topView.width - horizontalButtonWidth * count) / count + horizontalButtonWidth;
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.topView.mas_left).offset(width * i + width / 2.0);
                make.centerY.equalTo(self.topView);
                make.width.height.mas_equalTo(75);
            }];
            [button setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:12];
            [button setupButtonWithTopImage:image bottomTitle:title];
        } else {
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-verticalButtonHeight * i);
                make.centerX.equalTo(self.topView);
                make.width.mas_equalTo(COMMON_SCREEN_WIDTH);
                make.height.mas_equalTo(verticalButtonHeight);
            }];
            [button setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:18];
            [button setTitle:title forState:UIControlStateNormal];
            [button setImage:image forState:UIControlStateNormal];
            [button setImage:image forState:UIControlStateHighlighted];
            if (i != 0) [button addBorder:BORDER_COLOR position:CustomViewBorderPositionBottom isDashed:NO];
        }
    }
}

@end
