//
//  CustomTextView.m
//  WMYLink
//
//  Created by yizhi on 2020/12/2.
//  Copyright © 2020 YiZhi. All rights reserved.
//

#import "CustomTextView.h"
#import <Masonry.h>
@implementation CustomLinkTextView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.font = [UIFont systemFontOfSize:self.font.pointSize];
}

//重写方法，禁止选择
- (UITextRange *)selectedTextRange {
    return nil;
}

//重写方法，只允许单击手势
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tap = (UITapGestureRecognizer *)gestureRecognizer;
        if (tap.numberOfTapsRequired == 1) {
            return [super gestureRecognizerShouldBegin:gestureRecognizer];
        }
    }
    gestureRecognizer.enabled = NO;
    return NO;
}

@end

@interface CustomCountTextView()<UITextViewDelegate>
@property (strong, nonatomic) UILabel *placeholderLabel;
@property (strong, nonatomic) UILabel *countLabel;
@end
@implementation CustomCountTextView
#pragma mark - init

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupSubViews];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
//    self.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.font = [UIFont systemFontOfSize:self.font.pointSize];
    
    [self addSubview:self.placeholderLabel];
    [self.placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(4);
        make.top.equalTo(self).offset(8);
    }];
    
    self.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.65];
    
    self.delegate = self;
}

#pragma mark - override

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] init];
        _placeholderLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
        _placeholderLabel.font = [UIFont systemFontOfSize:14];
        _placeholderLabel.userInteractionEnabled = NO;
        _placeholderLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _placeholderLabel;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
        _countLabel.font = [UIFont systemFontOfSize:12];
        _countLabel.userInteractionEnabled = NO;
        _countLabel.textAlignment = NSTextAlignmentRight;
    }
    return _countLabel;
}

- (void)dealloc {
    NSLog(@"dealloc");
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.placeholderLabel.text = placeholder;
}

- (void)setMaxLength:(NSInteger)maxLength {
    _maxLength = maxLength != 0 ? maxLength : NSIntegerMax;
    //textview:UIScrollView约束设置比较特别，直接在上面添加的话会随着textview滑动
    //因为要添加到superview上，所以等初始化完成后再添加
    [self.superview addSubview:self.countLabel];
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.superview).offset(-15);
        make.bottom.equalTo(self.superview).offset(-6);
    }];
    
    self.countLabel.text = [NSString stringWithFormat:@"%d/%ld", 0, (long)maxLength];
    self.countLabel.hidden = maxLength == 0;
}

#pragma mark - delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    self.placeholderLabel.hidden = textView.text.length != 0;

    NSString *lang = [[UIApplication sharedApplication] textInputMode].primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"] || [lang isEqualToString:@"zh-Hant"]) {
        UITextRange *selectedRange = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if (textView.text.length > self.maxLength) {
                textView.text = [textView.text substringToIndex:self.maxLength];
                self.countLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)textView.text.length, (long)self.maxLength];
            } else {
                self.countLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)textView.text.length, (long)self.maxLength];
            }
        }
    } else {
        if (textView.text.length > self.maxLength) {
            textView.text = [textView.text substringToIndex:self.maxLength];
            self.countLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)textView.text.length, (long)self.maxLength];
        } else {
            self.countLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)textView.text.length, (long)self.maxLength];
        }
    }
    if (self.changeBlock) {
        self.changeBlock(textView.text);
    }
}

@end
