//
//  KeyboardAboveView.m
//  WMYLink
//
//  Created by yuyuyu on 2020/12/18.
//  Copyright © 2020 yuyuyu. All rights reserved.
//

#import "KeyboardAboveView.h"
#import <Masonry.h>
#import "CustomTextView.h"

@interface KeyboardAboveView()
@property (strong, nonatomic) CustomCountTextView *contentTextView;
@property (strong, nonatomic) UIButton *sendButton;
@end
@implementation KeyboardAboveView

#pragma mark - init

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.sendButton];
        [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(15);
            make.right.bottom.mas_equalTo(-15);
        }];
        
        [self addSubview:self.contentTextView];
        [self.contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(15);
            make.bottom.mas_equalTo(-15);
            make.right.equalTo(self.sendButton.mas_left).offset(-15);
        }];
        [self.contentTextView layoutIfNeeded];
        [self.contentTextView setCornerRadius:5];
        self.contentTextView.placeholder = @"和朋友们聊聊吧~";
        self.contentTextView.maxLength = 0;
    }
    return self;
}

- (void)setHidden:(BOOL)hidden {
    if (hidden) {
        [self.contentTextView resignFirstResponder];
    } else {
        [self.contentTextView becomeFirstResponder];
    }
}

- (CustomCountTextView *)contentTextView {
    if (!_contentTextView) {
        _contentTextView = [[CustomCountTextView alloc] init];
        //_contentTextView.returnKeyType = UIReturnKeyDone;
        _contentTextView.font = [UIFont systemFontOfSize:14];
        _contentTextView.textColor = UIColorFromRGB(0x333333);
        _contentTextView.backgroundColor = BACKGROUND_COLOR;
    }
    return _contentTextView;
}

- (UIButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendButton setTitleColor:THEME_COLOR forState:UIControlStateNormal];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

#pragma mark - private

- (void)sendMessage {
    if (self.contentTextView.text.length != 0) {
        [self.contentTextView resignFirstResponder];
        if (self.sendText) {
            self.sendText(self.contentTextView.text);
            self.contentTextView.text = @"";
        }
    }
}


@end
